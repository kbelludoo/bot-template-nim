import std/[options]

type
  PromotionTier* = object
    levelReq*: int
    costGold*: int64
    targetName*: string
    actionCode*: string

  BlessingConfig* = object
    maxBlessings*: int
    costPerBless*: int64

  PromotionManager* = ref object
    tiers*: seq[PromotionTier]
    blessCfg*: BlessingConfig
    isPromoted*: bool
    currentBlessings*: int

proc newPromotionManager*(tiers: seq[PromotionTier], blessCfg: BlessingConfig): PromotionManager =
  result = PromotionManager(
    tiers: tiers,
    blessCfg: blessCfg,
    isPromoted: false,
    currentBlessings: 0
  )

proc checkEligiblePromotion*(m: PromotionManager, currentLevel: int, currentGold: int64, currentTitle: string): Option[PromotionTier] =
  for tier in m.tiers:
    if currentLevel >= tier.levelReq and currentGold >= tier.costGold and currentTitle != tier.targetName:
      return some(tier)
  return none(PromotionTier)

proc missingBlessings*(m: PromotionManager, activeBlessCount: int): int =
  if activeBlessCount < m.blessCfg.maxBlessings:
    return m.blessCfg.maxBlessings - activeBlessCount
  return 0
