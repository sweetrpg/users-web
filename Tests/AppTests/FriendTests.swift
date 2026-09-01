import Foundation
import Testing

@testable import App

@Suite("Friend")
struct FriendTests {
  @Test("Friend decodes users-api snake_case JSON")
  func friendDecodes() throws {
    let json = """
      { "user_id": "2f1c4d6e-0000-4000-8000-000000000001", "name": "Ada", "email": "ada@example.com" }
      """
    let friend = try JSONDecoder().decode(Friend.self, from: Data(json.utf8))
    #expect(friend.userID == "2f1c4d6e-0000-4000-8000-000000000001")
    #expect(friend.name == "Ada")
    #expect(friend.email == "ada@example.com")
  }

  @Test("FriendRequestsResponse decodes incoming and outgoing lists")
  func requestsResponseDecodes() throws {
    let json = """
      {
        "incoming": [
          { "id": "req-1", "user_id": "u-1", "name": "Grace", "email": "grace@example.com" }
        ],
        "outgoing": [
          { "id": "req-2", "user_id": "u-2", "name": "", "email": "" }
        ]
      }
      """
    let resp = try JSONDecoder().decode(FriendRequestsResponse.self, from: Data(json.utf8))
    #expect(resp.incoming.count == 1)
    #expect(resp.incoming[0].id == "req-1")
    #expect(resp.incoming[0].name == "Grace")
    #expect(resp.outgoing.count == 1)
    #expect(resp.outgoing[0].userID == "u-2")
  }

  @Test("FriendsResponse decodes the friends wrapper")
  func friendsResponseDecodes() throws {
    let json = """
      { "friends": [ { "user_id": "u-1", "name": "Ada", "email": "ada@example.com" } ] }
      """
    let resp = try JSONDecoder().decode(FriendsResponse.self, from: Data(json.utf8))
    #expect(resp.friends.count == 1)
    #expect(resp.friends[0].userID == "u-1")
  }
}
