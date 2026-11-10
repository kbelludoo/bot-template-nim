import std/[times]

type
  StaminaType* = enum
    stDecreasing,        # 42h -> 0h (Tibia, Huntera)
    stIncreasingFatigue  # 0% -> 100% (Leveling, Protobuf)

  StaminaConfig* = object
    staminaType*: StaminaType
    maxFatiguePercent*: float    # ex: 80.0%
    resumeFatiguePercent*: float # ex: 30.0%
    minStaminaHours*: float      # ex: 14.0h
    resumeStaminaHours*: float   # ex: 38.0h
    minRestDurationSec*: float   # ex: 300s (5 minutos de histerese mínima)

  StaminaController* = ref object
    cfg*: StaminaConfig
    isResting*: bool
    restStartTime*: float
    fatiguePercent*: float
    staminaHours*: float

proc defaultStaminaConfig*(): StaminaConfig =
  result.staminaType = stIncreasingFatigue
  result.maxFatiguePercent = 80.0
  result.resumeFatiguePercent = 30.0
  result.minStaminaHours = 14.0
  result.resumeStaminaHours = 38.0
  result.minRestDurationSec = 300.0

proc newStaminaController*(cfg: StaminaConfig): StaminaController =
  result = StaminaController(
    cfg: cfg,
    isResting: false,
    restStartTime: 0.0,
    fatiguePercent: 0.0,
    staminaHours: 42.0
  )

proc updateFatigue*(c: StaminaController, fatiguePct: float) =
  c.fatiguePercent = fatiguePct

proc updateStaminaHours*(c: StaminaController, hours: float) =
  c.staminaHours = hours

proc shouldHunt*(c: StaminaController): bool =
  let now = epochTime()

  case c.cfg.staminaType
  of stIncreasingFatigue:
    if c.isResting:
      # Respeita o tempo mínimo de histerese anti-thrashing
      if (now - c.restStartTime) < c.cfg.minRestDurationSec:
        return false
      if c.fatiguePercent <= c.cfg.resumeFatiguePercent:
        c.isResting = false
        return true
      return false
    else:
      if c.fatiguePercent >= c.cfg.maxFatiguePercent:
        c.isResting = true
        c.restStartTime = now
        return false
      return true

  of stDecreasing:
    if c.isResting:
      if (now - c.restStartTime) < c.cfg.minRestDurationSec:
        return false
      if c.staminaHours >= c.cfg.resumeStaminaHours:
        c.isResting = false
        return true
      return false
    else:
      if c.staminaHours <= c.cfg.minStaminaHours:
        c.isResting = true
        c.restStartTime = now
        return false
      return true
