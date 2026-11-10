import std/[asynchttpserver, asyncdispatch, json, strutils]
import ../../telemetry

proc runDashboardServer*(state: TelemetryState, port: int) {.async.} =
  var server = newAsyncHttpServer()

  proc cb(req: Request) {.async, gcsafe.} =
    var headers = newHttpHeaders([
      ("Access-Control-Allow-Origin", "*"),
      ("Content-Type", "application/json; charset=utf-8")
    ])

    if req.url.path == "/api/status" or req.url.path == "/status.json":
      let body = $state.toJson()
      await req.respond(Http200, body, headers)
    else:
      headers["Content-Type"] = "text/html; charset=utf-8"
      let html = """<!DOCTYPE html><html><head><meta charset="utf-8"><title>Bot Template Dashboard</title></head>
      <body style="background:#090d16; color:#f0f6fc; font-family:monospace; padding:30px;">
        <h2>⚡ BOT TEMPLATE DASHBOARD (NIM NATIVO ZERO-GC)</h2>
        <p>Motor: <b>Nim 2.2 ORC</b></p>
        <p>API Status: <a href="/api/status" style="color:#38bdf8;">/api/status</a></p>
      </body></html>"""
      await req.respond(Http200, html, headers)

  echo "🌐 [Dashboard Server] Online em http://0.0.0.0:", port
  await server.serve(Port(port), cb, "0.0.0.0")
