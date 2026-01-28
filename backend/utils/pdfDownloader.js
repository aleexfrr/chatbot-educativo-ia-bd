import axios from "axios";
import { withRedirectParam } from "./redirect.js";

export async function resolvePdf(viewUrl, cookies, baseUrl) {
  if (!baseUrl) throw new Error("baseUrl es obligatorio");

  const cookieHeader = cookies.map(c => `${c.name}=${c.value}`).join("; ");
  const finalViewUrl = withRedirectParam(viewUrl);

  const response = await axios.get(finalViewUrl, {
    responseType: "arraybuffer",
    headers: {
      Cookie: cookieHeader,
      Referer: baseUrl,
      // Estos headers ayudan mucho con Moodle/Aules
      "User-Agent":
        "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120 Safari/537.36",
      Accept: "application/pdf,application/octet-stream;q=0.9,*/*;q=0.8",
      "Accept-Language": "es-ES,es;q=0.9,en;q=0.8"
    },
    maxRedirects: 10,
    timeout: 60000,
    // Aceptamos 2xx y 3xx para poder diagnosticar si redirige
    validateStatus: s => s >= 200 && s < 400
  });

  const contentType = response.headers["content-type"] || "";

  // Si no es PDF, muchas veces es HTML (login / error)
  if (!contentType.includes("application/pdf")) {
    const text = Buffer.from(response.data).toString("utf8", 0, 300).replace(/\s+/g, " ");
    throw new Error(
      `No es PDF (content-type=${contentType}). Preview: ${text}`
    );
  }

  let filename = "archivo.pdf";
  const cd = response.headers["content-disposition"];

  if (cd?.includes("filename=")) {
    filename = cd.split("filename=")[1].replace(/"/g, "").trim();
  } else {
    filename = decodeURIComponent(finalViewUrl.split("/").pop());
  }

  return { buffer: response.data, filename };
}
