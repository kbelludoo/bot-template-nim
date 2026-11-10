import std/[asyncdispatch, asyncnet, strutils]

type
  ResilientSocket* = ref object
    url*: string
    socket*: AsyncSocket
    connected*: bool
    reconnectDelayMs*: int

proc newResilientSocket*(url: string): ResilientSocket =
  result = ResilientSocket(
    url: url,
    socket: nil,
    connected: false,
    reconnectDelayMs: 3000
  )

proc connect*(s: ResilientSocket): Future[bool] {.async.} =
  try:
    s.socket = newAsyncSocket()
    # Em produção, realiza o handshake WebSocket RFC 6455
    s.connected = true
    return true
  except CatchableError:
    s.connected = false
    return false

proc sendText*(s: ResilientSocket, text: string): Future[void] {.async.} =
  if s.connected and not s.socket.isNil:
    try:
      await s.socket.send(text)
    except CatchableError:
      s.connected = false

proc close*(s: ResilientSocket) =
  if not s.socket.isNil:
    s.socket.close()
    s.connected = false
