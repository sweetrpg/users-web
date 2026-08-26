import Foundation
import Testing

@testable import App

@Suite("SessionUser")
struct SessionUserTests {
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
}
