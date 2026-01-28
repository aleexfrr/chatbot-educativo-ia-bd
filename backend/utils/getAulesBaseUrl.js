import { AULES_URLS } from "../config/aules.js";

export function getAulesBaseUrl(modalidad, provincia) {
    const mod = AULES_URLS[modalidad];

    if (!mod) {
        throw new Error("Modalidad no válida");
    }

    // Modalidades con provincias (ESO)
    if (modalidad === "eso") {
        if (!provincia) {
            throw new Error("Provincia obligatoria para ESO");
        }

        const url = mod[provincia.toLowerCase()];
        if (!url) {
            throw new Error("Provincia no válida para ESO");
        }

        return url;
    }

    // Modalidades sin provincias
    return mod.default;
}
