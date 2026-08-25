import Redis
import Vapor

let sharedSessionCookieName = "sweetrpg_session"

/// Names the Redis connection this app reads the shared session from - a distinct connection
/// from any future app-local Redis this app might add for its own purposes, pointed instead at
/// auth-web's dedicated Redis instance. See `configure.swift` and `catalog-web`'s own
/// `SessionUserAccess.swift` for the precedent this mirrors.
extension RedisID {
  static let sharedSession = RedisID("sharedSession")
}

private let sharedSessionDecoder: JSONDecoder = {
  let decoder = JSONDecoder()
  decoder.dateDecodingStrategy = .iso8601
  return decoder
}()

extension Request {
  /// Reads (never writes) the session `auth-web` established for this visitor, if any. Fails
  /// open on every error path (disabled, unreachable Redis, missing cookie, missing key,
  /// malformed JSON) by returning `nil`. This intentionally does NOT go through Vapor's
  /// `Session`/`SessionsMiddleware` machinery: touching `req.session` on every request would
  /// create and write back a brand-new session for every anonymous visitor, which is exactly
  /// the write this read-only consumer must never make.
  var currentUser: SessionUser? {
    get async {
      guard application.sharedSessionRedisConfigured else { return nil }
      guard let sessionID = cookies[sharedSessionCookieName]?.string else { return nil }

      // Key format matches Vapor's ResilientRedisSessionDriver (auth-web's session writer):
      // `vrs-<sessionID>`, JSON-encoded Vapor `SessionData` (a flat `[String: String]`).
      let key = RedisKey("vrs-\(sessionID)")
      guard
        let sessionData = try? await redis(.sharedSession).get(key, asJSON: [String: String].self)
          .get(),
        let userJSON = sessionData["user"],
        let data = userJSON.data(using: .utf8),
        let user = try? sharedSessionDecoder.decode(SessionUser.self, from: data),
        user.expiry > Date()
      else { return nil }

      return user
    }
  }
}

extension Application {
  private struct SharedSessionRedisConfiguredKey: StorageKey {
    typealias Value = Bool
  }

  var sharedSessionRedisConfigured: Bool {
    get { storage[SharedSessionRedisConfiguredKey.self] ?? false }
    set { storage[SharedSessionRedisConfiguredKey.self] = newValue }
  }
}
