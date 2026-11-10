import std/[json, strutils]

proc buildKickHandshakePayload*(channelId: string): JsonNode =
  result = %*{
    "type": "channel_handshake",
    "data": {
      "message": {
        "channelId": channelId
      }
    }
  }

proc buildKickWatchLivestreamPayload*(channelId, livestreamId: string): JsonNode =
  result = %*{
    "type": "user_event",
    "data": {
      "message": {
        "name": "tracking.user.watch.livestream",
        "channel_id": channelId,
        "livestream_id": livestreamId
      }
    }
  }

proc buildTwitchClaimPointsGql*(channelId, claimId: string): JsonNode =
  result = %*{
    "operationName": "ClaimCommunityPoints",
    "variables": {
      "input": {
        "channelID": channelId,
        "claimID": claimId
      }
    },
    "extensions": {
      "persistedQuery": {
        "version": 1,
        "sha256Hash": "46aaeebe02c99afdf4fc97c7c0cba964124bf6b0af229395f1f6d1feed05b3d0"
      }
    }
  }

proc formatTwitchIrcJoin*(channels: openArray[string]): seq[string] =
  result = @[]
  for ch in channels:
    let clean = ch.strip().strip(chars = {'#'}).toLowerAscii()
    if clean.len > 0:
      result.add("JOIN #" & clean)
