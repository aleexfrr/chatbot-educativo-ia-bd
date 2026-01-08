const mongoose = require("mongoose");

// Schema de cada asignatura
const asignaturaSchema = new mongoose.Schema({
    nom: String,
    hores: Number,
    curs: Number
}, { _id: false });

// Schema del curso/estudio
const estudioSchema = new mongoose.Schema({
    tipo: String,
    nombre: String,
    siglas: String,
    familia: String,
    nivel: String,
    duracion_anyos: Number,
    hores_totals: Number,
    assignatures: [asignaturaSchema]
}, { collection: "estudios" });

module.exports = mongoose.model("Estudio", estudioSchema);
