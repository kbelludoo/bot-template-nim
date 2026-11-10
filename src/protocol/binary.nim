type
  WireType* = enum
    wtVarint = 0,
    wtFixed64 = 1,
    wtLengthDelimited = 2,
    wtFixed32 = 5

  ProtocolError* = object of CatchableError

proc decodeVarint*(buf: openArray[byte]): tuple[val: uint64, bytesRead: int] =
  var val: uint64 = 0
  var shift: int = 0

  for i, b in buf:
    if i >= 10:
      raise newException(ProtocolError, "Varint overflow (> 64 bits)")
    val = val or ((b.uint64 and 0x7F'u64) shl shift)
    if (b and 0x80'u8) == 0:
      return (val, i + 1)
    shift += 7

  raise newException(ProtocolError, "Buffer too short")

proc decodeZigzag*(n: uint64): int64 =
  result = (n shr 1).int64 xor (-((n and 1).int64))

proc decodeTag*(buf: openArray[byte]): tuple[fieldNumber: uint32, wireType: byte, bytesRead: int] =
  let (v, n) = decodeVarint(buf)
  let wt = (v and 0x07).byte
  let fn = (v shr 3).uint32
  return (fn, wt, n)
