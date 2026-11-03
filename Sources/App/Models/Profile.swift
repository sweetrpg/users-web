import Vapor

struct Profile: Content {
  let name: String
  let email: String
  let bio: String
  let website: String
  let username: String
  /// The terms version the user accepted and when; `nil` until they accept.
  let termsAccepted: TermsAccepted?

  enum CodingKeys: String, CodingKey {
    case name, email, bio, website, username
    case termsAccepted = "terms_accepted"
  }

  init(
    name: String, email: String, bio: String, website: String, username: String = "",
    termsAccepted: TermsAccepted? = nil
  ) {
    self.name = name
    self.email = email
    self.bio = bio
    self.website = website
    self.username = username
    self.termsAccepted = termsAccepted
  }

  // username tolerates absence so a users-api that predates the field (or a rollback) still
  // decodes.
  init(from decoder: Decoder) throws {
    let c = try decoder.container(keyedBy: CodingKeys.self)
    self.name = try c.decode(String.self, forKey: .name)
    self.email = try c.decode(String.self, forKey: .email)
    self.bio = try c.decode(String.self, forKey: .bio)
    self.website = try c.decode(String.self, forKey: .website)
    self.username = try c.decodeIfPresent(String.self, forKey: .username) ?? ""
    self.termsAccepted = try c.decodeIfPresent(TermsAccepted.self, forKey: .termsAccepted)
  }
}

struct TermsAccepted: Content, Equatable {
  let version: String
  let acceptedAt: String

  enum CodingKeys: String, CodingKey {
    case version
    case acceptedAt = "accepted_at"
  }
}
