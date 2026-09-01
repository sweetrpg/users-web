import Vapor

struct Profile: Content {
  let name: String
  let email: String
  let bio: String
  let website: String
  let username: String

  init(name: String, email: String, bio: String, website: String, username: String = "") {
    self.name = name
    self.email = email
    self.bio = bio
    self.website = website
    self.username = username
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
  }
}
