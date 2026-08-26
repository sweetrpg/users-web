import Leaf
import LingoVapor
import Logging
import Redis
import Vapor

public func configure(_ app: Application) async throws {
  app.http.server.configuration.hostname = "0.0.0.0"
  app.http.server.configuration.port = Environment.get("PORT").flatMap(Int.init) ?? 8080

  app.views.use(.leaf)

  app.lingoVapor.configuration = .init(
    defaultLocale: "en", localizationsDir: "Resources/Localizations")

  try I18n.loadTables()

  app.middleware.use(FileMiddleware(publicDirectory: app.directory.publicDirectory))

  // auth-web's own dedicated Redis instance, read-only from here - the shared session store
  // every frontend reads. A distinct connection from any future app-local Redis this app might
  // add for its own purposes - see SessionUserAccess.swift and catalog-web's own configure.swift
  // for the precedent this mirrors.
  if let sharedSessionRedisHost = Environment.get("SHARED_SESSION_REDIS_HOST"),
    !sharedSessionRedisHost.isEmpty
  {
    let sharedSessionRedisPort =
      Environment.get("SHARED_SESSION_REDIS_PORT").flatMap(Int.init) ?? 6379
    // Must match auth-web's own REDIS_DB (DB 2 in every deployed environment) - auth-web is the
    // sole writer of this store, so reading from the wrong DB index silently degrades to "every
    // visitor reads as logged-out" the same way an unreachable host does.
    let sharedSessionRedisDB = Environment.get("SHARED_SESSION_REDIS_DB").flatMap(Int.init) ?? 2
    app.redis(.sharedSession).configuration = try RedisConfiguration(
      hostname: sharedSessionRedisHost,
      port: sharedSessionRedisPort,
      password: Environment.get("SHARED_SESSION_REDIS_PASS"),
      database: sharedSessionRedisDB
    )
    app.sharedSessionRedisConfigured = true
  } else {
    app.logger.warning(
      "SHARED_SESSION_REDIS_HOST not set - every visitor will read as logged-out."
    )
  }

  app.middleware.use(AuthRequiredMiddleware())

  try routes(app)
}
