import Foundation
import FirebaseFirestore
import FirebaseAuth
import FirebaseStorage
import UIKit

@MainActor
class ProfileViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var profileImageURL: String?
    
    private let storage = Storage.storage()
    private let db = Firestore.firestore()
    
    func uploadProfileImage(_ image: UIImage) async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            errorMessage = "No user logged in"
            return
        }
        
        isLoading = true
        
        do {
            // Get the current user document to check for existing profile picture
            let userDoc = try await db.collection("users").document(currentUserId).getDocument()
            let oldProfilePicURL = userDoc.get("profilePicture") as? String
            
            // Convert image to JPEG data
            guard let imageData = image.jpegData(compressionQuality: 0.7) else {
                errorMessage = "Failed to process image"
                isLoading = false
                return
            }
            
            // Create storage reference for new image
            let storageRef = storage.reference()
                .child("profile_images")
                .child(currentUserId)
                .child("profile.jpg")
            
            print("Debug: Starting image upload")
            
            // Delete old profile picture if it exists
            if let oldURL = oldProfilePicURL {
                do {
                    let oldRef = try await storage.reference(forURL: oldURL)
                    try await oldRef.delete()
                    print("Debug: Old profile picture deleted")
                } catch {
                    print("Debug: Error deleting old profile picture: \(error)")
                    // Continue with upload even if delete fails
                }
            }
            
            // Upload the new image data
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
            
            // Get the download URL
            let downloadURL = try await storageRef.downloadURL()
            let urlString = downloadURL.absoluteString
            
            print("Debug: Image uploaded successfully, URL: \(urlString)")
            
            // Update the user's document with the new profile picture URL
            try await db.collection("users")
                .document(currentUserId)
                .updateData([
                    "profilePicture": urlString,
                    "lastUpdated": FieldValue.serverTimestamp()
                ])
            
            print("Debug: User document updated with new profile picture URL")
            
            // Update local state
            self.profileImageURL = urlString
            
        } catch {
            print("Debug: Error uploading profile picture: \(error)")
            errorMessage = "Failed to upload profile picture: \(error.localizedDescription)"
        }
        
        isLoading = false
    }
    
    func fetchCurrentUserProfile() async {
        guard let currentUserId = Auth.auth().currentUser?.uid else {
            errorMessage = "No user logged in"
            return
        }
        
        do {
            let document = try await db.collection("users")
                .document(currentUserId)
                .getDocument()
            
            if let user = try? document.data(as: User.self) {
                self.profileImageURL = user.photoURL
            }
        } catch {
            print("Debug: Error fetching user profile: \(error)")
            errorMessage = "Failed to fetch profile: \(error.localizedDescription)"
        }
    }
}
