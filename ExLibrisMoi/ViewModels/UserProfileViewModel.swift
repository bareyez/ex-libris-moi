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
        guard let userId = user.id else {
            print("Debug: User ID is nil")
            return
        }
        
        guard userId == Auth.auth().currentUser?.uid || isFriend else {
            print("Debug: Not authorized to view books")
            return
        }
        
        print("Debug: Starting to fetch books for user \(userId)")
        isLoading = true
        
        do {
            let snapshot = try await db.collection("users")
                .document(userId)
                .collection("books")
                .order(by: "dateAdded", descending: true)
                .limit(to: 15)
                .getDocuments()
            
            print("Debug: Retrieved \(snapshot.documents.count) books")
            
            recentBooks = snapshot.documents.compactMap { document in
                do {
                    let book = try document.data(as: Book.self)
                    print("Debug: Successfully decoded book: \(book.title)")
                    return book
                } catch {
                    print("Debug: Failed to decode book: \(error.localizedDescription)")
                    return nil
                }
            }
            
            isLoading = false
            
            if recentBooks.isEmpty {
                print("Debug: No books found for user")
            } else {
                print("Debug: Successfully loaded \(recentBooks.count) books")
            }
            
        } catch {
            print("Debug: Error fetching books: \(error.localizedDescription)")
            errorMessage = "Failed to fetch books: \(error.localizedDescription)"
            isLoading = false
        }
    }
    
    func checkFriendStatus(for user: User) async {
        guard let currentUserId = Auth.auth().currentUser?.uid,
              currentUserId != user.id else {
            isFriend = true
            return
        }
        
        guard let targetUserId = user.id else {
            print("Debug: No target user ID")
            return
        }
        
        do {
            let document = try await db.collection("users")
                .document(currentUserId)
                .getDocument()
            
            if let currentUser = try? document.data(as: User.self) {
                isFriend = currentUser.friendIds.contains(targetUserId)
                print("Debug: Friend status checked - isFriend: \(isFriend)")
            }
        } catch {
            print("Debug: Error checking friend status: \(error.localizedDescription)")
        }
    }
    
    func addFriend(_ user: User) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            errorMessage = "You must be logged in to add friends"
            print("Debug: Current user not logged in")
            return
        }
        
        guard let targetUserId = user.id else {
            print("Debug: Target user has no ID - Username: \(user.username)")
            errorMessage = "Unable to add friend: Invalid user ID"
            return
        }
        
        print("Debug: Adding friend - Current User ID: \(currentUserId)")
        print("Debug: Target User - ID: \(targetUserId), Username: \(user.username)")
        
        do {
            try await db.collection("users")
                .document(currentUserId)
                .updateData([
                    "friendIds": FieldValue.arrayUnion([targetUserId])
                ])
            
            print("Debug: Successfully added friend to friendIds array")
            isFriend = true
            await fetchRecentBooks(for: user)
        } catch {
            print("Debug: Failed to add friend - Error: \(error.localizedDescription)")
            errorMessage = "Failed to add friend: \(error.localizedDescription)"
        }
    }
}