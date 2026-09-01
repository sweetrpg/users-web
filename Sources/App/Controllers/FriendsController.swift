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
    let user: LeafUser
    let meta: PageMeta
    let friends: [Friend]
    let incoming: [FriendRequest]
    let outgoing: [FriendRequest]
    let friendCount: Int
    let incomingCount: Int
    let outgoingCount: Int
    /// Which left-rail panel to show first (server-side default; JS also honours location.hash).
    let activePanel: String
    let errorMessage: String?
  }

  func showFriends(req: Request) async throws -> View {
    let user = try await requireUser(req)
    return try await renderFriends(req: req, user: user, activePanel: "friends", errorMessage: nil)
  }

  func sendRequest(req: Request) async throws -> Response {
    let user = try await requireUser(req)

    struct SendForm: Content {
      let identifier: String
    }
    let form = try req.content.decode(SendForm.self)
    let identifier = form.identifier.trimmingCharacters(in: .whitespacesAndNewlines)

    do {
      try await req.usersAPI.sendFriendRequest(
        accessToken: user.accessToken, identifier: identifier)
      return req.redirectLocal(to: "/friends")
    } catch let error as Abort where isClientError(error) {
      let message = sendErrorMessage(for: error.status, l10n: req.l10n)
      return try await renderFriends(
        req: req, user: user, activePanel: "add", errorMessage: message
      ).encodeResponse(for: req)
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
      return try await renderFriends(
        req: req, user: user, activePanel: "friends", errorMessage: message
      ).encodeResponse(for: req)
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
      return try await renderFriends(
        req: req, user: user, activePanel: "incoming", errorMessage: message
      ).encodeResponse(for: req)
    }
  }

  private func requireUser(_ req: Request) async throws -> SessionUser {
    guard let user = await req.currentUser else {
      throw Abort(.unauthorized)
    }
    return user
  }

  private func renderFriends(
    req: Request, user: SessionUser, activePanel: String, errorMessage: String?
  ) async throws -> View {
    do {
      async let friends = req.usersAPI.fetchFriends(accessToken: user.accessToken)
      async let requests = req.usersAPI.fetchFriendRequests(accessToken: user.accessToken)
      let friendList = try await friends
      let requestLists = try await requests
      let view = FriendsView(
        user: LeafUser(user),
        meta: PageMeta(req),
        friends: friendList,
        incoming: requestLists.incoming,
        outgoing: requestLists.outgoing,
        friendCount: friendList.count,
        incomingCount: requestLists.incoming.count,
        outgoingCount: requestLists.outgoing.count,
        activePanel: activePanel,
        errorMessage: errorMessage
      )
      return try await req.view.render("friends", view)
    } catch {
      struct ErrorView: Encodable {
        let user: LeafUser
        let meta: PageMeta
        let errorMessage: String
      }
      return try await req.view.render(
        "friends-error",
        ErrorView(
          user: LeafUser(user),
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
    case .notFound: key = "friends_error_no_match"
    default: key = "friends_error_no_match"
    }
    return l10n[key] ?? key
  }
}
