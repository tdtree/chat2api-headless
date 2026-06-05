import { app } from 'electron'
import { storeManager } from './store/store'
import { ProxyServer } from './proxy/server'

app.commandLine.appendSwitch('no-sandbox')
app.commandLine.appendSwitch('disable-gpu')
app.commandLine.appendSwitch('in-process-gpu')
app.commandLine.appendSwitch('disable-software-rasterizer')
app.disableHardwareAcceleration()

async function startHeadless() {
  try {
    await storeManager.initialize()
    const config = storeManager.getConfig()
    let port = config.proxyPort || 6011
    const host = config.proxyHost || '0.0.0.0'

    // Fix: if port 8080 is taken, use a fallback
    const { createServer } = await import('net')
    const isPortFree = (p: number): Promise<boolean> =>
      new Promise(resolve => {
        const s = createServer().listen(p, '0.0.0.0', () => { s.close(); resolve(true) })
        s.on('error', () => resolve(false))
      })

    if (!(await isPortFree(port))) {
      console.warn(`[Headless] Port ${port} is in use, trying port 6011`)
      port = 6011
    }

    const proxyServer = new ProxyServer()
    const success = await proxyServer.start(port, host)

    if (success) {
      console.log(`[Headless] Chat2API proxy started on ${host}:${port}`)
    } else {
      console.error('[Headless] Failed to start proxy server')
      app.quit()
    }
  } catch (err) {
    console.error('[Headless] Error:', err)
    app.quit()
  }
}

app.whenReady().then(startHeadless)

app.on('window-all-closed', () => {})
