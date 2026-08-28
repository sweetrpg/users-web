import Foundation
import Testing
import VaporTesting

@testable import App

@Suite("ProfileController")
struct ProfileControllerTests {
  // AuthRequiredMiddleware sits in front of every route and would normally redirect an
  // unauthenticated visitor before this handler ever runs - this test exercises the handler's
  // own fallback directly (no shared session configured, so req.currentUser is nil), proving
  // the inline-edit fetch() call gets a JSON 401 to react to rather than an HTML redirect page
  // it would fail to JSON.parse().
  @Test("updateProfile responds with JSON 401 when the session is missing, not a redirect")
  func updateProfileUnauthenticatedRespondsWithJSON() async throws {
    try await withApp { app in
      try ProfileController().boot(routes: app.routes)

      try await app.testing().test(
        .POST, "profile",
        headers: ["Content-Type": "application/json", "Accept": "application/json"],
        body: ByteBuffer(string: #"{"name":"Ada","bio":"","website":""}"#)
      ) { res in
        #expect(res.status == .unauthorized)
        #expect(res.headers.contentType?.description.contains("json") == true)
        #expect(res.body.string.contains("session expired"))
      }
    }
  }
}
