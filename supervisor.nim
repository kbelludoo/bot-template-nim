import std/[asyncdispatch, strutils, times, math, random]
import config, circuit_breaker, pacing, telemetry

type
  Supervisor* = ref object
    accounts*: seq[AccountConfig]
    state*: TelemetryState

proc newSupervisor*(accounts: seq[AccountConfig], state: TelemetryState): Supervisor =
  result = Supervisor(accounts: accounts, state: state)

proc runAccountLoop*(acc: AccountConfig, tAcc: AccountTelemetry, cb: CircuitBreaker) {.async.} =
  echo "🚀 [Bot] Loop da conta iniciado: ", acc.name, " (", acc.id, ")"
  tAcc.addLog("Loop da conta iniciado com sucesso.")
  tAcc.running = true

  var tick = 0
  while true:
    # Heartbeat vital para detecção de watchdog
    tAcc.lastHeartbeat = epochTime()

    if not cb.canExecute():
      tAcc.status = "circuit_open"
      await sleepAsync(5000)
      continue

    try:
      tAcc.status = "hunting"
      tick.inc()

      # Organic Action Pacing
      await paceAction(2000)

      # Simulação de ciclo de jogo
      tAcc.kills.inc()
      tAcc.gold.inc(25)
      tAcc.exp.inc(150)

      if tick mod 10 == 0:
        tAcc.level = 1 + (tAcc.exp div 1500).int
        tAcc.addLog("Nível atualizado para: " & $tAcc.level)

      cb.recordSuccess()
    except CatchableError as e:
      echo "⚠️ [Bot] Erro transitório na conta ", acc.id, ": ", e.msg
      tAcc.addLog("Erro transitório: " & e.msg)
      cb.recordFailure()
      await sleepAsync(3000)

proc superviseAccount*(acc: AccountConfig, tAcc: AccountTelemetry, cb: CircuitBreaker) {.async.} =
  ## Rotina de supervisão com Auto-Recovery estilo Erlang (Worker Supervisor)
  while true:
    try:
      await runAccountLoop(acc, tAcc, cb)
    except CatchableError as e:
      tAcc.restarts.inc()
      cb.recordFailure()

      # Exponential Backoff com Jitter (3s, 6s, 12s, 24s... até 60s max)
      let exponent = min(tAcc.restarts, 5).float
      let baseBackoff = min(60.0, 3.0 * pow(2.0, exponent - 1.0))
      let jitter = rand(0.5..2.5)
      let backoffSec = baseBackoff + jitter
      let backoffMs = int(backoffSec * 1000)

      tAcc.status = "recovering"
      let msg = "🚨 Falha crítica no worker (" & e.msg & "). Auto-recovery em " &
                formatFloat(backoffSec, ffDecimal, 1) & "s (Reinício #" & $tAcc.restarts & ")"
      echo "🔄 [Auto-Recovery] ", acc.id, ": ", msg
      tAcc.addLog(msg)

      await sleepAsync(backoffMs)
    except Exception as fatal:
      # Previne que qualquer Defect não capturado finalize a task
      tAcc.restarts.inc()
      echo "💥 [Auto-Recovery FATAL] Conta ", acc.id, ": ", fatal.msg
      tAcc.status = "recovering"
      tAcc.addLog("Exceção fatal: " & fatal.msg & ". Reiniciando em 15s...")
      await sleepAsync(15_000)

proc runWatchdog*(sup: Supervisor, timeoutSec: float = 45.0) {.async.} =
  ## Monitor de travamentos e stalls de I/O em tarefas assíncronas
  echo "🛡️  [Watchdog] Monitor de resiliência ativo (limiar: ", int(timeoutSec), "s)."
  while true:
    await sleepAsync(10_000)
    let now = epochTime()

    for tAcc in sup.state.accounts:
      if not tAcc.running:
        continue

      # Se estiver em circuito aberto ou em recuperação programada, não considera travado
      if tAcc.status in ["circuit_open", "recovering", "idle"]:
        continue

      let silenceSec = now - tAcc.lastHeartbeat
      if silenceSec > timeoutSec:
        echo "⚠️  [Watchdog] ALERTA: Conta '", tAcc.id, "' está sem responder há ", int(silenceSec), "s!"
        tAcc.status = "stalled"
        tAcc.addLog("Watchdog: travamento detectado (" & $int(silenceSec) & "s sem resposta).")

proc start*(sup: Supervisor) =
  randomize()

  for acc in sup.accounts:
    if not acc.enabled:
      continue
    let tAcc = newAccountTelemetry(acc.id, acc.name)
    sup.state.accounts.add(tAcc)
    let cb = newCircuitBreaker(acc.id)

    # Inicia a task de supervisão resiliente com auto-recovery
    asyncCheck superviseAccount(acc, tAcc, cb)

  # Inicia o Watchdog global
  asyncCheck runWatchdog(sup)
