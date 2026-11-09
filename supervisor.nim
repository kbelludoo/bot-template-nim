import std/[asyncdispatch, strutils]
import config, circuit_breaker, pacing, telemetry

type
  Supervisor* = ref object
    accounts*: seq[AccountConfig]
    state*: TelemetryState

proc newSupervisor*(accounts: seq[AccountConfig], state: TelemetryState): Supervisor =
  result = Supervisor(accounts: accounts, state: state)

proc runAccountLoop*(acc: AccountConfig, tAcc: AccountTelemetry, cb: CircuitBreaker) {.async.} =
  echo "🚀 [Bot] Iniciando conta: ", acc.name, " (", acc.id, ")"
  tAcc.addLog("Conta iniciada com supervisor Nim.")

  var tick = 0
  while true:
    if not cb.canExecute():
      tAcc.status = "circuit_open"
      await sleepAsync(5000)
      continue

    try:
      tAcc.status = "hunting"
      tick.inc()

      # Organic Action Pacing
      await paceAction(2000)

      # Simulate game progression
      tAcc.kills.inc()
      tAcc.gold.inc(25)
      tAcc.exp.inc(150)

      if tick mod 10 == 0:
        tAcc.level = 1 + (tAcc.exp div 1500).int
        tAcc.addLog("Nível atualizado para: " & $tAcc.level)

      cb.recordSuccess()
    except CatchableError as e:
      echo "⚠️ [Bot] Erro na conta ", acc.id, ": ", e.msg
      tAcc.addLog("Erro: " & e.msg)
      cb.recordFailure()
      await sleepAsync(3000)

proc start*(sup: Supervisor) =
  for acc in sup.accounts:
    if not acc.enabled:
      continue
    let tAcc = newAccountTelemetry(acc.id, acc.name)
    sup.state.accounts.add(tAcc)
    let cb = newCircuitBreaker(acc.id)
    asyncCheck runAccountLoop(acc, tAcc, cb)
