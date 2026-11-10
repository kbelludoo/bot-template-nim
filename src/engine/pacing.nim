import std/[asyncdispatch, random]

proc paceAction*(baseMs: int, variance = 0.20) {.async.} =
  let minF = 1.0 - variance
  let maxF = 1.0 + variance
  let factor = rand(minF..maxF)
  let delay = int(baseMs.float * factor)

  # Adiciona atraso humano orgânico (300ms a 650ms)
  let humanDelay = rand(300..650)
  await sleepAsync(delay + humanDelay)
