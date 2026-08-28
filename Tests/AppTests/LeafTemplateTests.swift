import Leaf
import Testing
import VaporTesting

@testable import App

@Suite("Leaf templates")
struct LeafTemplateTests {
  @Test("profile-error renders base's page block instead of leaking an unresolved Leaf tag")
  func profileErrorRendersCleanly() async throws {
    try await withApp { app in
      app.views.use(.leaf)
      app.get("test-render") { req -> View in
        struct ErrorView: Encodable {
          let meta: PageMeta
          let errorMessage: String
        }
        return try await req.view.render(
          "profile-error",
          ErrorView(meta: PageMeta(req), errorMessage: "boom")
        )
      }

      try await app.testing().test(.GET, "test-render") { res in
        let body = res.body.string
        #expect(!body.contains("#embed"))
        #expect(body.contains("SweetRPG Platform"))
        #expect(body.contains("boom"))
        #expect(body.contains("/static/css/main.css"))
        #expect(body.contains("sweetrpg_theme_v1"))
        #expect(body.contains("/static/js/theme.js"))
      }
    }
  }
}
