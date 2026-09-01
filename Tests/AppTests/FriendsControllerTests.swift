import Foundation
import Leaf
import Testing
import VaporTesting

@testable import App

@Suite("FriendsController")
struct FriendsControllerTests {
  @Test("friends template renders lists, actions, and the add-a-friend form")
  func friendsTemplateRenders() async throws {
    try await withApp { app in
      app.views.use(.leaf)
      app.get("test-render") { req -> View in
        struct FriendsView: Encodable {
          let meta: PageMeta
          let friends: [Friend]
          let incoming: [FriendRequest]
          let outgoing: [FriendRequest]
          let errorMessage: String?
        }
        return try await req.view.render(
          "friends",
          FriendsView(
            meta: PageMeta(req),
            friends: [Friend(userID: "u-1", name: "Ada", email: "ada@example.com")],
            incoming: [FriendRequest(id: "req-1", userID: "u-2", name: "Grace", email: "")],
            outgoing: [FriendRequest(id: "req-2", userID: "u-3", name: "", email: "")],
            errorMessage: nil
          )
        )
      }

      try await app.testing().test(.GET, "test-render") { res in
        let body = res.body.string
        #expect(!body.contains("#extend"))
        #expect(body.contains("Ada"))
        #expect(body.contains("Grace"))
        // outgoing entry with no name falls back to the id
        #expect(body.contains("u-3"))
        #expect(body.contains("/friends/u-1/remove"))
        #expect(body.contains("/friends/requests/req-1/accept"))
        #expect(body.contains("/friends/requests/req-1/decline"))
        #expect(body.contains(#"name="user_id""#))
      }
    }
  }
}
