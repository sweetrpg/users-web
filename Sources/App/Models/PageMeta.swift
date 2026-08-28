import Vapor

struct PageMeta: Content {
  let basePath: String
  let rootURL: String
  let sharedURL: String
  let buildVersion: String
  let buildDate: String
  let buildHash: String
  let loginURL: String
  let logoutURL: String
  let adminURL: String
  let userSettingsURL: String
  let l10n: [String: String]

  init(_ req: Request) {
    self.basePath = req.basePath
    self.rootURL = req.rootURL
    self.sharedURL = req.sharedURL
    self.buildVersion = req.buildInfo.version
    self.buildDate = req.buildInfo.date
    self.buildHash = String(req.buildInfo.sha.prefix(8))
    let returnTo = "\(req.basePath)\(req.url.path)"
    let encodedReturnTo =
      returnTo.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "/"
    self.loginURL = "/auth/login?return_to=\(encodedReturnTo)"
    self.logoutURL = "/auth/logout?return_to=\(encodedReturnTo)"
    self.adminURL = "/admin"
    self.userSettingsURL = "/users/profile"
    self.l10n = req.l10n
  }
}
