import Foundation
import FirebaseFirestore

struct Book: Identifiable, Codable {
    @DocumentID var id: String? // Firestore document ID
    let isbn: String
    let title: String
    let author: String
    let coverURL: String?
    let description: String?
    let publishedDate: String
    let publisher: String?
    let language: String?
    let genre: [String]?
    
    // User-specific fields
    var lendingStatus: LendingStatus
    var userRating: Int
    let dateAdded: Date
    
    enum LendingStatus: String, Codable, CaseIterable {
        case available
        case lent
        case reading
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case isbn
        case title
        case author
        case coverURL
        case description
        case publishedDate
        case publisher
        case language
        case genre
        case lendingStatus
        case userRating
        case dateAdded
    }
    
    init(id: String? = nil,
         isbn: String,
         title: String,
         author: String,
         coverURL: String? = nil,
         description: String? = nil,
         publishedDate: String,
         publisher: String? = nil,
         language: String? = nil,
         genre: [String]? = nil,
         lendingStatus: LendingStatus = .available,
         userRating: Int = 0,
         dateAdded: Date = Date()) {
        self.id = id
        self.isbn = isbn
        self.title = title
        self.author = author
        self.coverURL = coverURL
        self.description = description
        self.publishedDate = publishedDate
        self.publisher = publisher
        self.language = language
        self.genre = genre
        self.lendingStatus = lendingStatus
        self.userRating = userRating
        self.dateAdded = dateAdded
    }
} 
