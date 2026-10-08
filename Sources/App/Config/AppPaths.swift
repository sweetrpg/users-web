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

  /// Same-origin path to the feedback-widget's submission endpoint, routed through the Ingress
  /// (see sweetrpg/platform's add-anonymous-feedback-reporting change) - no CORS needed since
  /// it never leaves this app's own origin. Override via env var for local development.
  var feedbackApiURL: String {
    Environment.get("FEEDBACK_API_URL") ?? "/api/0/users/feedback"
  }

  func redirectLocal(to path: String) -> Response {
    redirect(to: basePath + path)
  }
}
