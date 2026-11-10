import std/[json, strutils]

proc formatTrpcBatchInput*(input: JsonNode): string =
  ## Formata o payload no formato tRPC v10 Batch {"0":{"json":...}}
  let envelope = %*{
    "0": {
      "json": input
    }
  }
  result = $envelope

proc unwrapTrpcBatchResponse*(body: string): JsonNode =
  ## Desenvelopa a resposta tRPC v10 [{"result":{"data":{"json":...}}}]
  let parsed = parseJson(body)
  if parsed.kind != JArray or parsed.len == 0:
    raise newException(CatchableError, "Resposta tRPC batch não é array ou está vazia")

  let first = parsed[0]
  if first.hasKey("error"):
    let err = first["error"]
    let code = err{"json"}{"code"}.getInt(500)
    let msg = err{"json"}{"message"}.getStr("erro desconhecido")
    raise newException(CatchableError, "Erro tRPC (" & $code & "): " & msg)

  if not first.hasKey("result") or not first["result"].hasKey("data"):
    raise newException(CatchableError, "Payload tRPC sem data.json")

  result = first["result"]["data"]{"json"}
