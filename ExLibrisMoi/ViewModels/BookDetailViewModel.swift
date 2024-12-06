import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage

@MainActor
class BookDetailViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    func deleteBook(_ book: Book) async {
        guard let userId = Auth.auth().currentUser?.uid,
              let bookId = book.id else {
            print("Debug: Cannot delete book - missing userId or bookId")
            return
        }
        
        isLoading = true
        print("Debug: Starting deletion for book: \(book.title)")
        
        do {
            // Delete the book document from Firestore
            try await db.collection("users")
                .document(userId)
                .collection("books")
                .document(bookId)
                .delete()
            
            print("Debug: Successfully deleted book document from Firestore")
            
            // Delete the cover image if it exists in Firebase Storage
            if let coverURL = book.coverURL {
                print("Debug: Attempting to delete cover image: \(coverURL)")
                
                // Create storage reference directly without checking URL
                let storageRef = storage.reference()
                    .child("users")
                    .child(userId)
                    .child("book_covers")
                    .child("\(book.isbn).jpg")
                
                do {
                    // Check if file exists before trying to delete
                    _ = try await storageRef.getMetadata()
                    try await storageRef.delete()
                    print("Debug: Successfully deleted cover image from Storage")
                } catch let error as NSError {
                    if error.domain == StorageErrorDomain,
                       error.code == StorageErrorCode.objectNotFound.rawValue {
                        print("Debug: No cover image found in storage for this book")
                    } else {
                        print("Debug: Failed to delete cover image - \(error.localizedDescription)")
                    }
                    // Continue even if image deletion fails
                }
            }
            
            isLoading = false
            print("Debug: Book deletion completed successfully")
            // Post notification that library has changed
            NotificationCenter.default.post(name: .libraryDidChange, object: nil)
        } catch {
            print("Debug: Failed to delete book - \(error.localizedDescription)")
            errorMessage = "Failed to delete book: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func updateBookRating(_ book: Book, rating: Int) async {
        guard let userId = Auth.auth().currentUser?.uid,
              let bookId = book.id else {
            print("Debug: Cannot update rating - missing userId or bookId")
            return
        }
        
        do {
            try await db.collection("users")
                .document(userId)
                .collection("books")
                .document(bookId)
                .updateData([
                    "userRating": rating
                ])
            
            print("Debug: Successfully updated rating to \(rating) for book: \(book.title)")
            NotificationCenter.default.post(name: .libraryDidChange, object: nil)
        } catch {
            print("Debug: Failed to update rating - \(error.localizedDescription)")
            errorMessage = "Failed to update rating: \(error.localizedDescription)"
        }
    }
} 