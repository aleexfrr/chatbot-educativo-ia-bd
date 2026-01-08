const mongoose = require("mongoose");

const consultaSchema = new mongoose.Schema({
    mensaje: { type: String, required: true },
    fecha: { type: Date, default: Date.now }
}, { collection: "consultas" });

module.exports = mongoose.model("Consulta", consultaSchema);
