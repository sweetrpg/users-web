import Vapor

/// One entry in the caller's accepted-friend list, as returned by users-api `GET /friends`.
/// name/email are best-effort - empty when the other user has no profile document yet, in which
/// case templates fall back to showing `userID`.
struct Friend: Content {
  let userID: String
  let name: String
  let email: String

  enum CodingKeys: String, CodingKey {
    case userID = "user_id"
    case name
    case email
  }
}

/// One pending friend request involving the caller, from users-api `GET /friends/requests`.
struct FriendRequest: Content {
  let id: String
  let userID: String
  let name: String
  let email: String

  enum CodingKeys: String, CodingKey {
    case id
    case userID = "user_id"
    case name
    case email
  }
}

struct FriendsResponse: Content {
  let friends: [Friend]
}

struct FriendRequestsResponse: Content {
  let incoming: [FriendRequest]
  let outgoing: [FriendRequest]
}
