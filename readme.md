# Chatbot Educativo IA-BD

Este proyecto es un **chatbot educativo** que permite consultar información sobre cursos, institutos y asignaturas de la Generalitat Valenciana.  

El backend está hecho en **Node.js** y conecta con **MongoDB Atlas**, mientras que el frontend es un **HTML/JS/CSS puro** con estilo tipo chat moderno.

---

## 🛠 Estructura del proyecto

```
chatbot/
│
├─ backend/
│   ├─ index.js          # Servidor Node.js principal
│   ├─ services/         # Lógica de consulta de cursos y asignaturas
│   ├─ models/           # Modelos de MongoDB (Estudio, Consulta)
│   └─ package.json
│
├─ frontend/
│   ├─ index.html
│   ├─ script.js
│   └─ style.css
│
└─ .gitignore
```

---

## ⚡ Funcionalidades

- Consultar cursos y asignaturas (ej: “Qué asignaturas tiene DAM”)  
- Consultar horas de asignaturas y duración de cursos  
- Guardar **historial de preguntas** en MongoDB  
- Interfaz de chat moderna con burbujas, hora de mensaje y animación “el bot está escribiendo…”  

---

## 🚀 Instalación y ejecución

1. Clonar el repositorio:

```bash
git clone <URL_DEL_REPO>
cd chatbot/backend
```

2. Instalar dependencias:

```bash
npm install
```

3. Configurar **MongoDB Atlas** en un archivo `.env` (ejemplo):

```
MONGODB_URI="mongodb+srv://usuario:clave@cluster.mongodb.net/chatbot?retryWrites=true&w=majority"
```

4. Ejecutar el servidor:

```bash
node index.js
```

5. Abrir `frontend/index.html` en el navegador.

---

## 📦 Tecnologías utilizadas

- **Node.js** para el backend  
- **Express** (si lo añades) para el servidor HTTP  
- **MongoDB Atlas** para la base de datos  
- **HTML/CSS/JS** para la interfaz de usuario  

---

## 🔧 Uso

- Escribe tu pregunta en el input del chat  
- Presiona Enter o clic en “Enviar”  
- El bot responderá con la información disponible  
- Las consultas se guardan automáticamente en la