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
        #expect(body.contains("Pilgrimage Software"))
        #expect(body.contains("boom"))
        #expect(body.contains("/static/css/main.css"))
        #expect(body.contains("sweetrpg_theme_v1"))
        #expect(body.contains("/static/js/theme.js"))
        #expect(body.contains("class=\"nav\""))
        #expect(body.contains("class=\"nav-brand\""))
        #expect(body.contains("nav-logo nav-logo-light"))
        #expect(body.contains("class=\"avatar-menu\""))
        #expect(body.contains("class=\"app-switcher\""))
        #expect(body.contains("class=\"btn btn-primary\""))
        #expect(!body.contains("class=\"btn-primary\""))
      }
    }
  }

  @Test("profile renders click-to-edit fields, not the old separate edit form")
  func profileRendersInlineEditFields() async throws {
    try await withApp { app in
      app.views.use(.leaf)
      app.get("test-render") { req -> View in
        struct ProfileView: Encodable {
          let meta: PageMeta
          let profile: Profile
          let errorMessage: String?
        }
        return try await req.view.render(
          "profile",
          ProfileView(
            meta: PageMeta(req),
            profile: Profile(
              name: "Ada Lovelace", email: "ada@example.com", bio: "Mathematician", website: ""),
            errorMessage: nil
          )
        )
      }

      try await app.testing().test(.GET, "test-render") { res in
        let body = res.body.string
        // Data the JS reads to drive inline editing - not a static form field.
        #expect(body.contains(#"data-name="Ada Lovelace""#))
        #expect(body.contains(#"data-bio="Mathematician""#))
        #expect(body.contains("profile-field-value"))
        #expect(body.contains("/profile-inline-edit.js"))
        // The old always-visible "enter edit mode, click Save" form is gone.
        #expect(!body.contains("profile-edit-form"))
        #expect(!body.contains("Edit Profile"))
        // Email stays plain, read-only display - never becomes an editable field.
        #expect(body.contains("profile-field-readonly"))
        #expect(!body.contains(#"data-field="email""#))
      }
    }
  }
}
