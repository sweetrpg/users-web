import Vapor

struct AuthRequiredMiddleware: AsyncMiddleware {
  private static let unauthenticatedPaths: Set<String> = [
    "/status/ping"
  ]

  func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
    let path = request.url.path
    if Self.unauthenticatedPaths.contains(path) || path.hasPrefix("/public/") {
      return try await next.respond(to: request)
    }

    guard await request.currentUser != nil else {
      let returnTo = "\(request.basePath)\(path)"
      let encodedReturnTo =
        returnTo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "/"
      return request.redirect(to: "/auth/login?return_to=\(encodedReturnTo)")
    }

    return try await next.respond(to: request)
  }
}
