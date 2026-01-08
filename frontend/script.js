const chat = document.getElementById("chat");
const input = document.getElementById("input");

function getHora() {
    const now = new Date();
    return now.getHours().toString().padStart(2, '0') + ":" + now.getMinutes().toString().padStart(2, '0');
}

async function enviar() {
    const mensaje = input.value.trim();
    if (!mensaje) return;

    // Mensaje del usuario
    const userMsg = document.createElement("div");
    userMsg.className = "message user";
    userMsg.innerHTML = `${mensaje}<span class="time">${getHora()}</span>`;
    chat.appendChild(userMsg);
    chat.scrollTop = chat.scrollHeight;
    input.value = "";

    // Animación "el bot está escribiendo..."
    const typingMsg = document.createElement("div");
    typingMsg.className = "message bot typing";
    typingMsg.textContent = "El bot está escribiendo...";
    chat.appendChild(typingMsg);
    chat.scrollTop = chat.scrollHeight;

    try {
        const res = await fetch(`http://localhost:3001/chat?msg=${encodeURIComponent(mensaje)}`);
        const data = await res.json();

        // Quitar animación
        chat.removeChild(typingMsg);

        // Mensaje del bot
        const botMsg = document.createElement("div");
        botMsg.className = "message bot";
        botMsg.innerHTML = `${data.respuesta}<span class="time">${getHora()}</span>`;
        chat.appendChild(botMsg);
        chat.scrollTop = chat.scrollHeight;

    } catch (e) {
        chat.removeChild(typingMsg);
        const botMsg = document.createElement("div");
        botMsg.className = "message bot";
        botMsg.innerHTML = `Error al conectar con el backend<span class="time">${getHora()}</span>`;
        chat.appendChild(botMsg);
        chat.scrollTop = chat.scrollHeight;
    }
}

input.addEventListener("keydown", (e) => {
    if (e.key === "Enter") enviar();
});
