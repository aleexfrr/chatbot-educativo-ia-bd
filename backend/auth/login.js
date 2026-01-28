import puppeteer from "puppeteer";
import fs from "fs";
import { normalizeProvincia } from "../utils/normalizeProvincia.js";

/**
 * Login en Aules y guardado de cookies por modalidad/provincia
 */
export async function loginAndSaveCookies(
    nia,
    password,
    baseUrl,
    modalidad,
    provincia
) {
    if (!nia || !password || !baseUrl || !modalidad) {
        throw new Error("Faltan parámetros para el login (nia, password, baseUrl, modalidad)");
    }

    const prov = normalizeProvincia(modalidad, provincia);
    const cookiesPath = `./cookies_${modalidad}_${prov}.json`;

    const browser = await puppeteer.launch({
        headless: false,
        defaultViewport: null
    });

    const context = browser.defaultBrowserContext();
    const page = await context.newPage();

    await page.goto(`${baseUrl}/login/index.php`, { waitUntil: "networkidle2" });

    await page.type("#username", nia, { delay: 40 });
    await page.type("#password", password, { delay: 40 });

    await Promise.all([
        page.click("#loginbtn"),
        page.waitForNavigation({ waitUntil: "networkidle2" })
    ]);

    if (!page.url().includes("/my")) {
        await browser.close();
        throw new Error("Credenciales incorrectas o login fallido");
    }

    const cookies = await context.cookies();
    fs.writeFileSync(cookiesPath, JSON.stringify(cookies, null, 2));

    console.log(`✅ Cookies guardadas en ${cookiesPath}`);

    await browser.close();
}
