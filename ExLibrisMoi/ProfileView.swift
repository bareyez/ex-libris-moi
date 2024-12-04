import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage

struct ProfileView: View {
    @State private var firstName = ""
    @State private var username = ""
    @State private var memberSince = Date()
    @State private var profileImage: UIImage?
    @State private var showImagePicker = false
    @State private var showActionSheet = false
    @State private var sourceType: UIImagePickerController.SourceType = .photoLibrary
    @State private var isUploading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Profile")
                .font(.custom("Georgia", size: 32))
                .padding(.top)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal)
            
            Button(action: {
                showActionSheet = true
            }) {
                if let image = profileImage {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                } else {
                    Circle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: 120, height: 120)
                        .overlay(
                            Image(systemName: "person.fill")
                                .foregroundColor(.gray)
                                .font(.system(size: 50))
                        )
                }
            }
            
            VStack(spacing: 5) {
                Text(firstName)
                    .font(.custom("Georgia", size: 24))
                
                Text("@\(username)")
                    .foregroundColor(.gray)
                
                Text("member since \(memberSince.formatted(.dateTime.year()))")
                    .font(.subheadline)
                    .foregroundColor(.gray)
            }

            Spacer()
            
            Button(action: signOut) {
                Text("log out")
                    .font(.custom("Georgia", size: 18))
                    .frame(width: 100)
                    .padding()
                    .background(Color.red)
                    .foregroundColor(.white)
                    .cornerRadius(25)
            }
            .padding(.bottom)
        }
        .onAppear(perform: loadUserData)
        .sheet(isPresented: $showImagePicker) {
            ImagePicker(image: $profileImage, sourceType: sourceType)
        }
        .actionSheet(isPresented: $showActionSheet) {
            ActionSheet(
                title: Text("Select Photo"),
                buttons: [
                    .default(Text("Photo Library")) {
                        sourceType = .photoLibrary
                        showImagePicker = true
                    },
                    .default(Text("Camera")) {
                        if UIImagePickerController.isSourceTypeAvailable(.camera) {
                            sourceType = .camera
                            showImagePicker = true
                        } else {
                            errorMessage = "Camera is not available"
                            showError = true
                        }
                    },
                    .cancel()
                ]
            )
        }
        .onChange(of: profileImage) { newImage in
            if let image = newImage, isUploading == false {
                uploadProfileImage(image)
            }
        }
        .alert(isPresented: $showError) {
            Alert(title: Text("Upload Error"),
                  message: Text(errorMessage),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    private func loadUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        // Load profile image without triggering upload
        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
        storageRef.getData(maxSize: 4 * 1024 * 1024) { data, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    // Set profileImage directly without triggering upload
                    withAnimation {
                        self.profileImage = image
                    }
                }
            }
        }
        
        Firestore.firestore().collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                firstName = document.data()?["firstName"] as? String ?? ""
                username = document.data()?["username"] as? String ?? ""
                if let timestamp = document.data()?["memberSince"] as? TimeInterval {
                    memberSince = Date(timeIntervalSince1970: timestamp)
                }
            }
        }
    }
    
    private func uploadProfileImage(_ image: UIImage) {
        guard let userId = Auth.auth().currentUser?.uid,
              let imageData = image.jpegData(compressionQuality: 0.5) else { return }
        
        isUploading = true
        let storageRef = Storage.storage().reference().child("profile_images/\(userId).jpg")
        
        storageRef.putData(imageData, metadata: nil) { metadata, error in
            isUploading = false
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
                print("Error uploading image: \(error)")
            }
        }
    }
    
    private func signOut() {
        try? Auth.auth().signOut()
    }
} 