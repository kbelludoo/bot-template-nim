import std/[tables, times]

type
  PartyMember* = object
    id*: string
    name*: string
    role*: string # "tank", "dps", "healer"
    level*: int
    lastSeen*: float

  PartyCoordinator* = ref object
    partyId*: string
    leaderId*: string
    members*: Table[string, PartyMember]
    soloKillRate*: float
    bonusExpRate*: float

proc newPartyCoordinator*(partyId, leaderId: string, soloRate = 40.0, bonusExp = 0.45): PartyCoordinator =
  result = PartyCoordinator(
    partyId: partyId,
    leaderId: leaderId,
    members: initTable[string, PartyMember](),
    soloKillRate: (if soloRate <= 0.0: 40.0 else: soloRate),
    bonusExpRate: (if bonusExp <= 0.0: 0.45 else: bonusExp)
  )

proc registerMember*(p: PartyCoordinator, member: PartyMember) =
  var m = member
  m.lastSeen = epochTime()
  p.members[m.id] = m

proc removeMember*(p: PartyCoordinator, memberId: string) =
  p.members.del(memberId)

proc isLeader*(p: PartyCoordinator, memberId: string): bool =
  return p.leaderId == memberId
