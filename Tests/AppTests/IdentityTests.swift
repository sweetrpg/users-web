import Foundation
import Testing

@testable import App

@Suite("Identity")
struct IdentityTests {
  @Test("Identity decodes users-api's camelCase linkedIdentityResponse JSON")
  func identityDecodes() throws {
    let json = """
      { "loginProfileId": "li-1", "connectionType": "github", "linkedAt": "2026-09-01T00:00:00Z" }
      """
    let identity = try JSONDecoder().decode(Identity.self, from: Data(json.utf8))
    #expect(identity.id == "li-1")
    #expect(identity.connectionType == "github")
    #expect(identity.linkedAt == "2026-09-01T00:00:00Z")
  }

  @Test("[Identity] decodes users-api's bare array response")
  func identityArrayDecodes() throws {
    let json = """
      [ { "loginProfileId": "li-1", "connectionType": "email", "linkedAt": "2026-09-01T00:00:00Z" } ]
      """
    let identities = try JSONDecoder().decode([Identity].self, from: Data(json.utf8))
    #expect(identities.count == 1)
    #expect(identities[0].id == "li-1")
  }
}
