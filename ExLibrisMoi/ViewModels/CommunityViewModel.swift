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
        let searchLowerCase = searchText.lowercased()
        
        db.collection("users")
            .whereField("username", isGreaterThanOrEqualTo: searchLowerCase)
            .whereField("username", isLessThanOrEqualTo: searchLowerCase + "\u{f8ff}")
            .limit(to: 10)
            .getDocuments { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let snapshot = snapshot {
                    self.searchResults = snapshot.documents.compactMap { document in
                        do {
                            print("Debug: Processing document ID: \(document.documentID)")
                            var user = try document.data(as: User.self)
                            user.setId(document.documentID)
                            print("Debug: Final user - ID: \(user.id ?? "nil"), Username: \(user.username)")
                            return user
                        } catch {
                            print("Debug: Error decoding user document: \(error)")
                            return nil
                        }
                    }
                }
                self.isLoading = false
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
                do {
                    print("Debug: Processing friend document ID: \(document.documentID)")
                    var friend = try document.data(as: User.self)
                    friend.setId(document.documentID)  // Set the document ID explicitly
                    print("Debug: Decoded friend - ID: \(friend.id ?? "nil"), Username: \(friend.username)")
                    return friend
                } catch {
                    print("Debug: Error decoding friend document: \(error)")
                    return nil
                }
            }
            
            print("Debug: Fetched \(friends.count) friends")
        } catch {
            errorMessage = "Failed to fetch friends: \(error.localizedDescription)"
            print("Debug: Error fetching friends: \(error.localizedDescription)")
        }
    }
} 