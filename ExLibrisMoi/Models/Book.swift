import Foundation
import FirebaseFirestore

struct Book: Identifiable, Codable, Hashable {
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
    
    // Computed property for formatted published date
    var formattedPublishedDate: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        if let date = dateFormatter.date(from: publishedDate) {
            dateFormatter.dateFormat = "MMMM d, yyyy"
            return dateFormatter.string(from: date)
        } else if let date = dateFormatter.date(from: publishedDate + "-01") {
            // Handle year-month format
            dateFormatter.dateFormat = "MMMM yyyy"
            return dateFormatter.string(from: date)
        } else if let year = Int(publishedDate) {
            // Handle year-only format
            return String(year)
        }
        
        return publishedDate
    }
    
    // Computed property for formatted date added
    var formattedDateAdded: String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.string(from: dateAdded)
    }
    
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
    
    // Add this function to conform to Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(isbn)
    }
    
    // Add this function to conform to Equatable (required by Hashable)
    static func == (lhs: Book, rhs: Book) -> Bool {
        lhs.id == rhs.id && lhs.isbn == rhs.isbn
    }
} 
