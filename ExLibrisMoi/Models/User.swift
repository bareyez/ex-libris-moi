import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    let username: String
    let displayName: String
    let photoURL: String?
    var friendIds: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case displayName
        case photoURL
        case friendIds
    }
} 