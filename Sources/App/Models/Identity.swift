import Vapor

/// One linked login method, as returned by users-api `GET /identities`.
struct Identity: Content {
  let id: String
  let connectionType: String
  /// Kept as the raw string users-api returns rather than parsed to Date - Leaf renders it
  /// as-is and this view has no need to reformat it.
  let linkedAt: String

  enum CodingKeys: String, CodingKey {
    case id
    case connectionType = "connection_type"
    case linkedAt = "linked_at"
  }
}

struct IdentitiesResponse: Content {
  let identities: [Identity]
}
