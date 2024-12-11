import Foundation
import FirebaseFirestore

struct User: Identifiable, Codable {
    @DocumentID var id: String?
    var username: String
    var firstName: String?
    var lastName: String?
    var photoURL: String?
    var friendIds: [String]
    
    enum CodingKeys: String, CodingKey {
        case id
        case username
        case firstName
        case lastName
        case photoURL = "profilePicture"
        case friendIds
    }
    
    // Add a mutating function to set the ID
    mutating func setId(_ id: String) {
        self.id = id
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        // First initialize all properties
        id = try container.decodeIfPresent(String.self, forKey: .id)
        username = try container.decode(String.self, forKey: .username)
        firstName = try container.decodeIfPresent(String.self, forKey: .firstName)
        lastName = try container.decodeIfPresent(String.self, forKey: .lastName)
        photoURL = try container.decodeIfPresent(String.self, forKey: .photoURL)
        friendIds = try container.decodeIfPresent([String].self, forKey: .friendIds) ?? []
    }
}