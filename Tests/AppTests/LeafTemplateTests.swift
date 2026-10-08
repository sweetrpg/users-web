import Leaf
import Testing
import VaporTesting

@testable import App

// .serialized: Leaf's renderer is not reliably safe under Swift Testing's cross-test
// parallelism - concurrent renders within this suite intermittently crashed with
// `-[__NSCFNumber count]: unrecognized selector`, reproducing more often as more Leaf-rendering
// tests were added here. Forcing this suite's tests to run one at a time avoids the contention
// (mirrors the USERS_API_URL env-var race fix in auth-web's AppTests.swift).
@Suite("Leaf templates", .serialized)
struct LeafTemplateTests {
  @Test("profile-error renders base's page block instead of leaking an unresolved Leaf tag")
  func profileErrorRendersCleanly() async throws {
    try await withApp { app in
      // withApp (unlike the real app's configure(_:)) never calls I18n.loadTables() itself -
      // without this, meta.l10n lookups silently return empty strings instead of failing loudly,
      // and this test only ever passed by accident when some other test happened to populate
      // I18n's process-shared table first.
      try I18n.loadTables()
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

  @Test("settings enables unlink on every row when more than one identity is linked")
  func settingsEnablesUnlinkWithMultipleIdentities() async throws {
    try await withApp { app in
      try I18n.loadTables()
      app.views.use(.leaf)
      app.get("test-render") { req -> View in
        struct SettingsView: Encodable {
          let meta: PageMeta
          let identities: [Identity]
          let canUnlink: Bool
          let linkStartURL: String
          let linkOutcome: String?
          let errorMessage: String?
        }
        let identities = [
          Identity(id: "li-1", connectionType: "github", linkedAt: "2026-09-03T01:27:54Z"),
          Identity(id: "li-2", connectionType: "dropbox", linkedAt: "2026-10-04T14:36:31Z"),
          Identity(id: "li-3", connectionType: "oauth2", linkedAt: "2026-10-04T14:35:42Z"),
        ]
        return try await req.view.render(
          "settings",
          SettingsView(
            meta: PageMeta(req), identities: identities, canUnlink: true,
            linkStartURL: "/auth/link/start", linkOutcome: nil, errorMessage: nil)
        )
      }

      try await app.testing().test(.GET, "test-render") { res in
        let body = res.body.string
        #expect(!body.contains("disabled"))
        #expect(body.contains("github"))
        #expect(body.contains("dropbox"))
        #expect(body.contains("oauth2"))
      }
    }
  }

  @Test("settings disables unlink on the sole row when exactly one identity is linked")
  func settingsDisablesUnlinkWithOneIdentity() async throws {
    try await withApp { app in
      try I18n.loadTables()
      app.views.use(.leaf)
      app.get("test-render") { req -> View in
        struct SettingsView: Encodable {
          let meta: PageMeta
          let identities: [Identity]
          let canUnlink: Bool
          let linkStartURL: String
          let linkOutcome: String?
          let errorMessage: String?
        }
        let identities = [
          Identity(id: "li-1", connectionType: "github", linkedAt: "2026-09-03T01:27:54Z")
        ]
        return try await req.view.render(
          "settings",
          SettingsView(
            meta: PageMeta(req), identities: identities, canUnlink: false,
            linkStartURL: "/auth/link/start", linkOutcome: nil, errorMessage: nil)
        )
      }

      try await app.testing().test(.GET, "test-render") { res in
        #expect(res.body.string.contains("disabled"))
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
