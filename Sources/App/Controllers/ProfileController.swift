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

  func updateProfile(req: Request) async throws -> Response {
    guard let user = await req.currentUser else {
      return req.redirect(to: req.basePath + "/auth/login")
    }

    struct UpdateRequest: Content {
      let name: String
      let bio: String
      let website: String
    }

    let updateReq = try req.content.decode(UpdateRequest.self)

    do {
      _ = try await req.usersAPI.updateProfile(
        accessToken: user.accessToken,
        name: updateReq.name,
        bio: updateReq.bio,
        website: updateReq.website
      )
      return req.redirectLocal(to: "/profile")
    } catch let error as Abort {
      if error.status == .badRequest {
        let profile = try await req.usersAPI.fetchProfile(accessToken: user.accessToken)
        struct ProfileView: Encodable {
          let user: LeafUser
          let meta: PageMeta
          let profile: Profile
          let errorMessage: String?
        }
        let view = ProfileView(
          user: LeafUser(user),
          meta: PageMeta(req),
          profile: profile,
          errorMessage: error.reason
        )
        return try await req.view.render("profile", view).encodeResponse(for: req)
      }
      throw error
    }
  }
}
