import Vapor

struct PageMeta: Content {
  let basePath: String
  let rootURL: String
  let sharedURL: String
  let loginURL: String
  let logoutURL: String
  let l10n: [String: String]

  init(_ req: Request) {
    self.basePath = req.basePath
    self.rootURL = req.rootURL
    self.sharedURL = req.sharedURL
    let returnTo = "\(req.basePath)\(req.url.path)"
    let encodedReturnTo =
      returnTo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "/"
    self.loginURL = "/auth/login?return_to=\(encodedReturnTo)"
    self.logoutURL = "/auth/logout?return_to=\(encodedReturnTo)"
    self.l10n = req.l10n
  }
}
