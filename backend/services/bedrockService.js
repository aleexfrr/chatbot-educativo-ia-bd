const { BedrockAgentRuntimeClient, InvokeAgentCommand } = require("@aws-sdk/client-bedrock-agent-runtime");
require("dotenv").config();

const client = new BedrockAgentRuntimeClient({
    region: process.env.AWS_REGION,
    credentials: {
        accessKeyId: process.env.AWS_ACCESS_KEY_ID,
        secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY,
        sessionToken: process.env.AWS_SESSION_TOKEN  
    }
});

async function invocarAgenteBedrock(mensaje, sessionId = "session-" + Date.now()) {
    console.log("🤖 Invocando Bedrock con mensaje:", mensaje);
    
    try {
        const command = new InvokeAgentCommand({
            agentId: process.env.BEDROCK_AGENT_ID,
            agentAliasId: process.env.BEDROCK_AGENT_ALIAS_ID,
            sessionId: sessionId,
            inputText: mensaje
        });

        const response = await client.send(command);
        
        let respuestaCompleta = "";
        
        for await (const event of response.completion) {
            if (event.chunk && event.chunk.bytes) {
                const text = new TextDecoder().decode(event.chunk.bytes);
                respuestaCompleta += text;
            }
        }

        return respuestaCompleta;
        
    } catch (error) {
        console.error(" Error al invocar agente Bedrock:", error);
        console.error(" Detalles del error:", error.message);
        throw error;
    }
}

module.exports = { invocarAgenteBedrock };