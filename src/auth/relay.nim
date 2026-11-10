import std/[os, strutils, osproc, times]

var lastSolverKick: float = 0.0

proc extrairUltimaTunnelUrl*(logPath: string): string =
  if not fileExists(logPath):
    return ""

  try:
    let content = readFile(logPath)
    for line in content.splitLines():
      let idx = line.find("https://")
      if idx >= 0:
        let sub = line[idx..^1]
        let endIdx = sub.find(".trycloudflare.com")
        if endIdx >= 0:
          result = sub[0 .. endIdx + ".trycloudflare.com".len - 1]
  except CatchableError:
    return ""

proc dispararSolverActions*(repo, workflowFile, tunnelLogPath, logId: string, cooldownSec = 45.0): bool =
  let now = epochTime()
  if (now - lastSolverKick) < cooldownSec:
    echo "⏳ Cooldown ativo para solver (", int(cooldownSec - (now - lastSolverKick)), "s restantes)"
    return false

  let tunnelUrl = extrairUltimaTunnelUrl(tunnelLogPath)
  if tunnelUrl.len == 0:
    echo "⚠️ [", logId, "] Nenhuma tunnel URL encontrada em: ", tunnelLogPath
    return false

  lastSolverKick = now
  echo "🚀 Disparando solver via gh workflow run em ", repo, " com URL: ", tunnelUrl
  let cmd = "gh workflow run " & workflowFile & " --repo " & repo & " -f tunnel_url=" & tunnelUrl
  let exitCode = execCmd(cmd)
  return exitCode == 0
