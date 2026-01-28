import express from "express";
import dotenv from "dotenv";
import cors from "cors";

import { loginAndSaveCookies } from "./auth/login.js";
import { downloadAulesPdfs } from "./services/aulesScraper.js";
import { invocarAgenteBedrock } from "./services/bedrockService.js";
import { getAulesBaseUrl } from "./utils/getAulesBaseUrl.js";
import { normalizeProvincia } from "./utils/normalizeProvincia.js";

dotenv.config();

const app = express();
app.use(cors());
app.use(express.json());

// ===== LOGIN =====
app.post("/login", async (req, res) => {
    try {
        const { nia, password, modalidad, provincia } = req.body;

        if (!nia || !password || !modalidad) {
            return res.status(400).json({
                mensaje: "❌ Faltan campos obligatorios (nia, password, modalidad)"
            });
        }

        const prov = normalizeProvincia(modalidad, provincia);
        const baseUrl = getAulesBaseUrl(modalidad, prov);

        await loginAndSaveCookies(nia, password, baseUrl, modalidad, prov);

        res.json({
            mensaje: "✅ Login exitoso, cookies guardadas.",
            modalidad,
            provincia: prov
        });
    } catch (error) {
        console.error("❌ Error en login:", error.message);
        res.status(400).json({ mensaje: error.message });
    }
});

// ===== DOWNLOAD PDFs =====
app.post("/download-pdfs", async (req, res) => {
    try {
        const { instituto, modalidad, provincia } = req.body;

        if (!instituto || !modalidad) {
            return res.status(400).json({
                mensaje: "❌ instituto y modalidad son obligatorios"
            });
        }

        await downloadAulesPdfs({ instituto, modalidad, provincia });

        res.json({ mensaje: "✅ Descarga de PDFs completada." });
    } catch (error) {
        console.error("❌ Error al descargar PDFs:", error.message);
        res.status(400).json({ mensaje: error.message });
    }
});

// ===== CHAT =====
app.get("/chat", async (req, res) => {
    const msg = req.query.msg?.trim();
    if (!msg) return res.json({ respuesta: "Por favor escribe algo" });

    try {
        const respuesta = await invocarAgenteBedrock(msg);
        res.json({ respuesta });
    } catch (error) {
        console.error(error);
        res.status(500).json({
            respuesta: "Ocurrió un error al procesar tu consulta con Bedrock."
        });
    }
});

app.listen(3001, () =>
    console.log("🚀 Backend escuchando en http://localhost:3001")
);
