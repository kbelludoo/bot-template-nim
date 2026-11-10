const
  ColyseusOpHandshake* = 9'u8
  ColyseusOpJoinRoom* = 10'u8
  ColyseusOpError* = 11'u8
  ColyseusOpLeaveRoom* = 12'u8
  ColyseusOpRoomData* = 13'u8
  ColyseusOpRoomState* = 14'u8
  ColyseusOpRoomStatePatch* = 15'u8
  ColyseusOpPing* = 18'u8
  ColyseusOpPong* = 19'u8

proc parseColyseusJoinRoom*(frame: openArray[byte]): tuple[reconnectionToken: string, serializerId: string, ackFrame: seq[byte]] =
  if frame.len < 2 or frame[0] != ColyseusOpJoinRoom:
    raise newException(CatchableError, "frame inválido para OpJoinRoom")

  var offset = 1
  let tokenLen = frame[offset].int
  offset += 1

  if offset + tokenLen > frame.len:
    raise newException(CatchableError, "buffer too short")

  var tokenChars = newString(tokenLen)
  for i in 0..<tokenLen:
    tokenChars[i] = frame[offset + i].char
  offset += tokenLen

  var serializerId = ""
  if offset < frame.len:
    let serLen = frame[offset].int
    offset += 1
    if offset + serLen <= frame.len:
      var sChars = newString(serLen)
      for i in 0..<serLen:
        sChars[i] = frame[offset + i].char
      serializerId = sChars

  return (tokenChars, serializerId, @[ColyseusOpJoinRoom])

proc encodeColyseusRoomData*(msgType: string, msgpackPayload: openArray[byte]): seq[byte] =
  result = @[]
  if msgType.len <= 31:
    result.add(ColyseusOpRoomData)
    result.add((0xa0 or msgType.len).byte)
  else:
    result.add(ColyseusOpRoomData)
    result.add(0xd9'u8)
    result.add(msgType.len.byte)

  for c in msgType:
    result.add(c.byte)

  for b in msgpackPayload:
    result.add(b)
