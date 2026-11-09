import std/[asynchttpserver, asyncdispatch, json, strutils]
import telemetry

const IndexHtml = """<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>Nim Bot Template - Command Center</title>
    <style>
        body { background: #0b0f17; color: #f0f6fc; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', monospace; padding: 20px; }
        .card { background: #161b22; border: 1px solid #30363d; border-radius: 8px; padding: 18px; margin-bottom: 14px; max-width: 900px; margin-left: auto; margin-right: auto; }
        .tag { background: #238636; color: white; padding: 3px 10px; border-radius: 12px; font-weight: bold; font-size: 13px; }
        pre { background: #010409; padding: 12px; border-radius: 6px; overflow-x: auto; color: #58a6ff; font-size: 12px; }
    </style>
</head>
<body>
    <div class="card">
        <h2>⚡ Nim Bot Template <span class="tag">ONLINE</span></h2>
        <p>100% Native Nim 2.2 • Zero-GC ORC Model • High Performance Engine</p>
        <div id="stats">Carregando telemetria...</div>
        <h3>Status JSON (/api/status)</h3>
        <pre id="raw">...</pre>
    </div>
    <script>
        async function update() {
            try {
                const res = await fetch('/api/status');
                const data = await res.json();
                document.getElementById('raw').innerText = JSON.stringify(data, null, 2);
                document.getElementById('stats').innerHTML = `
                    <b>Uptime:</b> ${data.uptime_sec}s | <b>RAM:</b> ${data.ram_mb}<br>
                    <b>Contas Ativas:</b> ${data.total_accounts}
                `;
            } catch (e) {}
        }
        setInterval(update, 3000);
        update();
    </script>
</body>
</html>"""

proc runServer*(state: TelemetryState, port: int) {.async.} =
  var server = newAsyncHttpServer()

  proc cb(req: Request) {.async, gcsafe.} =
    let path = req.url.path
    var headers = newHttpHeaders([
      ("Access-Control-Allow-Origin", "*"),
      ("Access-Control-Allow-Methods", "GET, POST, OPTIONS"),
      ("Access-Control-Allow-Headers", "Content-Type, Authorization")
    ])

    if req.reqMethod == HttpOptions:
      await req.respond(Http200, "", headers)
      return

    if path == "/api/status" or path == "/status.json":
      headers.add("Content-Type", "application/json; charset=utf-8")
      let body = $state.toJson()
      await req.respond(Http200, body, headers)
    elif path == "/" or path == "":
      headers.add("Content-Type", "text/html; charset=utf-8")
      await req.respond(Http200, IndexHtml, headers)
    else:
      await req.respond(Http404, "Not Found", headers)

  echo "🌐 [Web Server] Dashboard online em http://0.0.0.0:", port
  await server.serve(Port(port), cb, "0.0.0.0")
