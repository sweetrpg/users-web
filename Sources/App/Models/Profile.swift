import Vapor

struct Profile: Content {
  let name: String
  let email: String
  let bio: String
  let website: String
}
