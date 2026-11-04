import Foundation
import Testing
import VaporTesting

@testable import App

private func sampleProfile(accepted: TermsAccepted?) -> Profile {
  Profile(name: "Ada", email: "ada@example.com", bio: "", website: "", termsAccepted: accepted)
}

private let sampleUser = LeafUser(
  SessionUser(
    sub: "auth0|abc", name: "Ada", email: "ada@example.com", roles: [], accessToken: "tok",
    expiry: Date().addingTimeInterval(3600)))

/// Renders `profile.leaf` through the same `ProfileView` the controller builds. The real route
/// reads the visitor from auth-web's shared Redis session, which tests cannot populate.
private func renderProfile(_ profile: Profile, rootURL: String, basePath: String) async throws
  -> String
{
  setenv("ROOT_URL", rootURL, 1)
  setenv("INGRESS_BASE_PATH", basePath, 1)
  defer {
    unsetenv("ROOT_URL")
    unsetenv("INGRESS_BASE_PATH")
  }
  var html = ""
  try await withApp { app in
    try I18n.loadTables()
    app.views.use(.leaf)
    app.get("test-profile") { req async throws -> View in
      try await req.view.render(
        "profile", ProfileView(req: req, user: sampleUser, profile: profile))
    }
    try await app.testing().test(.GET, "test-profile") { res in
      #expect(res.status == .ok)
      html = res.body.string
    }
  }
  return html
}

// Extends LeafTemplateTests so these Leaf renders share its .serialized ordering (Leaf crashes
// under cross-suite parallel rendering).
extension LeafTemplateTests {
  @Test("shows links to /terms and /privacy, and the accepted version and date")
  func showsLinksVersionAndDate() async throws {
    let html = try await renderProfile(
      sampleProfile(
        accepted: TermsAccepted(version: "1.0", acceptedAt: "2026-11-02T19:10:09.123Z")),
      rootURL: "https://dev.sweetrpg.com/", basePath: "/users")
    #expect(html.contains("href=\"https://dev.sweetrpg.com/terms\""))
    #expect(html.contains("href=\"https://dev.sweetrpg.com/privacy\""))
    #expect(html.contains("Accepted version 1.0 on November 2, 2026"))
  }

  @Test("renders 'Not recorded yet' when no acceptance is on record")
  func notRecorded() async throws {
    let html = try await renderProfile(
      sampleProfile(accepted: nil), rootURL: "https://dev.sweetrpg.com/", basePath: "/users")
    #expect(html.contains("Not recorded yet"))
    #expect(!html.contains("Accepted version"))
  }

  @Test("links hang off the site root, never the app's own path prefix")
  func linksIgnoreBasePath() async throws {
    let html = try await renderProfile(
      sampleProfile(accepted: nil), rootURL: "/", basePath: "/users")
    #expect(html.contains("href=\"/terms\""))
    #expect(!html.contains("/users/terms"))
  }

  @Test("a ROOT_URL without a trailing slash still yields a well-formed link")
  func rootURLWithoutTrailingSlash() {
    let view = TermsView(rootURL: "https://dev.sweetrpg.com", accepted: nil)
    #expect(view.termsURL == "https://dev.sweetrpg.com/terms")
  }

  @Test("an unparseable accepted_at is shown as received")
  func unparseableDate() {
    #expect(TermsView.displayDate("not-a-date") == "not-a-date")
  }

  @Test("profile decodes terms_accepted from users-api and tolerates null or absence")
  func decodesTermsAccepted() throws {
    let base = #""name":"A","email":"a@b.c","bio":"","website":"""#
    let with =
      #"{\#(base),"terms_accepted":{"version":"1.0","accepted_at":"2026-11-02T19:10:09Z"}}"#
    let null = #"{\#(base),"terms_accepted":null}"#
    let absent = "{\(base)}"
    let decode = { (json: String) throws -> Profile in
      try JSONDecoder().decode(Profile.self, from: Data(json.utf8))
    }
    #expect(try decode(with).termsAccepted?.version == "1.0")
    #expect(try decode(null).termsAccepted == nil)
    #expect(try decode(absent).termsAccepted == nil)
  }
}
