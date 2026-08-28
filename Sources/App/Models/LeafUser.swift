import Crypto
import Foundation
import Vapor

struct LeafUser: Content {
  let name: String
  let email: String?
  let avatarInitial: String
  let avatarGravatarURL: String?
  let isAdmin: Bool

  init(_ user: SessionUser) {
    self.name = user.name
    self.email = user.email
    self.avatarInitial = user.name.first.map { String($0).uppercased() } ?? ""
    self.avatarGravatarURL = user.email.map { email in
      let canonical = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
      let hash = Insecure.MD5.hash(data: Data(canonical.utf8))
        .map { String(format: "%02x", $0) }
        .joined()
      return "https://www.gravatar.com/avatar/\(hash)?s=64&d=404"
    }
    self.isAdmin = user.roles.contains("admin")
  }
}
