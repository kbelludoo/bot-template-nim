import std/[random, asyncdispatch]

proc applyJitter*(baseMs: int, jitterPercent = 0.20): int =
  let variance = int(baseMs.float * jitterPercent)
  if variance <= 0: return baseMs
  let delta = rand(-variance .. variance)
  return max(50, baseMs + delta)

proc paceClick*(minMs = 350, maxMs = 650): Future[void] {.async.} =
  let delay = rand(minMs .. maxMs)
  await sleepAsync(delay)

proc paceAction*(baseMs: int): Future[void] {.async.} =
  let delay = applyJitter(baseMs)
  await sleepAsync(delay)
