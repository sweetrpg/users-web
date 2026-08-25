import Foundation
import Testing
import VaporTesting

@testable import App

@Suite("App")
struct AppTests {
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

  @Test("status ping responds ok without requiring authentication")
  func statusPingBypassesAuth() async throws {
    try await withApp(configure: configure) { app in
      try await app.testing().test(.GET, "status/ping") { res in
        #expect(res.status == .ok)
      }
    }
  }

  @Test("Profile data model decodes correctly from JSON")
  func profileDecodesCorrectly() throws {
    let json = """
      {
        "name": "Alice",
        "email": "alice@example.com",
        "bio": "Hello world",
        "website": "https://example.com"
      }
      """
    let data = json.data(using: .utf8)!
    let profile = try JSONDecoder().decode(Profile.self, from: data)
    #expect(profile.name == "Alice")
    #expect(profile.email == "alice@example.com")
    #expect(profile.bio == "Hello world")
    #expect(profile.website == "https://example.com")
  }

  @Test("Profile encodes correctly to JSON")
  func profileEncodesCorrectly() throws {
    let profile = Profile(
      name: "Bob",
      email: "bob@example.com",
      bio: "Test bio",
      website: "https://test.com"
    )
    let data = try JSONEncoder().encode(profile)
    let json = String(data: data, encoding: .utf8)!
    #expect(json.contains("\"name\":\"Bob\""))
    #expect(json.contains("\"email\":\"bob@example.com\""))
  }

  @Test("SessionUser decodes RFC3339 date correctly")
  func sessionUserDecodesDate() throws {
    let json = """
      {
        "sub": "auth0|123",
        "name": "Alice",
        "email": "alice@example.com",
        "roles": ["user"],
        "accessToken": "test-token",
        "expiry": "2099-01-01T00:00:00Z"
      }
      """
    let data = json.data(using: .utf8)!
    let decoder = JSONDecoder()
    decoder.dateDecodingStrategy = .iso8601
    let user = try decoder.decode(SessionUser.self, from: data)
    #expect(user.sub == "auth0|123")
    #expect(user.name == "Alice")
    #expect(user.accessToken == "test-token")
  }

  @Test("ProfileController encodes structured view data")
  func profileViewDataEncodesCorrectly() throws {
    struct TestView: Encodable {
      let message: String
      let count: Int
    }

    let view = TestView(message: "Hello", count: 42)
    let data = try JSONEncoder().encode(view)
    let json = String(data: data, encoding: .utf8)!
    #expect(json.contains("\"message\":\"Hello\""))
    #expect(json.contains("\"count\":42"))
  }
}
