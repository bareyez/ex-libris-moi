import Foundation

class OpenLibraryAPI {
    enum APIError: Error {
        case invalidURL
        case noBookFound
        case invalidResponse
        case decodingError(Error)
    }
    
    func fetchBook(isbn: String) async throws -> Book {
        // First try the books API
        do {
            return try await fetchBookDetails(isbn: isbn)
        } catch {
            // If that fails, try the ISBN API
            return try await fetchBookFromISBN(isbn: isbn)
        }
    }
    
    private func fetchBookDetails(isbn: String) async throws -> Book {
        let urlString = "https://openlibrary.org/api/books?bibkeys=ISBN:\(isbn)&format=json&jscmd=data"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        // Check if we got an empty response
        if let jsonString = String(data: data, encoding: .utf8),
           jsonString == "{}" {
            throw APIError.noBookFound
        }
        
        do {
            let decoder = JSONDecoder()
            let response = try decoder.decode([String: OpenLibraryBook].self, from: data)
            
            guard let book = response.first?.value else {
                throw APIError.noBookFound
            }
            
            // Get genres/subjects if available
            let genres = book.subjects?.prefix(5).map { $0 } ?? []
            
            // Construct cover URL using ISBN
            let coverURL = "https://covers.openlibrary.org/b/isbn/\(isbn)-L.jpg"
            
            print("Debug: Book details fetched - Title: \(book.title), Author: \(book.authors?.first?.name ?? "Unknown")")
            print("Debug: Description length: \(book.description?.value?.count ?? 0) characters")
            print("Debug: Publishers: \(book.publishers?.joined(separator: ", ") ?? "None")")
            
            return Book(
                isbn: isbn,
                title: book.title,
                author: book.authors?.first?.name ?? "Unknown Author",
                coverURL: coverURL,
                description: book.description?.value ?? book.excerpts?.first?.text,
                publishedDate: book.publishDate ?? "Unknown",
                publisher: book.publishers?.first,
                language: book.languages?.first?.name,
                genre: Array(genres),
                lendingStatus: .available,
                userRating: 0,
                dateAdded: Date()
            )
        } catch {
            print("Debug: Decoding error - \(error)")
            throw APIError.decodingError(error)
        }
    }
    
    private func fetchBookFromISBN(isbn: String) async throws -> Book {
        let urlString = "https://openlibrary.org/isbn/\(isbn).json"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        struct ISBNResponse: Codable {
            let title: String
            let authors: [Reference]?
            let publishDate: String?
            let covers: [Int]?
            let description: String?
            let publishers: [String]?
            
            enum CodingKeys: String, CodingKey {
                case title
                case authors
                case publishDate = "publish_date"
                case covers
                case description
                case publishers
            }
        }
        
        struct Reference: Codable {
            let key: String
        }
        
        do {
            let response = try JSONDecoder().decode(ISBNResponse.self, from: data)
            
            // Construct cover URL using the ISBN
            let coverURL: String? = "https://covers.openlibrary.org/b/isbn/\(isbn)-L.jpg"
            
            return Book(
                isbn: isbn,
                title: response.title,
                author: "Unknown Author",
                coverURL: coverURL,
                description: response.description,
                publishedDate: response.publishDate ?? "Unknown",
                publisher: response.publishers?.first,
                language: nil,
                genre: nil
            )
        } catch {
            throw APIError.decodingError(error)
        }
    }
    
    // Helper method to fetch author details if needed
    private func fetchAuthor(key: String) async throws -> String {
        let urlString = "https://openlibrary.org\(key).json"
        guard let url = URL(string: urlString) else {
            throw APIError.invalidURL
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        struct AuthorResponse: Codable {
            let name: String
        }
        
        let response = try JSONDecoder().decode(AuthorResponse.self, from: data)
        return response.name
    }
} 