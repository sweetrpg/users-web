import Foundation
import Vapor

/// Render context for `profile.leaf`.
struct ProfileView: Encodable {
  let user: LeafUser
  let meta: PageMeta
  let profile: Profile
  let terms: TermsView

  init(req: Request, user: LeafUser, profile: Profile) {
    self.user = user
    self.meta = PageMeta(req)
    self.profile = profile
    self.terms = TermsView(rootURL: req.rootURL, accepted: profile.termsAccepted)
  }
}

/// The terms and privacy links plus the user's accepted version and date. The documents are
/// served by `main-web` at the site root, so the links hang off `ROOT_URL`, not this app's own
/// `INGRESS_BASE_PATH` (which would point at a path `users-web` does not serve).
struct TermsView: Encodable {
  let termsURL: String
  let privacyURL: String
  let acceptedVersion: String?
  let acceptedDate: String?

  init(rootURL: String, accepted: TermsAccepted?) {
    let root = rootURL.hasSuffix("/") ? rootURL : rootURL + "/"
    self.termsURL = root + "terms"
    self.privacyURL = root + "privacy"
    self.acceptedVersion = accepted?.version
    self.acceptedDate = accepted.map { Self.displayDate($0.acceptedAt) }
  }

  /// `users-api` sends RFC 3339 UTC; show the calendar date, or the raw string if it does not parse.
  static func displayDate(_ raw: String) -> String {
    let fractional = ISO8601DateFormatter()
    fractional.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    let plain = ISO8601DateFormatter()
    guard let date = fractional.date(from: raw) ?? plain.date(from: raw) else { return raw }
    return date.formatted(
      Date.FormatStyle(
        date: .long, time: .omitted, locale: Locale(identifier: "en_US"),
        timeZone: TimeZone(identifier: "UTC")!))
  }
}
