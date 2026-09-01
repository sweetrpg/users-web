import Vapor

struct FriendsController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let friends = routes.grouped("friends")
    friends.get(use: showFriends)
    friends.post("requests", use: sendRequest)
    friends.post("requests", ":id", "accept", use: acceptRequest)
    friends.post("requests", ":id", "decline", use: declineRequest)
    friends.post(":id", "remove", use: removeFriend)
  }

  private struct FriendsView: Encodable {
    let meta: PageMeta
    let friends: [Friend]
    let incoming: [FriendRequest]
    let outgoing: [FriendRequest]
    let errorMessage: String?
  }

  func showFriends(req: Request) async throws -> View {
    let user = try await requireUser(req)
    return try await renderFriends(req: req, user: user, errorMessage: nil)
  }

  func sendRequest(req: Request) async throws -> Response {
    let user = try await requireUser(req)

    struct SendForm: Content {
      let userID: String

      enum CodingKeys: String, CodingKey {
        case userID = "user_id"
      }
    }
    let form = try req.content.decode(SendForm.self)
    let target = form.userID.trimmingCharacters(in: .whitespacesAndNewlines)

    do {
      try await req.usersAPI.sendFriendRequest(accessToken: user.accessToken, targetUserID: target)
      return req.redirectLocal(to: "/friends")
    } catch let error as Abort where isClientError(error) {
      let message = sendErrorMessage(for: error.status, l10n: req.l10n)
      return try await renderFriends(req: req, user: user, errorMessage: message).encodeResponse(
        for: req)
    }
  }

  func acceptRequest(req: Request) async throws -> Response {
    try await respond(req: req, action: "accept")
  }

  func declineRequest(req: Request) async throws -> Response {
    try await respond(req: req, action: "decline")
  }

  func removeFriend(req: Request) async throws -> Response {
    let user = try await requireUser(req)
    let id = try req.parameters.require("id")
    do {
      try await req.usersAPI.removeFriend(accessToken: user.accessToken, id: id)
      return req.redirectLocal(to: "/friends")
    } catch let error as Abort where isClientError(error) {
      let message = req.l10n["friends_error_action"] ?? "That action could not be completed."
      return try await renderFriends(req: req, user: user, errorMessage: message).encodeResponse(
        for: req)
    }
  }

  // MARK: - Helpers

  private func respond(req: Request, action: String) async throws -> Response {
    let user = try await requireUser(req)
    let id = try req.parameters.require("id")
    do {
      try await req.usersAPI.respondToFriendRequest(
        accessToken: user.accessToken, id: id, action: action)
      return req.redirectLocal(to: "/friends")
    } catch let error as Abort where isClientError(error) {
      let message = req.l10n["friends_error_action"] ?? "That action could not be completed."
      return try await renderFriends(req: req, user: user, errorMessage: message).encodeResponse(
        for: req)
    }
  }

  private func requireUser(_ req: Request) async throws -> SessionUser {
    guard let user = await req.currentUser else {
      throw Abort(.unauthorized)
    }
    return user
  }

  private func renderFriends(req: Request, user: SessionUser, errorMessage: String?) async throws
    -> View
  {
    do {
      async let friends = req.usersAPI.fetchFriends(accessToken: user.accessToken)
      async let requests = req.usersAPI.fetchFriendRequests(accessToken: user.accessToken)
      let view = FriendsView(
        meta: PageMeta(req),
        friends: try await friends,
        incoming: try await requests.incoming,
        outgoing: try await requests.outgoing,
        errorMessage: errorMessage
      )
      return try await req.view.render("friends", view)
    } catch {
      struct ErrorView: Encodable {
        let meta: PageMeta
        let errorMessage: String
      }
      return try await req.view.render(
        "friends-error",
        ErrorView(
          meta: PageMeta(req),
          errorMessage: req.l10n["friends_error_load"] ?? "Failed to load friends")
      )
    }
  }

  private func isClientError(_ error: Abort) -> Bool {
    (400..<500).contains(error.status.code)
  }

  private func sendErrorMessage(for status: HTTPResponseStatus, l10n: [String: String]) -> String {
    let key: String
    switch status {
    case .conflict: key = "friends_error_duplicate"
    case .notFound: key = "friends_error_no_user"
    default: key = "friends_error_invalid_id"
    }
    return l10n[key] ?? key
  }
}
