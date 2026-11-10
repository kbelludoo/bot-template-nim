import std/[times]

type
  WorldBossEvent* = object
    id*: string
    name*: string
    spawnTime*: float
    minLevel*: int
    portalId*: string
    isOpen*: bool
    alreadyDone*: bool

  BossScheduler* = ref object
    bosses*: seq[WorldBossEvent]

proc newBossScheduler*(): BossScheduler =
  result = BossScheduler(bosses: @[])

proc addBoss*(s: BossScheduler, boss: WorldBossEvent) =
  s.bosses.add(boss)

proc getReadyBosses*(s: BossScheduler, characterLevel: int): seq[WorldBossEvent] =
  let nowTime = epochTime()
  result = @[]
  for b in s.bosses:
    if b.alreadyDone or characterLevel < b.minLevel:
      continue
    let diffMinutes = (nowTime - b.spawnTime) / 60.0
    if b.isOpen or (nowTime >= b.spawnTime and diffMinutes < 10.0):
      result.add(b)

proc markCompleted*(s: BossScheduler, bossId: string) =
  for b in s.bosses.mitems:
    if b.id == bossId:
      b.alreadyDone = true
