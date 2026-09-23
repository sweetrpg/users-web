import Foundation
import Testing

@testable import App

@Suite("Identity")
struct IdentityTests {
  @Test("Identity decodes users-api snake_case JSON")
  func identityDecodes() throws {
    let json = """
      { "id": "li-1", "connection_type": "github", "linked_at": "2026-09-01T00:00:00Z" }
      """
    let identity = try JSONDecoder().decode(Identity.self, from: Data(json.utf8))
    #expect(identity.id == "li-1")
    #expect(identity.connectionType == "github")
    #expect(identity.linkedAt == "2026-09-01T00:00:00Z")
  }

  @Test("IdentitiesResponse decodes the identities wrapper")
  func identitiesResponseDecodes() throws {
    let json = """
      { "identities": [ { "id": "li-1", "connection_type": "email", "linked_at": "2026-09-01T00:00:00Z" } ] }
      """
    let resp = try JSONDecoder().decode(IdentitiesResponse.self, from: Data(json.utf8))
    #expect(resp.identities.count == 1)
    #expect(resp.identities[0].id == "li-1")
  }
}
