import std/[times, options]

type
  DailyManager* = ref object
    lastClaimDate*: Option[string]

proc newDailyManager*(): DailyManager =
  result = DailyManager(lastClaimDate: none(string))

proc shouldClaimDaily*(m: DailyManager): bool =
  let today = now().utc().format("yyyy-MM-dd")
  if m.lastClaimDate.isNone():
    return true
  return m.lastClaimDate.get() != today

proc recordClaim*(m: DailyManager) =
  let today = now().utc().format("yyyy-MM-dd")
  m.lastClaimDate = some(today)
