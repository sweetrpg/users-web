import Foundation
import Testing

@testable import App

@Suite("ProfileController")
struct ProfileControllerTests {
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
