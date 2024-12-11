import Foundation
import FirebaseFirestore

@MainActor
class UserViewModel: ObservableObject {
    @Published var user: User?
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    
    func fetchUser(id: String) {
        isLoading = true
        
        db.collection("users").document(id)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                    return
                }
                
                self.user = try? snapshot?.data(as: User.self)
            }
    }
}