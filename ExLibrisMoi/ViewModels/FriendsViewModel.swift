import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class FriendsViewModel: ObservableObject {
    @Published var friends: [User] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private let db = Firestore.firestore()
    
    func fetchFriends() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        isLoading = true
        
        // For testing purposes, let's fetch all users except the current user
        db.collection("users")
            .whereField(FieldPath.documentID(), isNotEqualTo: userId)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                    print("Debug: Error fetching friends - \(error.localizedDescription)")
                    return
                }
                
                self.friends = snapshot?.documents.compactMap { document in
                    do {
                        var user = try document.data(as: User.self)
                        // Explicitly set the document ID
                        user.setId(document.documentID)
                        print("Debug: Loaded user - ID: \(user.id ?? "nil"), Username: \(user.username)")
                        return user
                    } catch {
                        print("Debug: Error decoding user - \(error.localizedDescription)")
                        return nil
                    }
                } ?? []
                
                print("Debug: Loaded \(self.friends.count) friends")
                self.friends.forEach { friend in
                    print("Debug: Friend - ID: \(friend.id ?? "nil"), Username: \(friend.username)")
                }
            }
        
        // Once you implement the friends feature, use this code instead:
        /*
        db.collection("users")
            .document(userId)
            .collection("friends")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                self.isLoading = false
                
                if let error = error {
                    self.error = error
                    return
                }
                
                let friendIds = snapshot?.documents.compactMap { $0.documentID } ?? []
                
                if friendIds.isEmpty {
                    self.friends = []
                    return
                }
                
                // Fetch friend details
                db.collection("users")
                    .whereField(FieldPath.documentID(), in: friendIds)
                    .getDocuments { snapshot, error in
                        if let error = error {
                            self.error = error
                            return
                        }
                        
                        self.friends = snapshot?.documents.compactMap { document in
                            try? document.data(as: User.self)
                        } ?? []
                    }
            }
        */
    }
}