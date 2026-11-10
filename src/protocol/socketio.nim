import std/[strutils, options]

type
  SocketIoPacket* = object
    engineType*: int
    socketType*: Option[int]
    namespace*: string
    payload*: string

proc parseSocketIoPacket*(raw: string): Option[SocketIoPacket] =
  if raw.len == 0:
    return none(SocketIoPacket)

  var pkt: SocketIoPacket
  pkt.engineType = parseInt($raw[0])
  pkt.namespace = "/"

  var rest = raw[1..^1]
  if pkt.engineType == 4 and rest.len > 0 and rest[0].isDigit:
    pkt.socketType = some(parseInt($rest[0]))
    rest = rest[1..^1]
  else:
    pkt.socketType = none(int)

  pkt.payload = rest
  return some(pkt)
