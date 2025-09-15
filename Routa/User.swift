import Foundation

struct User: Codable, Equatable {
    let id: String
    let email: String
    let displayName: String?
    let createdAt: Date
    
    init(id: String, email: String, displayName: String? = nil, createdAt: Date = Date()) {
        self.id = id
        self.email = email
        self.displayName = displayName
        self.createdAt = createdAt
    }
}