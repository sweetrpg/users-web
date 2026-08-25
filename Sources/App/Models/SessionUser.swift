import Vapor

struct SessionUser: Codable {
  let sub: String
  let name: String
  let email: String?
  let roles: [String]
  let accessToken: String
  let expiry: Date
}
