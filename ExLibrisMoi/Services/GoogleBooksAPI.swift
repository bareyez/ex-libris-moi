import Foundation

class GoogleBooksAPI {
    private let apiKey = Configuration.GoogleBooksAPI.apiKey
    
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
            
            let coverURL = volumeInfo.imageLinks?.getBestQualityURL()
            
            print("Debug: Book details fetched - Title: \(volumeInfo.title)")
            print("Debug: Authors: \(volumeInfo.authors?.joined(separator: ", ") ?? "Unknown")")
            print("Debug: Cover URL: \(coverURL ?? "nil")")
            
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
    let imageLinks: ImageLinks?
    let language: String?
    
    struct ImageLinks: Codable {
        let smallThumbnail: String?
        let thumbnail: String?
        let small: String?
        let medium: String?
        let large: String?
        let extraLarge: String?
        
        func getBestQualityURL() -> String? {
            // Get the thumbnail URL first
            guard let baseURL = thumbnail else {
                return smallThumbnail
            }
            
            // Transform the URL to get the highest quality version
            var highQualityURL = baseURL
                .replacingOccurrences(of: "http:", with: "https:")
            
            // Add zoom parameter for higher quality if not present
            if !highQualityURL.contains("zoom=") {
                highQualityURL += "&zoom=1"
            }
            
            print("Debug: Original thumbnail URL: \(baseURL)")
            print("Debug: Transformed high quality URL: \(highQualityURL)")
            
            return highQualityURL
        }
    }
} 
