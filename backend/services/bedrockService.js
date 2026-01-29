import {
    BedrockAgentRuntimeClient,
    InvokeAgentCommand,
} from "@aws-sdk/client-bedrock-agent-runtime";
import dotenv from "dotenv";

dotenv.config();

// Crear cliente de Bedrock
const client = new BedrockAgentRuntimeClient({
    region: process.env.AWS_REGION,
    credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
        sessionToken: process.env.AWS_SESSION_TOKEN,
    },
});

/**
 * Invoca al agente de Bedrock manteniendo el contexto de la conversación
 * @param {string} mensaje - Mensaje del usuario
 * @param {string} sessionId - ID único de la sesión/conversación
 * @returns {Promise<string>} - Respuesta del agente
 */
export async function invocarAgenteBedrock(mensaje, sessionId) {
    console.log("🤖 Invocando Bedrock...");
    console.log("   Mensaje:", mensaje);
    console.log("   SessionID:", sessionId);

    try {
        const command = new InvokeAgentCommand({
            agentId: process.env.BEDROCK_AGENT_ID,
            agentAliasId: process.env.BEDROCK_AGENT_ALIAS_ID,
            sessionId: sessionId, // 👈 Usa el sessionId proporcionado
            inputText: mensaje,
        });

        console.log("📡 Enviando comando a Bedrock...");
        const response = await client.send(command);
        
        let respuestaCompleta = "";

        // Procesar la respuesta en chunks
        for await (const event of response.completion) {
            if (event.chunk?.bytes) {
                const text = new TextDecoder().decode(event.chunk.bytes);
                respuestaCompleta += text;
            }
        }

        console.log("✅ Respuesta de Bedrock recibida");
        console.log("   Longitud:", respuestaCompleta.length, "caracteres");

        return respuestaCompleta || "No recibí respuesta del agente.";
        
    } catch (error) {
        console.error("❌ Error al invocar agente Bedrock:");
        console.error("   Tipo:", error.name);
        console.error("   Mensaje:", error.message);
        
        // Re-lanzar el error para manejarlo en el endpoint
        throw new Error(`Bedrock error: ${error.message}`);
    }
}