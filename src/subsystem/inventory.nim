import std/[sets]

type
  InventoryManager* = ref object
    protectedItems*: HashSet[string]
    maxSlots*: int

proc newInventoryManager*(maxSlots = 50): InventoryManager =
  var protected = initHashSet[string]()
  protected.incl("potion_hp")
  protected.incl("potion_mana")
  protected.incl("superball")
  result = InventoryManager(protectedItems: protected, maxSlots: maxSlots)

proc isProtected*(inv: InventoryManager, itemId: string): bool =
  return inv.protectedItems.contains(itemId)

proc shouldSellTrash*(inv: InventoryManager, occupiedSlots: int): bool =
  if inv.maxSlots == 0: return false
  return (occupiedSlots.float / inv.maxSlots.float) >= 0.80
