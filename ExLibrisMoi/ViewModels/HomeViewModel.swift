import Foundation
import FirebaseFirestore
import FirebaseAuth

class HomeViewModel: ObservableObject {
    @Published var books: [Book] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func fetchBooks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        isLoading = true
        
        db.collection("users").document(userId).collection("books")
            .order(by: "dateAdded", descending: true)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    print("Debug: Error fetching books - \(error.localizedDescription)")
                    return
                }
                
                self.books = snapshot?.documents.compactMap { document in
                    do {
                        let book = try document.data(as: Book.self)
                        print("Debug: Book cover URL - \(book.coverURL ?? "nil")")
                        return book
                    } catch {
                        print("Debug: Error decoding book - \(error.localizedDescription)")
                        return nil
                    }
                } ?? []
            }
    }
    
    @MainActor
    func refreshBooks() async {
        fetchBooks()
    }
} 
