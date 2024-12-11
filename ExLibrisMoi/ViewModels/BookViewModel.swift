import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class BookViewModel: ObservableObject {
    @Published var book: Book?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    
    func fetchBook(id: String, ownerId: String? = nil) {
        guard let userId = ownerId ?? Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        print("Debug: Fetching book with ID: \(id) from user: \(userId)")
        
        db.collection("users")
            .document(userId)
            .collection("books")
            .document(id)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                    print("Debug: Error fetching book - \(error.localizedDescription)")
                    return
                }
                
                if let snapshot = snapshot, snapshot.exists {
                    do {
                        self.book = try snapshot.data(as: Book.self)
                        print("Debug: Successfully loaded book: \(self.book?.title ?? "Unknown")")
                    } catch {
                        print("Debug: Error decoding book - \(error.localizedDescription)")
                    }
                } else {
                    print("Debug: No book found with ID: \(id)")
                }
            }
    }
}