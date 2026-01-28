export async function waitForAulesReady(page) {
    try {
        await page.waitForFunction(() => document.readyState === "complete", { timeout: 40000 });
        await page.waitForNetworkIdle({ idleTime: 2000, timeout: 40000 });
    } catch {
        console.log("⚠️ Timeout esperando a que Aules cargue completamente, continuando...");
    }
    await new Promise(resolve => setTimeout(resolve, 1000));
}
