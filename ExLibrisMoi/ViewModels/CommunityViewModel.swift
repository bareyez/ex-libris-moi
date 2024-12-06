import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class CommunityViewModel: ObservableObject {
    @Published var searchText = ""
    @Published var searchResults: [User] = []
    @Published var friends: [User] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func searchUsers() {
        guard !searchText.isEmpty else {
            searchResults = []
            return
        }
        
        isLoading = true
        
        // Search for users where username contains the search text
        db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: searchText.lowercased())
            .whereField("username", isLessThanOrEqualTo: searchText.lowercased() + "\u{f8ff}")
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = error.localizedDescription
                    return
                }
                
                self.searchResults = snapshot?.documents.compactMap { document in
                    try? document.data(as: User.self)
                } ?? []
            }
    }
    
    func addFriend(_ user: User) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            // Add to current user's friends
            try await db.collection("users")
                .document(currentUserId)
                .updateData([
                    "friendIds": FieldValue.arrayUnion([user.id!])
                ])
            
            // Refresh friends list
            await fetchFriends()
        } catch {
            errorMessage = "Failed to add friend: \(error.localizedDescription)"
        }
    }
    
    func fetchFriends() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let document = try await db.collection("users")
                .document(currentUserId)
                .getDocument()
            
            guard let currentUser = try? document.data(as: User.self),
                  !currentUser.friendIds.isEmpty else {
                friends = []
                return
            }
            
            // Fetch all friend documents
            let snapshot = try await db.collection("users")
                .whereField(FieldPath.documentID(), in: currentUser.friendIds)
                .getDocuments()
            
            friends = snapshot.documents.compactMap { document in
                try? document.data(as: User.self)
            }
        } catch {
            errorMessage = "Failed to fetch friends: \(error.localizedDescription)"
        }
    }
} 