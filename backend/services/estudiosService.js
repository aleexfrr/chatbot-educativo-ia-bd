const Estudio = require("../models/Estudio");

async function getAsignaturas(siglasCurso) {
    const curso = await Estudio.findOne({
        siglas: { $regex: `^\\s*${siglasCurso}\\s*$`, $options: "i" }
    });

    if (!curso || !curso.assignatures || curso.assignatures.length === 0) {
        return null;
    }

    return curso.assignatures.map(a => ({ nombre: a.nom, horas: a.hores, curso: a.curs }));
}

async function getHoras(asignatura, siglasCurso) {
    const asignatures = await getAsignaturas(siglasCurso);
    if (!asignatures) return null;

    const a = asignatures.find(a => a.nombre.toLowerCase() === asignatura.toLowerCase());
    return a ? a.horas : null;
}

async function getCurso(siglasCurso) {
    const curso = await Estudio.findOne({
        siglas: { $regex: `^\\s*${siglasCurso}\\s*$`, $options: "i" }
    });

    if (!curso) return null;

    return {
        nombre: curso.nombre,
        siglas: curso.siglas,
        nivel: curso.nivel,
        duracion_anyos: curso.duracion_anyos,
        hores_totals: curso.hores_totals
    };
}

module.exports = { getAsignaturas, getHoras, getCurso };
