import Vapor

struct UsersAPIConfig {
  let baseURL: String
}

extension Request {
  var usersAPIConfig: UsersAPIConfig {
    let defaultURL = "http://api-v1.sweetrpg-users.svc.cluster.local:8000"
    let baseURL = Environment.get("USERS_API_URL") ?? defaultURL
    return UsersAPIConfig(baseURL: baseURL)
  }
}
