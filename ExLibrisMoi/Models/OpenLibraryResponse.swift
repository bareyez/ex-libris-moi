import Foundation

struct OpenLibraryResponse: Codable {
    let isbn: OpenLibraryBook
    
    enum CodingKeys: String, CodingKey {
        case isbn = "ISBN:"
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // The actual key will be dynamic based on the ISBN
        let key = container.allKeys.first ?? CodingKeys.isbn
        isbn = try container.decode(OpenLibraryBook.self, forKey: key)
    }
}

struct OpenLibraryBook: Codable {
    let title: String
    let authors: [OpenLibraryAuthor]?
    let publishDate: String?
    let publishers: [String]?
    let description: OpenLibraryText?
    let excerpts: [OpenLibraryExcerpt]?
    let subjects: [String]?
    let languages: [OpenLibraryLanguage]?
    
    enum CodingKeys: String, CodingKey {
        case title
        case authors
        case publishDate = "publish_date"
        case publishers
        case description
        case excerpts
        case subjects
        case languages
    }
}

struct OpenLibraryAuthor: Codable {
    let name: String
    let url: String?
}

struct OpenLibraryCover: Codable {
    let small: String?
    let medium: String?
    let large: String?
}

struct OpenLibraryIdentifiers: Codable {
    let isbn13: [String]?
    let isbn10: [String]?
    
    enum CodingKeys: String, CodingKey {
        case isbn13 = "isbn_13"
        case isbn10 = "isbn_10"
    }
}

struct OpenLibraryText: Codable {
    let value: String?
    let type: String?
}

struct OpenLibraryExcerpt: Codable {
    let text: String
    let comment: String?
}

struct OpenLibraryLanguage: Codable {
    let key: String
    let name: String?
} 