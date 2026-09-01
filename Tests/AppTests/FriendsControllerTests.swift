import Foundation
import Leaf
import Testing
import VaporTesting

@testable import App

@Suite("FriendsController")
struct FriendsControllerTests {
  private struct RenderFriendsView: Encodable {
    let user: LeafUser
    let meta: PageMeta
    let friends: [Friend]
    let incoming: [FriendRequest]
    let outgoing: [FriendRequest]
    let friendCount: Int
    let incomingCount: Int
    let outgoingCount: Int
    let activePanel: String
    let errorMessage: String?
  }

  private static func sampleUser() -> LeafUser {
    LeafUser(
      SessionUser(
        sub: "auth0|123", name: "Logged In", email: "me@example.com", roles: ["user"],
        accessToken: "t", expiry: Date.distantFuture))
  }

  @Test("friends template renders the nav rail, panels, subtitles, and the add form")
  func friendsTemplateRenders() async throws {
    try await withApp { app in
      app.views.use(.leaf)
      app.get("test-render") { req -> View in
        try await req.view.render(
          "friends",
          RenderFriendsView(
            user: Self.sampleUser(),
            meta: PageMeta(req),
            friends: [
              Friend(userID: "u-1", name: "Ada", email: "ada@example.com"),
              Friend(userID: "u-9", name: "Bea", email: ""),
            ],
            incoming: [FriendRequest(id: "req-1", userID: "u-2", name: "Grace", email: "")],
            outgoing: [FriendRequest(id: "req-2", userID: "u-3", name: "", email: "")],
            friendCount: 2,
            incomingCount: 1,
            outgoingCount: 1,
            activePanel: "friends",
            errorMessage: nil
          )
        )
      }

      try await app.testing().test(.GET, "test-render") { res in
        let body = res.body.string
        #expect(!body.contains("#extend"))
        // Nav rail with four panels.
        #expect(body.contains(#"class="friends-nav""#))
        #expect(body.contains(#"data-panel="friends""#))
        #expect(body.contains(#"data-panel="incoming""#))
        #expect(body.contains(#"data-panel="outgoing""#))
        #expect(body.contains(#"data-panel="add""#))
        // Subtitles: plural for 2 friends, singular for 1 request.
        #expect(body.contains("2 friends"))
        #expect(body.contains("1 request"))
        // Lists + per-entry action URLs.
        #expect(body.contains("Ada"))
        #expect(body.contains("Grace"))
        #expect(body.contains("u-3"))
        #expect(body.contains("/friends/u-1/remove"))
        #expect(body.contains("/friends/requests/req-1/accept"))
        // Redesigned add input: single field named "identifier" with a placeholder, no label.
        #expect(body.contains(#"name="identifier""#))
        #expect(body.contains("placeholder="))
        // Logged-in identity is in context (avatar menu shows the name, not the log-in link).
        #expect(body.contains("Logged In"))
        #expect(body.contains(#"class="avatar-menu""#))
      }
    }
  }
}
