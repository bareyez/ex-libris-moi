import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class LendingViewModel: ObservableObject {
    @Published var loans: [Loan] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    
    func fetchLoans() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        print("Debug: Fetching loans for user: \(userId)")
        
        db.collection("users")
            .document(userId)
            .collection("loans")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                    print("Debug: Error fetching loans - \(error.localizedDescription)")
                    return
                }
                
                self.loans = snapshot?.documents.compactMap { document in
                    do {
                        let loan = try document.data(as: Loan.self)
                        print("Debug: Loaded loan - Book ID: \(loan.bookId), Borrower ID: \(loan.borrowerId)")
                        return loan
                    } catch {
                        print("Debug: Error decoding loan - \(error.localizedDescription)")
                        return nil
                    }
                } ?? []
                
                print("Debug: Loaded \(self.loans.count) loans")
            }
    }
    
    func addLoan(_ loan: Loan) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        var loanData = try Firestore.Encoder().encode(loan)
        loanData["lenderId"] = userId
        
        try await db.collection("loans").addDocument(data: loanData)
        
        // Update book status
        try await db.collection("books").document(loan.bookId)
            .updateData(["lendingStatus": "lent"])
    }
    
    func markLoanAsReturned(_ loan: Loan) async throws {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Update the book status back to available
        try await db.collection("users")
            .document(userId)
            .collection("books")
            .document(loan.bookId)
            .updateData(["lendingStatus": Book.LendingStatus.available.rawValue])
        
        // Delete the loan
        try await db.collection("users")
            .document(userId)
            .collection("loans")
            .document(loan.id ?? "")
            .delete()
        
        // Notify that the library has changed
        NotificationCenter.default.post(name: .libraryDidChange, object: nil)
    }
} 