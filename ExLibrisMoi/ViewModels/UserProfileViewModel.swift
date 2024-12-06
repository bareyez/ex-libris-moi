import Foundation
import FirebaseFirestore
import FirebaseAuth

@MainActor
class UserProfileViewModel: ObservableObject {
    @Published var recentBooks: [Book] = []
    @Published var isLoading = false
    @Published var isFriend = false
    @Published var errorMessage: String?
    
    private let db = Firestore.firestore()
    
    func fetchRecentBooks(for user: User) async {
        guard let userId = user.id else { return }
        isLoading = true
        
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("books")
                .order(by: "dateAdded", descending: true)
                .limit(to: 3)
                .getDocuments()
            
            recentBooks = snapshot.documents.compactMap { document in
                try? document.data(as: Book.self)
            }
            
            isLoading = false
        } catch {
            errorMessage = "Failed to fetch books: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func checkFriendStatus(for user: User) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            let document = try await db.collection("users")
                .document(currentUserId)
                .getDocument()
            
            if let currentUser = try? document.data(as: User.self) {
                isFriend = currentUser.friendIds.contains(user.id!)
            }
        } catch {
            errorMessage = "Failed to check friend status: \(error.localizedDescription)"
        }
    }
    
    func addFriend(_ user: User) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        
        do {
            try await db.collection("users")
                .document(currentUserId)
                .updateData([
                    "friendIds": FieldValue.arrayUnion([user.id!])
                ])
            
            isFriend = true
        } catch {
            errorMessage = "Failed to add friend: \(error.localizedDescription)"
        }
    }
} 