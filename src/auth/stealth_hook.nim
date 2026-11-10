import std/[strutils]

proc stealthInitScript*(): string =
  result = """(() => {
  Object.defineProperty(navigator, 'webdriver', { get: () => undefined });
  Object.defineProperty(navigator, 'languages', { get: () => ['pt-BR', 'pt', 'en-US', 'en'] });
  Object.defineProperty(navigator, 'plugins', { get: () => [1, 2, 3, 4, 5] });
  Object.defineProperty(navigator, 'hardwareConcurrency', { get: () => 8 });
  Object.defineProperty(navigator, 'deviceMemory', { get: () => 8 });
  window.chrome = window.chrome || { runtime: {} };
})();"""

proc turnstileInterceptScript*(targetPathSubstring: string = "/auth/world-ticket"): string =
  let target = if targetPathSubstring.strip().len == 0: "/auth/world-ticket" else: targetPathSubstring
  result = """(() => {
  window.__INTERCEPTED_TURNSTILE_TOKEN = null;
  window.__INTERCEPTED_PAYLOAD = null;

  class DummyWebSocket {
    constructor(url) {
      this.url = url;
      this.readyState = 0;
    }
    send() {}
    close() { this.readyState = 3; }
    addEventListener() {}
    removeEventListener() {}
  }
  window.WebSocket = DummyWebSocket;

  const origFetch = window.fetch.bind(window);
  window.fetch = async function(input, init) {
    const url = typeof input === 'string' ? input : (input && input.url) || '';
    if (url.includes('""" & target & """') && init && init.body) {
      try {
        const parsed = typeof init.body === 'string' ? JSON.parse(init.body) : init.body;
        window.__INTERCEPTED_PAYLOAD = parsed;
        const inner = (parsed && parsed["0"] && parsed["0"].json) ? parsed["0"].json : parsed;
        if (inner && inner.turnstileToken) {
          window.__INTERCEPTED_TURNSTILE_TOKEN = inner.turnstileToken;
        }
      } catch (e) {}
      return new Response(JSON.stringify([{ result: { data: { json: { intercepted: true } } } }]), {
        status: 200,
        headers: { 'Content-Type': 'application/json' }
      });
    }
    return origFetch(input, init);
  };
})();"""
