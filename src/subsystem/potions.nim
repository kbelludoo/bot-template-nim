type
  PotionManager* = ref object
    minHpRatio*: float

proc newPotionManager*(minHpRatio = 0.50): PotionManager =
  result = PotionManager(minHpRatio: minHpRatio)

proc shouldDrinkHpPotion*(p: PotionManager, currentHp, maxHp: int): bool =
  if maxHp == 0: return false
  return (currentHp.float / maxHp.float) <= p.minHpRatio
