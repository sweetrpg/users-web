import Foundation
import Testing

@testable import App

@Suite("Profile")
struct ProfileTests {
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
}
