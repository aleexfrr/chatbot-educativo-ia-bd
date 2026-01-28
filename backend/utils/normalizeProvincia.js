export function normalizeProvincia(modalidad, provincia) {
    // Solo ESO depende de provincia. El resto: siempre "default".
    if (!modalidad) return "default";
    if (modalidad.toLowerCase() !== "eso") return "default";

    const p = (provincia || "").toLowerCase().trim();

    // normalizaciones típicas
    if (p === "valència") return "valencia";
    if (p === "alicant") return "alicante";
    if (p === "castelló") return "castellon";

    if (!p) return "default";
    return p;
}
