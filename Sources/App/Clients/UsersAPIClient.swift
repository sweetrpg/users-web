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

  func fetchFriends(accessToken: String) async throws -> [Friend] {
    let response = try await client.get(URI(string: baseURL + "/friends")) { req in
      req.headers.bearerAuthorization = BearerAuthorization(token: accessToken)
    }
    try Self.ensureSuccess(response)
    return try response.content.decode(FriendsResponse.self).friends
  }

  func fetchFriendRequests(accessToken: String) async throws -> FriendRequestsResponse {
    let response = try await client.get(URI(string: baseURL + "/friends/requests")) { req in
      req.headers.bearerAuthorization = BearerAuthorization(token: accessToken)
    }
    try Self.ensureSuccess(response)
    return try response.content.decode(FriendRequestsResponse.self)
  }

  func sendFriendRequest(accessToken: String, targetUserID: String) async throws {
    let response = try await client.post(URI(string: baseURL + "/friends/requests")) { req in
      req.headers.bearerAuthorization = BearerAuthorization(token: accessToken)
      try req.content.encode(SendFriendRequestBody(userID: targetUserID))
    }
    try Self.ensureSuccess(response)
  }

  /// action is "accept" or "decline".
  func respondToFriendRequest(accessToken: String, id: String, action: String) async throws {
    let response = try await client.post(
      URI(string: baseURL + "/friends/requests/\(id)/\(action)")
    ) { req in
      req.headers.bearerAuthorization = BearerAuthorization(token: accessToken)
    }
    try Self.ensureSuccess(response)
  }

  func removeFriend(accessToken: String, id: String) async throws {
    let response = try await client.delete(URI(string: baseURL + "/friends/\(id)")) { req in
      req.headers.bearerAuthorization = BearerAuthorization(token: accessToken)
    }
    try Self.ensureSuccess(response)
  }

  private static func ensureSuccess(_ response: ClientResponse) throws {
    guard (200..<300).contains(response.status.code) else {
      throw Abort(
        response.status, reason: "users-api request failed with status \(response.status.code)")
    }
  }
}

private struct UpdateProfileRequest: Content {
  let name: String
  let bio: String
  let website: String
}

private struct SendFriendRequestBody: Content {
  let userID: String

  enum CodingKeys: String, CodingKey {
    case userID = "user_id"
  }
}

extension Request {
  var usersAPI: UsersAPIClient { UsersAPIClient(request: self) }
}
