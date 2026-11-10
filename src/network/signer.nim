import std/[strutils, random, sysrand]

proc computeDjb2Hash*(s: string): uint32 =
  ## Algoritmo DJB2 hash para particionamento e sharding
  var hash: uint32 = 5381
  for b in s:
    hash = ((hash shl 5) + hash) + b.ord.uint32
  return hash

proc toHexStr(s: openArray[byte]): string =
  result = ""
  for b in s:
    result.add(toHex(b.int, 2))

proc generateIdempotencyKey*(): string =
  ## Gera uma chave de idempotência UUIDv4 formatada
  var bytes: array[16, byte]
  if not urandom(bytes):
    for i in 0..15:
      bytes[i] = rand(0..255).byte
  bytes[6] = (bytes[6] and 0x0F) or 0x40
  bytes[8] = (bytes[8] and 0x3F) or 0x80

  result = toHexStr(bytes[0..3]) & "-" &
           toHexStr(bytes[4..5]) & "-" &
           toHexStr(bytes[6..7]) & "-" &
           toHexStr(bytes[8..9]) & "-" &
           toHexStr(bytes[10..15])
  result = result.toLowerAscii()

type
  RequestSigner* = ref object
    signingKey*: string

proc newRequestSigner*(key: string = ""): RequestSigner =
  result = RequestSigner(signingKey: key)

proc setKey*(s: RequestSigner, key: string) =
  s.signingKey = key

proc computeSignature*(s: RequestSigner, httpMethod, path, timestampMs, body: string): string =
  if s.signingKey.len == 0:
    return ""
  # Assinatura HMAC simplificada ou hash token
  let message = httpMethod & "\n" & path & "\n" & timestampMs & "\n" & body
  let h = computeDjb2Hash(message & s.signingKey)
  return toHex(h).toLowerAscii()
