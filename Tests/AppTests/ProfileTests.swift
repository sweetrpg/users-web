import Foundation
import Testing

@testable import App

@Suite("Profile")
struct ProfileTests {
  @Test("Profile decodes, including username")
  func profileDecodesCorrectly() throws {
    let json = """
      {
        "name": "Alice",
        "email": "alice@example.com",
        "bio": "Hello world",
        "website": "https://example.com",
        "username": "alice"
      }
      """
    let profile = try JSONDecoder().decode(Profile.self, from: Data(json.utf8))
    #expect(profile.name == "Alice")
    #expect(profile.email == "alice@example.com")
    #expect(profile.bio == "Hello world")
    #expect(profile.website == "https://example.com")
    #expect(profile.username == "alice")
  }

  @Test("Profile tolerates a response with no username (older users-api / rollback)")
  func profileDecodesWithoutUsername() throws {
    let json = """
      { "name": "Alice", "email": "a@example.com", "bio": "", "website": "" }
      """
    let profile = try JSONDecoder().decode(Profile.self, from: Data(json.utf8))
    #expect(profile.username == "")
  }

  @Test("Profile encodes correctly to JSON")
  func profileEncodesCorrectly() throws {
    let profile = Profile(
      name: "Bob", email: "bob@example.com", bio: "Test bio", website: "https://test.com",
      username: "bob")
    let json = String(data: try JSONEncoder().encode(profile), encoding: .utf8)!
    #expect(json.contains("\"name\":\"Bob\""))
    #expect(json.contains("\"username\":\"bob\""))
  }
}
