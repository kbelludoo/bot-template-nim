import std/[json, tables, strutils]

type
  StateOverlay* = ref object
    rawPayload*: Table[string, JsonNode]

proc newStateOverlay*(): StateOverlay =
  result = StateOverlay(rawPayload: initTable[string, JsonNode]())

proc ingest*(o: StateOverlay, jsonBytes: string) =
  try:
    let j = parseJson(jsonBytes)
    if j.kind == JObject:
      for k, v in j.pairs:
        o.rawPayload[k] = v
  except CatchableError:
    discard

proc set*(o: StateOverlay, key: string, val: JsonNode) =
  o.rawPayload[key] = val

proc get*(o: StateOverlay, key: string): JsonNode =
  if o.rawPayload.hasKey(key):
    return o.rawPayload[key]
  return newJNull()

proc exportJson*(o: StateOverlay): string =
  var obj = newJObject()
  for k, v in o.rawPayload.pairs:
    obj[k] = v
  return $obj
