import Foundation
import SwiftUI
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

class BookScannerViewModel: ObservableObject {
    enum APIError: Error {
        case invalidResponse
    }
    
    @Published var scannedBooks: [Book] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    private let openLibraryAPI = OpenLibraryAPI()
    
    func lookupBook(isbn: String) {
        isLoading = true
        errorMessage = nil
        
        Task {
            do {
                let book = try await openLibraryAPI.fetchBook(isbn: isbn)
                print("Debug: Book details - ISBN: \(book.isbn ?? "nil"), Title: \(book.title), Cover URL: \(book.coverURL ?? "nil")")
                await MainActor.run {
                    scannedBooks.append(book)
                    isLoading = false
                }
            } catch OpenLibraryAPI.APIError.noBookFound {
                await MainActor.run {
                    errorMessage = "No book found with this ISBN"
                    isLoading = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Error fetching book: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    func shelveAllBooks() {
        guard let userId = Auth.auth().currentUser?.uid else {
            errorMessage = "User not logged in"
            return
        }
        
        isLoading = true
        
        Task {
            do {
                let batch = db.batch()
                
                for book in scannedBooks {
                    let bookRef = db.collection("users")
                        .document(userId)
                        .collection("books")
                        .document()
                    
                    var coverURL = book.coverURL
                    let openLibraryCoverURL = "https://covers.openlibrary.org/b/isbn/\(book.isbn)-L.jpg"
                    
                    do {
                        coverURL = try await downloadAndStoreBookCover(
                            url: URL(string: openLibraryCoverURL)!,
                            userId: userId,
                            isbn: book.isbn
                        )
                    } catch {
                        print("Debug: Failed to store cover for \(book.title) - \(error.localizedDescription)")
                        coverURL = openLibraryCoverURL
                    }
                    
                    let bookData = Book(
                        id: bookRef.documentID,
                        isbn: book.isbn,
                        title: book.title,
                        author: book.author,
                        coverURL: coverURL,
                        description: book.description,
                        publishedDate: book.publishedDate,
                        publisher: book.publisher,
                        language: book.language,
                        genre: book.genre,
                        lendingStatus: .available,
                        userRating: 0,
                        dateAdded: Date()
                    )
                    
                    try batch.setData(from: bookData, forDocument: bookRef)
                }
                
                try await batch.commit()
                
                await MainActor.run {
                    scannedBooks.removeAll()
                    isLoading = false
                }
            } catch {
                print("Debug: Error saving books - \(error.localizedDescription)")
                await MainActor.run {
                    errorMessage = "Error saving books: \(error.localizedDescription)"
                    isLoading = false
                }
            }
        }
    }
    
    private func downloadAndStoreBookCover(url: URL, userId: String, isbn: String) async throws -> String {
        do {
            let (data, response) = try await URLSession.shared.data(from: url)
            
            guard let httpResponse = response as? HTTPURLResponse,
                  httpResponse.statusCode == 200,
                  !data.isEmpty else {
                throw APIError.invalidResponse
            }
            
            let storageRef = storage.reference()
                .child("users")
                .child(userId)
                .child("book_covers")
                .child("\(isbn).jpg")
            
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let _ = try await storageRef.putData(data, metadata: metadata)
            
            let downloadURL = try await storageRef.downloadURL()
            return downloadURL.absoluteString
        } catch {
            print("Debug: Failed to download/store cover - \(error.localizedDescription)")
            return url.absoluteString
        }
    }
} 
