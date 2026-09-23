import Vapor

/// Account settings - linked login methods (link-user-accounts). "Link another login method"
/// is a plain link into auth-web's `/auth/link/start` (same pattern as PageMeta's loginURL) -
/// auth-web owns the Auth0 round trip and redirects back here with a `link` query param
/// indicating the outcome; this controller never calls auth-web directly.
struct SettingsController: RouteCollection {
  func boot(routes: RoutesBuilder) throws {
    let settings = routes.grouped("settings")
    settings.get(use: showSettings)
    settings.post("identities", ":id", "unlink", use: unlinkIdentity)
  }

  private struct SettingsView: Encodable {
    let user: LeafUser
    let meta: PageMeta
    let identities: [Identity]
    let linkStartURL: String
    let linkOutcome: String?
    let errorMessage: String?
  }

  func showSettings(req: Request) async throws -> View {
    let user = try await requireUser(req)
    let linkOutcome = req.query[String.self, at: "link"]
    return try await renderSettings(
      req: req, user: user, linkOutcome: linkOutcome, errorMessage: nil)
  }

  func unlinkIdentity(req: Request) async throws -> Response {
    let user = try await requireUser(req)
    let id = try req.parameters.require("id")
    do {
      try await req.usersAPI.unlinkIdentity(accessToken: user.accessToken, id: id)
      return req.redirectLocal(to: "/settings")
    } catch let error as Abort where error.status == .conflict {
      let message =
        req.l10n["settings_error_last_identity"] ?? "You can't remove your last login method."
      return try await renderSettings(
        req: req, user: user, linkOutcome: nil, errorMessage: message
      ).encodeResponse(for: req)
    } catch let error as Abort where (400..<500).contains(error.status.code) {
      let message = req.l10n["settings_error_action"] ?? "That action could not be completed."
      return try await renderSettings(
        req: req, user: user, linkOutcome: nil, errorMessage: message
      ).encodeResponse(for: req)
    } catch {
      req.logger.error("failed to unlink identity via users-api: \(error)")
      let message = req.l10n["settings_error_action"] ?? "That action could not be completed."
      return try await renderSettings(
        req: req, user: user, linkOutcome: nil, errorMessage: message
      ).encodeResponse(for: req)
    }
  }

  // MARK: - Helpers

  private func requireUser(_ req: Request) async throws -> SessionUser {
    guard let user = await req.currentUser else {
      throw Abort(.unauthorized)
    }
    return user
  }

  private func renderSettings(
    req: Request, user: SessionUser, linkOutcome: String?, errorMessage: String?
  ) async throws -> View {
    let returnTo = "\(req.basePath)/settings"
    let encodedReturnTo =
      returnTo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "/settings"
    let linkStartURL = "/auth/link/start?return_to=\(encodedReturnTo)"

    do {
      let identities = try await req.usersAPI.fetchIdentities(accessToken: user.accessToken)
      let view = SettingsView(
        user: LeafUser(user),
        meta: PageMeta(req),
        identities: identities,
        linkStartURL: linkStartURL,
        linkOutcome: linkOutcome,
        errorMessage: errorMessage
      )
      return try await req.view.render("settings", view)
    } catch {
      req.logger.error("failed to fetch identities from users-api: \(error)")
      struct ErrorView: Encodable {
        let user: LeafUser
        let meta: PageMeta
        let errorMessage: String
      }
      return try await req.view.render(
        "settings-error",
        ErrorView(
          user: LeafUser(user),
          meta: PageMeta(req),
          errorMessage: req.l10n["settings_error_load"] ?? "Failed to load account settings.")
      )
    }
  }
}
