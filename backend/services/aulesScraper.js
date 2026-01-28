import puppeteer from "puppeteer";
import fs from "fs";
import { resolvePdf } from "../utils/pdfDownloader.js";
import { waitForAulesReady } from "../utils/waitForAulesReady.js";
import { getAulesBaseUrl } from "../utils/getAulesBaseUrl.js";
import { normalizeProvincia } from "../utils/normalizeProvincia.js";
import {
    S3Client,
    PutObjectCommand,
    HeadObjectCommand
} from "@aws-sdk/client-s3";

/* =========================
   S3 CLIENT (usa SSO / env / ~/.aws)
========================= */
const s3 = new S3Client({
    region: process.env.AWS_REGION
});

/* =========================
   UTIL: comprobar si subir PDF
========================= */
async function shouldUploadPdf({ bucket, key, newSize }) {
    try {
        const head = new HeadObjectCommand({
            Bucket: bucket,
            Key: key
        });

        const result = await s3.send(head);
        const existingSize = result.ContentLength;

        if (newSize > existingSize) {
            console.log("   🔄 PDF más grande que el de S3 → se reemplaza");
            return true;
        }

        console.log("   ⏭️ PDF ya existe y es igual o mayor → se omite");
        return false;

    } catch (err) {
        // AWS SDK v3: a veces NotFound llega con status 404 en $metadata
        const code = err?.name;
        const status = err?.$metadata?.httpStatusCode;

        if (code === "NotFound" || code === "NoSuchKey" || status === 404) {
            console.log("   🆕 PDF no existe en S3 → se sube");
            return true;
        }

        throw err;
    }
}

/* =========================
   FUNCIÓN PRINCIPAL
========================= */
export async function downloadAulesPdfs({
    instituto,
    modalidad,
    provincia
}) {
    if (!instituto || !modalidad) {
        throw new Error("Instituto y modalidad son obligatorios");
    }

    const prov = normalizeProvincia(modalidad, provincia);
    const cookiesPath = `./cookies_${modalidad}_${prov}.json`;

    if (!fs.existsSync(cookiesPath)) {
        throw new Error(`No existen cookies para ${modalidad}/${prov}. Ejecuta /login primero.`);
    }

    const cookies = JSON.parse(fs.readFileSync(cookiesPath, "utf-8"));
    const baseUrl = getAulesBaseUrl(modalidad, prov);

    const browser = await puppeteer.launch({
        headless: false,
        defaultViewport: null
    });

    try {
        const context = browser.defaultBrowserContext();
        await context.setCookie(...cookies);

        const page = await context.newPage();
        await page.goto(`${baseUrl}/my/`, { waitUntil: "domcontentloaded" });
        await waitForAulesReady(page);

        console.log(`✅ Sesión iniciada en Aules (${modalidad} / ${prov})`);

        /* =========================
           OBTENER CURSOS
        ========================= */
        const courses = await page.$$eval(
            "div.card-grid a[tabindex='-1']",
            els => [...new Set(els.map(e => e.href))]
        );

        console.log(`📚 Cursos encontrados: ${courses.length}`);

        /* =========================
           RECORRER CURSOS
        ========================= */
        for (const courseUrl of courses) {
            await page.goto(courseUrl, { waitUntil: "domcontentloaded" });
            await waitForAulesReady(page);

            let fullCourseName = "";
            try {
                await page.waitForSelector("div.page-header-headings h1.h2.mb-0", { timeout: 30000 });
                fullCourseName = await page.$eval(
                    "div.page-header-headings h1.h2.mb-0",
                    el => el.textContent.trim()
                );
            } catch {
                console.log("⚠️ No se pudo leer el nombre del curso");
                continue;
            }

            console.log(`\n📂 Curso: ${fullCourseName}`);

            const [cursoReal, claseReal] = fullCourseName.split(".");

            /* =========================
               BUSCAR PDFs
            ========================= */
            let pdfViews = [];
            try {
                await page.waitForSelector('img.activityicon[src*="/f/pdf"]', { timeout: 15000 });

                pdfViews = await page.$$eval(
                    'img.activityicon[src*="/f/pdf"]',
                    imgs =>
                        imgs
                            .map(img => img.closest(".activity")?.querySelector("a[href]")?.href)
                            .filter(Boolean)
                );
            } catch {
                console.log("   ℹ️ No hay PDFs en este curso");
            }

            console.log(`📄 PDFs encontrados: ${pdfViews.length}`);

            /* =========================
               PROCESAR PDFs (diagnóstico)
            ========================= */
            for (const viewUrl of pdfViews) {
                console.log(`   🔗 View URL: ${viewUrl}`);

                // 1) DESCARGA
                let pdf;
                try {
                    pdf = await resolvePdf(viewUrl, cookies, baseUrl);
                    console.log(`   📥 Descargado: ${pdf.filename} (${pdf.buffer.length} bytes)`);
                } catch (err) {
                    console.log("   ❌ FALLO DESCARGA (resolvePdf)");
                    console.log("      - name:", err?.name);
                    console.log("      - message:", err?.message);
                    console.log("      - status:", err?.response?.status);
                    console.log("      - content-type:", err?.response?.headers?.["content-type"]);
                    console.log("      - url:", err?.config?.url);

                    if (err?.response?.data) {
                        const preview = Buffer.from(err.response.data)
                            .toString("utf8", 0, 200)
                            .replace(/\s+/g, " ");
                        console.log("      - body(0..200):", preview);
                    }
                    continue;
                }

                const { buffer, filename } = pdf;
                const pdfSize = buffer.length;

                const key =
                    `${instituto}/${modalidad}/` +
                    `${claseReal || "Clase_Desconocida"}/` +
                    `${cursoReal}/${filename}`;

                // 2) HEAD S3
                let upload;
                try {
                    upload = await shouldUploadPdf({
                        bucket: process.env.AWS_BUCKET_NAME,
                        key,
                        newSize: pdfSize
                    });
                } catch (err) {
                    console.log("   ❌ FALLO S3 HEAD (HeadObject)");
                    console.log("      - name:", err?.name);
                    console.log("      - message:", err?.message);
                    console.log("      - $metadata:", err?.$metadata);
                    console.log("      - key:", key);
                    continue;
                }

                if (!upload) continue;

                // 3) PUT S3
                try {
                    const put = new PutObjectCommand({
                        Bucket: process.env.AWS_BUCKET_NAME,
                        Key: key,
                        Body: buffer,
                        ContentType: "application/pdf"
                    });

                    await s3.send(put);
                    console.log(`   ✅ PDF subido a S3: ${key}`);

                } catch (err) {
                    console.log("   ❌ FALLO S3 PUT (PutObject)");
                    console.log("      - name:", err?.name);
                    console.log("      - message:", err?.message);
                    console.log("      - $metadata:", err?.$metadata);
                    console.log("      - key:", key);
                }
            }
        }

        console.log("\n🎉 SCRAPING COMPLETADO");

    } finally {
        await browser.close();
    }
}
