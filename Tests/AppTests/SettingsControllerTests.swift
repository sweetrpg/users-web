import Foundation
import Testing
import VaporTesting

@testable import App

@Suite("SettingsController")
struct SettingsControllerTests {
  // AuthRequiredMiddleware normally redirects an unauthenticated visitor before this handler
  // runs - this exercises the handler's own fallback directly (no shared session configured,
  // so req.currentUser is nil).
  @Test("showSettings responds 401 when the session is missing")
  func showSettingsUnauthenticatedRespondsUnauthorized() async throws {
    try await withApp { app in
      try SettingsController().boot(routes: app.routes)

      try await app.testing().test(.GET, "settings") { res in
        #expect(res.status == .unauthorized)
      }
    }
  }

  @Test("unlinkIdentity responds 401 when the session is missing")
  func unlinkUnauthenticatedRespondsUnauthorized() async throws {
    try await withApp { app in
      try SettingsController().boot(routes: app.routes)

      try await app.testing().test(.POST, "settings/identities/li-1/unlink") { res in
        #expect(res.status == .unauthorized)
      }
    }
  }
}
