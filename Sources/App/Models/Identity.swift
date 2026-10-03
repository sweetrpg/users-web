import Vapor

/// One linked login method, as returned by users-api `GET /api/identities` (server/identities.go's
/// linkedIdentityResponse) - a bare JSON array of camelCase objects, not a wrapped
/// {"identities": [...]} object.
struct Identity: Content {
  let id: String
  let connectionType: String
  /// Kept as the raw string users-api returns rather than parsed to Date - Leaf renders it
  /// as-is and this view has no need to reformat it.
  let linkedAt: String

  enum CodingKeys: String, CodingKey {
    case id = "loginProfileId"
    case connectionType
    case linkedAt
  }
}
