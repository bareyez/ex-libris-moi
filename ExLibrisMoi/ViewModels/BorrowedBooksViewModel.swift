import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class BorrowedBooksViewModel: ObservableObject {
    @Published var loans: [Loan] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    
    func fetchBorrowedBooks() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        print("Debug: Fetching borrowed books for user: \(userId)")
        
        // Query all users' loans where borrowerId matches current user
        db.collectionGroup("loans")
            .whereField("borrowerId", isEqualTo: userId)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                    print("Debug: Error fetching borrowed books - \(error.localizedDescription)")
                    return
                }
                
                self.loans = snapshot?.documents.compactMap { document in
                    do {
                        let loan = try document.data(as: Loan.self)
                        return loan
                    } catch {
                        print("Debug: Error decoding borrowed book - \(error.localizedDescription)")
                        return nil
                    }
                } ?? []
                
                print("Debug: Loaded \(self.loans.count) borrowed books")
            }
    }
} 
