import std/[os, asyncdispatch, strutils, exitprocs]
import config, telemetry, supervisor, server
import src/lib

proc main() =
  echo "================================================================================"
  echo "       ⚡ NIM BOT TEMPLATE (NATIVE ZERO-GC & ALTA PERFORMANCE) ⚡              "
  echo "  Multi-Conta Assíncrono • Pacing Orgânico • Circuit Breaker • Auto-Recovery    "
  echo "  Sub-sistemas: Stamina • Overlay • tRPC • Colyseus • Protobuf • RouteSolver   "
  echo "================================================================================"

  addExitProc(proc() =
    echo "\n🛑 [Shutdown] Finalizando processos do bot com segurança."
  )

  var configPath = "accounts.json"
  var i = 1
  while i <= paramCount():
    let arg = paramStr(i)
    if (arg == "-config" or arg == "--config") and i + 1 <= paramCount():
      configPath = paramStr(i + 1)
      i += 2
    else:
      i += 1

  var accounts = loadAccounts(configPath)
  if accounts.len == 0:
    echo "⚠️ Nenhuma conta encontrada em '", configPath, "'. Carregando os 18 bots da suíte Nim para demonstração."
    accounts = defaultSuiteAccounts()

  # Exemplo de inicialização dos subsistemas de paridade
  let stamina = newStaminaController(defaultStaminaConfig())
  let overlay = newStateOverlay()
  let stealth = newStealthEngine()
  let daily = newDailyManager()
  let inventory = newInventoryManager(50)

  echo "🧩 [Subsistemas Ativos] Stamina, Overlay, Stealth, Daily, Inventory e RouteSolver prontos."

  let portStr = getEnv("PORT", "3099")
  let port = try: parseInt(portStr) except CatchableError: 3099

  let state = newTelemetryState(port, "Nim Bot Template Engine")

  # 1. Start Supervisor
  let sup = newSupervisor(accounts, state)
  sup.start()

  # 2. Start HTTP Telemetry Server
  asyncCheck runServer(state, port)

  runForever()

when isMainModule:
  main()
