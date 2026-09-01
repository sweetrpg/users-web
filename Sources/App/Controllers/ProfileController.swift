import Vapor

struct ProfileController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    routes.get("profile", use: showProfile)
    routes.post("profile", use: updateProfile)
  }

  func showProfile(req: Request) async throws -> View {
    guard let user = await req.currentUser else {
      throw Abort(.unauthorized)
    }

    let profile: Profile
    do {
      profile = try await req.usersAPI.fetchProfile(accessToken: user.accessToken)
    } catch {
      req.logger.error("failed to fetch profile from users-api: \(error)")
      struct ErrorView: Encodable {
        let user: LeafUser
        let meta: PageMeta
        let errorMessage: String
      }
      return try await req.view.render(
        "profile-error",
        ErrorView(user: LeafUser(user), meta: PageMeta(req), errorMessage: "Failed to load profile")
      )
    }

    struct ProfileView: Encodable {
      let user: LeafUser
      let meta: PageMeta
      let profile: Profile
      let errorMessage: String?
    }
    return try await req.view.render(
      "profile",
      ProfileView(user: LeafUser(user), meta: PageMeta(req), profile: profile, errorMessage: nil)
    )
  }

  /// Backs the profile page's inline-edit fields (see profile.leaf's script) - each field save
  /// is its own JSON fetch(), not a full-page form submit, so this always responds with JSON
  /// rather than a redirect or re-rendered HTML page.
  func updateProfile(req: Request) async throws -> Response {
    struct ErrorBody: Content { let message: String }

    guard let user = await req.currentUser else {
      let res = Response(status: .unauthorized)
      try res.content.encode(ErrorBody(message: "session expired"))
      return res
    }

    struct UpdateRequest: Content {
      let name: String
      let bio: String
      let website: String
      let username: String?
    }
    let updateReq = try req.content.decode(UpdateRequest.self)

    do {
      let profile = try await req.usersAPI.updateProfile(
        accessToken: user.accessToken,
        name: updateReq.name,
        bio: updateReq.bio,
        website: updateReq.website,
        username: updateReq.username ?? ""
      )
      let res = Response(status: .ok)
      try res.content.encode(profile)
      return res
    } catch let error as Abort {
      let res = Response(status: error.status)
      try res.content.encode(ErrorBody(message: error.reason))
      return res
    }
  }
}
