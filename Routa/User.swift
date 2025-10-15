import Foundation

struct User: Codable, Equatable {
    let id: String
    let email: String
    let displayName: String?
    let bio: String?
    let createdAt: Date

    init(id: String, email: String, displayName: String? = nil, bio: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.bio = bio
        self.createdAt = createdAt
    }
}