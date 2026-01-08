const mongoose = require("mongoose");
const express = require("express");
const cors = require("cors");
const { getAsignaturas, getHoras, getCurso } = require("./services/estudiosService");

const app = express();
app.use(cors());

// Conexión a MongoDB Atlas
mongoose.connect(
    "mongodb+srv://bedrock_db_user:bedrock@chatbot.m4nu11p.mongodb.net/chatbot?retryWrites=true&w=majority"
)
.then(() => console.log("✅ Conectado a MongoDB"))
.catch(err => console.error("❌ Error de conexión:", err));

// Endpoint para el chatbot
app.get("/chat", async (req, res) => {
    const msg = req.query.msg?.toLowerCase() || "";

    let respuesta = "No entiendo tu pregunta 😅";

    try {
        if (msg.includes("asignaturas") && msg.includes("dam")) {
        const asignaturas = await getAsignaturas("DAM");
        if (asignaturas) {
            respuesta = "Asignaturas de DAM: " + asignaturas.map(a => a.nombre).join(", ");
        } else {
            respuesta = "No encontré asignaturas para DAM.";
        }
        } else if (msg.includes("horas") && msg.includes("programació")) {
        const horas = await getHoras("Programació", "DAM");
        respuesta = horas ? `Programació tiene ${horas} horas` : "No encontré esa asignatura.";
        } else if (msg.includes("info") && msg.includes("dam")) {
        const info = await getCurso("DAM");
        respuesta = info ? `Curso DAM: ${info.nombre}, nivel: ${info.nivel}, duración: ${info.duracion_anyos} años, horas totales: ${info.hores_totals}` : "No encontré información de DAM.";
        }
    } catch (e) {
        console.error(e);
        respuesta = "Ocurrió un error al procesar tu consulta.";
    }

    res.json({ respuesta });
});

// Levantar servidor en puerto 3001
app.listen(3001, () => console.log("Backend escuchando en http://localhost:3001"));
