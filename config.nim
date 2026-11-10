import std/[os, json]

type
  CredentialsConfig* = object
    email*: string
    password*: string
    token*: string
    sessionCookie*: string
    origin*: string

  SettingsConfig* = object
    huntTarget*: string
    autoHunt*: bool
    autoSell*: bool
    autoHeal*: bool
    autoUpgrade*: bool
    autoDaily*: bool
    autoChests*: bool
    autoParty*: bool
    partyLeader*: string
    killRate*: float

  AccountConfig* = object
    id*: string
    name*: string
    enabled*: bool
    bindIP*: string
    proxy*: string
    credentials*: CredentialsConfig
    settings*: SettingsConfig

proc defaultAccount*(id, name: string): AccountConfig =
  result.id = id
  result.name = name
  result.enabled = true
  result.settings.autoHunt = true
  result.settings.autoSell = true
  result.settings.autoHeal = true
  result.settings.autoUpgrade = true
  result.settings.autoDaily = true
  result.settings.autoChests = true
  result.settings.autoParty = true
  result.settings.killRate = 1.0

proc defaultSuiteAccounts*(): seq[AccountConfig] =
  const suite = [
    ("bot-baiak-nim", "Baiak Idle MMORPG"),
    ("bot-farmbot-nim", "Farm Bot Automation"),
    ("bot-huntera-nim", "Huntera Idle Engine"),
    ("bot-kickminer-nim", "Kick Miner Drops"),
    ("bot-leveling-nim", "Leveling Optimizer"),
    ("bot-lichess-nim", "Lichess Chess Engine"),
    ("bot-lolidle-nim", "LoL Idle Battle"),
    ("bot-luxidle-nim", "Lux Idle Automation"),
    ("bot-pokeidle-nim", "PokeIdle Auto-Catch"),
    ("bot-pokeidleworld-nim", "PokeIdle World"),
    ("bot-pokelegacy-nim", "PokeLegacy Engine"),
    ("bot-pokepixel-nim", "PokePixel Runner"),
    ("bot-poketrue-nim", "PokeTrue Battler"),
    ("bot-restream-nim", "Restream Multi-Stream"),
    ("bot-sigma-nim", "Sigma Engine Worker"),
    ("bot-template-nim", "Template Master Engine"),
    ("bot-tibiaidle-nim", "Tibia Idle MMORPG"),
    ("bot-twitchminer-nim", "Twitch Channel Miner")
  ]
  result = @[]
  for item in suite:
    result.add(defaultAccount(item[0], item[1]))

proc loadAccounts*(path: string): seq[AccountConfig] =
  result = @[]
  if fileExists(path):
    try:
      let txt = readFile(path)
      let j = parseJson(txt)
      if j.kind == JArray:
        for item in j:
          var acc = defaultAccount(item{"id"}.getStr("acc-1"), item{"name"}.getStr("Player"))
          acc.enabled = item{"enabled"}.getBool(true)
          acc.bindIP = item{"bindIP"}.getStr("")
          acc.proxy = item{"proxy"}.getStr("")

          if item.hasKey("credentials"):
            let c = item["credentials"]
            acc.credentials.email = c{"email"}.getStr("")
            acc.credentials.password = c{"password"}.getStr("")
            acc.credentials.token = c{"token"}.getStr("")
            acc.credentials.sessionCookie = c{"sessionCookie"}.getStr("")
            acc.credentials.origin = c{"origin"}.getStr("")

          if item.hasKey("settings"):
            let s = item["settings"]
            acc.settings.huntTarget = s{"huntTarget"}.getStr("")
            acc.settings.autoHunt = s{"autoHunt"}.getBool(true)
            acc.settings.autoSell = s{"autoSell"}.getBool(true)
            acc.settings.autoHeal = s{"autoHeal"}.getBool(true)
            acc.settings.autoUpgrade = s{"autoUpgrade"}.getBool(true)
            acc.settings.autoDaily = s{"autoDaily"}.getBool(true)
            acc.settings.autoChests = s{"autoChests"}.getBool(true)
            acc.settings.autoParty = s{"autoParty"}.getBool(true)
            acc.settings.partyLeader = s{"partyLeader"}.getStr("")
            acc.settings.killRate = s{"killRate"}.getFloat(1.0)

          result.add(acc)
    except CatchableError as e:
      echo "⚠️ Erro ao ler ", path, ": ", e.msg
