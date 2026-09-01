import Testing
import VaporTesting

@testable import App

// .serialized: both tests exercise configure(_:), which calls app.logger.warning(...) when
// SHARED_SESSION_REDIS_HOST is unset. Running them concurrently crashed CI on Linux (a Swift
// runtime race populating the log-source type-metadata cache on first use, inside swift-log's
// default StreamLogHandler - this app's own JSONLogHandler bootstrap only happens in the real
// entrypoint, never in tests). Same mitigation already used in auth-web's
// ProvisionedUserIDTests suite.
@Suite("AuthRequiredMiddleware", .serialized)
struct AuthRequiredMiddlewareTests {
  @Test("an unauthenticated visitor requesting the profile page is redirected to auth-web login")
  func unauthenticatedVisitorRedirectsToLogin() async throws {
    try await withApp(configure: configure) { app in
      try await app.testing().test(.GET, "profile") { res in
        #expect(res.status == .seeOther)
        let location = res.headers.first(name: .location) ?? ""
        #expect(location.hasPrefix("/auth/login?return_to="))
      }
    }
  }

  @Test("an unauthenticated visitor requesting the friends page is redirected to auth-web login")
  func unauthenticatedVisitorRedirectsToLoginFromFriends() async throws {
    try await withApp(configure: configure) { app in
      try await app.testing().test(.GET, "friends") { res in
        #expect(res.status == .seeOther)
        let location = res.headers.first(name: .location) ?? ""
        #expect(location.hasPrefix("/auth/login?return_to="))
      }
    }
  }

  @Test("status ping responds ok without requiring authentication")
  func statusPingBypassesAuth() async throws {
    try await withApp(configure: configure) { app in
      try await app.testing().test(.GET, "status/ping") { res in
        #expect(res.status == .ok)
      }
    }
  }
}
