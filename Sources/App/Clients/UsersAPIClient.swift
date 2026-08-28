import Vapor

struct UsersAPIClient {
  let client: Client
  let baseURL: String

  init(request: Request) {
    self.client = request.client
    self.baseURL = request.usersAPIConfig.baseURL
  }

  func fetchProfile(accessToken: String) async throws -> Profile {
    let response = try await client.get(URI(string: baseURL + "/profile")) { req in
      req.headers.bearerAuthorization = BearerAuthorization(token: accessToken)
    }
    guard (200..<300).contains(response.status.code) else {
      throw Abort(
        response.status, reason: "users-api request failed with status \(response.status.code)")
    }
    return try response.content.decode(Profile.self)
  }

  func updateProfile(
    accessToken: String, name: String, bio: String, website: String
  ) async throws -> Profile {
    let response = try await client.patch(URI(string: baseURL + "/profile")) { req in
      req.headers.bearerAuthorization = BearerAuthorization(token: accessToken)
      try req.content.encode(UpdateProfileRequest(name: name, bio: bio, website: website))
    }
    guard (200..<300).contains(response.status.code) else {
      throw Abort(
        response.status, reason: "users-api request failed with status \(response.status.code)")
    }
    return try response.content.decode(Profile.self)
  }
}

private struct UpdateProfileRequest: Content {
  let name: String
  let bio: String
  let website: String
}

extension Request {
  var usersAPI: UsersAPIClient { UsersAPIClient(request: self) }
}
