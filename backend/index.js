const mongoose = require("mongoose");
const express = require("express");
const cors = require("cors");
const { getAsignaturas, getHoras, getCurso } = require("./services/estudiosService");
const { invocarAgenteBedrock } = require("./services/bedrockService");
const Consulta = require("./models/Consulta");
require("dotenv").config();
const app = express();
app.use(cors());
app.use(express.json());

mongoose.connect(
    "mongodb+srv://bedrock_db_user:bedrock@chatbot.m4nu11p.mongodb.net/chatbot?retryWrites=true&w=majority"
)
.then(() => console.log(" Conectado a MongoDB"),)

.catch(err => console.error(" Error de conexión:", err));




app.get("/chat", async (req, res) => {
    
    const msg = req.query.msg?.trim();
    if (!msg) return res.json({ respuesta: "Por favor escribe algo" });

    let respuesta = "No entiendo tu pregunta ";

    try {
        respuesta = await invocarAgenteBedrock(msg);

        const nuevaConsulta = new Consulta({ mensaje: msg });
        await nuevaConsulta.save();

    } catch (e) {
        console.error(e);
        respuesta = "Ocurrió un error al procesar tu consulta con Bedrock.";
    }

    res.json({ respuesta });
});

app.listen(3001, () => console.log("Backend escuchando en http://localhost:3001"));