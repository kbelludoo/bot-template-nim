import std/[os]

type
  TicketResult* = object
    ticket*: string
    wsUrl*: string

proc findBrowserPath*(): string =
  let custom = getEnv("BROWSER_PATH", "")
  if custom.len > 0 and fileExists(custom):
    return custom

  when defined(windows):
    let candidates = [
      r"C:\Program Files\Google\Chrome\Application\chrome.exe",
      r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
      getEnv("LOCALAPPDATA", "") & r"\Google\Chrome\Application\chrome.exe",
      r"C:\Program Files\BraveSoftware\Brave-Browser\Application\brave.exe",
      r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe"
    ]
  else:
    let candidates = [
      "/usr/bin/google-chrome",
      "/usr/bin/google-chrome-stable",
      "/usr/bin/chromium",
      "/usr/bin/chromium-browser"
    ]

  for c in candidates:
    if c.len > 0 and fileExists(c):
      return c

  raise newException(CatchableError, "Nenhum navegador Chrome/Chromium encontrado no sistema")
