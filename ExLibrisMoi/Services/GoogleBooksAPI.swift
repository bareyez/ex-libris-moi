import Foundation

class GoogleBooksAPI {
    //private let apiKey = Configuration.GoogleBooksAPI.apiKey
    private let apiKey = Configuration.GOOGLE_BOOKS_API_KEY
    enum APIError: Error {
        case invalidURL
        case noBookFound
        case invalidResponse
        case decodingError(Error)
    }
    
    func fetchBook(isbn: String) async throws -> Book {
        let urlString = "https://www.googleapis.com/books/v1/volumes?q=isbn:\(isbn)&key=\(apiKey)"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        do {
            let response = try JSONDecoder().decode(GoogleBooksResponse.self, from: data)
            
            guard let volumeInfo = response.items?.first?.volumeInfo else {
                throw APIError.noBookFound
            }
            
            // Use Open Library cover URL instead of Google Books
            let coverURL = "https://covers.openlibrary.org/b/isbn/\(isbn)-L.jpg"
            
            print("Debug: Book details fetched - Title: \(volumeInfo.title)")
            print("Debug: Authors: \(volumeInfo.authors?.joined(separator: ", ") ?? "Unknown")")
            print("Debug: Cover URL: \(coverURL)")
            
            return Book(
                isbn: isbn,
                title: volumeInfo.title,
                author: volumeInfo.authors?.first ?? "Unknown Author",
                coverURL: coverURL,
                description: volumeInfo.description,
                publishedDate: volumeInfo.publishedDate ?? "Unknown",
                publisher: volumeInfo.publisher,
                language: languageCodeToName(volumeInfo.language ?? ""),
                genre: volumeInfo.categories,
                lendingStatus: .available,
                userRating: 0,
                dateAdded: Date()
            )
        } catch {
            print("Debug: Decoding error - \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    private func languageCodeToName(_ code: String) -> String {
        let locale = Locale(identifier: code)
        return locale.localizedString(forLanguageCode: code) ?? code.uppercased()
    }
}

// MARK: - Response Models
struct GoogleBooksResponse: Codable {
    let items: [Volume]?
}

struct Volume: Codable {
    let volumeInfo: VolumeInfo
}

struct VolumeInfo: Codable {
    let title: String
    let authors: [String]?
    let publisher: String?
    let publishedDate: String?
    let description: String?
    let categories: [String]?
    let language: String?
} 
