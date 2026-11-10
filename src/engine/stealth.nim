import std/[random, httpclient, asyncdispatch]

type
  StealthConfig* = object
    enabled*: bool
    minActionDelayMs*: int # Delay entre cliques consecutivos (ex: 300ms)
    maxActionDelayMs*: int # Delay máximo entre cliques consecutivos (ex: 600ms)
    jitterVariance*: float # Variação orgânica no timer (ex: 0.20 = ±20%)

  StealthEngine* = ref object
    config*: StealthConfig

proc defaultStealthConfig*(): StealthConfig =
  result.enabled = true
  result.minActionDelayMs = 300
  result.maxActionDelayMs = 600
  result.jitterVariance = 0.20

proc newStealthEngine*(cfg: StealthConfig = defaultStealthConfig()): StealthEngine =
  result = StealthEngine(config: cfg)

proc jitterDelayMs*(e: StealthEngine, baseMs: int): int =
  if not e.config.enabled or e.config.jitterVariance <= 0.0:
    return baseMs
  let factor = 1.0 + rand(-e.config.jitterVariance..e.config.jitterVariance)
  result = max(50, int(baseMs.float * factor))

proc humanActionDelayMs*(e: StealthEngine): int =
  if not e.config.enabled:
    return 50
  result = rand(e.config.minActionDelayMs..e.config.maxActionDelayMs)

proc pacingStep*(e: StealthEngine) {.async.} =
  let delay = e.humanActionDelayMs()
  await sleepAsync(delay)

proc applyBrowserHeaders*(e: StealthEngine, client: var HttpClient or var AsyncHttpClient) =
  client.headers = newHttpHeaders([
    ("User-Agent", "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36"),
    ("Sec-Ch-Ua", "\"Google Chrome\";v=\"131\", \"Chromium\";v=\"131\", \"Not_A Brand\";v=\"24\""),
    ("Sec-Ch-Ua-Mobile", "?0"),
    ("Sec-Ch-Ua-Platform", "\"Windows\""),
    ("Sec-Fetch-Dest", "empty"),
    ("Sec-Fetch-Mode", "cors"),
    ("Sec-Fetch-Site", "same-origin"),
    ("Accept-Language", "pt-BR,pt;q=0.9,en-US;q=0.8,en;q=0.7")
  ])
