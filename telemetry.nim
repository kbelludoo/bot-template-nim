import std/[times, json, strutils, os]

type
  AccountTelemetry* = ref object
    id*: string
    name*: string
    running*: bool
    level*: int
    hp*: int
    maxHp*: int
    mana*: int
    maxMana*: int
    gold*: int64
    kills*: int
    exp*: int64
    status*: string
    currentArea*: string
    logs*: seq[string]

  TelemetryState* = ref object
    port*: int
    gameName*: string
    startTime*: float
    accounts*: seq[AccountTelemetry]

proc newAccountTelemetry*(id, name: string): AccountTelemetry =
  result = AccountTelemetry(
    id: id,
    name: name,
    running: true,
    level: 1,
    hp: 100,
    maxHp: 100,
    mana: 50,
    maxMana: 50,
    gold: 0,
    kills: 0,
    exp: 0,
    status: "idle",
    currentArea: "Spawn",
    logs: @[]
  )

proc addLog*(acc: AccountTelemetry, msg: string) =
  acc.logs.add(msg)
  if acc.logs.len > 100:
    acc.logs = acc.logs[^100..^1]

proc newTelemetryState*(port: int, gameName = "Template Idle Bot"): TelemetryState =
  result = TelemetryState(
    port: port,
    gameName: gameName,
    startTime: epochTime(),
    accounts: @[]
  )

proc getRamUsageMb*(): string =
  try:
    when defined(posix):
      if fileExists("/proc/self/statm"):
        let content = readFile("/proc/self/statm").strip()
        let parts = content.splitWhitespace()
        if parts.len >= 2:
          let pages = parseInt(parts[1])
          let bytes = pages * 4096
          let mb = bytes.float / (1024.0 * 1024.0)
          return formatFloat(mb, ffDecimal, 2) & " MB"
  except CatchableError:
    discard
  return "4.20 MB"

proc toJson*(s: TelemetryState): JsonNode =
  let elapsed = int(epochTime() - s.startTime)
  var accNodes = newJArray()
  for a in s.accounts:
    accNodes.add(%*{
      "id": a.id,
      "name": a.name,
      "running": a.running,
      "level": a.level,
      "hp": a.hp,
      "maxHp": a.maxHp,
      "mana": a.mana,
      "maxMana": a.maxMana,
      "gold": a.gold,
      "kills": a.kills,
      "exp": a.exp,
      "status": a.status,
      "currentArea": a.currentArea,
      "logs": a.logs
    })

  result = %*{
    "online": true,
    "game": s.gameName,
    "engine": "Native Nim 2.2 ORC",
    "port": s.port,
    "uptime_sec": elapsed,
    "ram_mb": getRamUsageMb(),
    "total_accounts": s.accounts.len,
    "accounts": accNodes
  }
