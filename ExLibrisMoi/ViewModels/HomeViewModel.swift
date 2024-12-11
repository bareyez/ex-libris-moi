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
    
    func addLoan(_ loan: Loan) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // 1. Add the loan document under the user's loans collection
        var loanData = try Firestore.Encoder().encode(loan)
        loanData["lenderId"] = userId
        
        try await db.collection("users")
            .document(userId)
            .collection("loans")
            .addDocument(data: loanData)
        
        // 2. Update book status in the user's books collection
        try await db.collection("users")
            .document(userId)
            .collection("books")
            .document(loan.bookId)
            .updateData(["lendingStatus": Book.LendingStatus.lent.rawValue])
        
        // 3. Notify that the library has changed
        NotificationCenter.default.post(name: .libraryDidChange, object: nil)
    }
} 
