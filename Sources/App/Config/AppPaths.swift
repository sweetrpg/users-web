import Vapor

extension Request {
  var basePath: String {
    Environment.get("INGRESS_BASE_PATH") ?? ""
  }

  var rootURL: String {
    Environment.get("ROOT_URL") ?? "/"
  }

  var sharedURL: String {
    Environment.get("SHARED_URL") ?? "http://localhost:8081"
  }

  func redirectLocal(to path: String) -> Response {
    redirect(to: basePath + path)
  }
}
