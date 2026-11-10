import std/[httpclient, asyncdispatch, strutils, uri]
import ../engine/stealth

type
  ResilientClient* = ref object
    client*: AsyncHttpClient
    stealth*: StealthEngine
    proxyUrl*: string

proc newResilientClient*(proxyUrl: string = ""): ResilientClient =
  let proxyObj = if proxyUrl.len > 0: newProxy(proxyUrl) else: nil
  result = ResilientClient(
    client: newAsyncHttpClient(proxy = proxyObj),
    stealth: newStealthEngine(),
    proxyUrl: proxyUrl
  )
  result.client.timeout = 10_000
  result.stealth.applyBrowserHeaders(result.client)

proc get*(c: ResilientClient, url: string): Future[string] {.async.} =
  await c.stealth.pacingStep()
  result = await c.client.getContent(url)

proc post*(c: ResilientClient, url, body: string): Future[string] {.async.} =
  await c.stealth.pacingStep()
  let resp = await c.client.post(url, body)
  result = await resp.body
