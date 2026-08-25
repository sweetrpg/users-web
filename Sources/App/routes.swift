import Vapor

func routes(_ app: Application) throws {
  app.get("status", "ping") { req -> [String: String] in
    ["status": "ok"]
  }

  try app.register(collection: ProfileController())
}
