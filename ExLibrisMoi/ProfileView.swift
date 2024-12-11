import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import PhotosUI

struct ProfileView: View {
    @StateObject private var viewModel = ProfileViewModel()
    @State private var selectedItem: PhotosPickerItem?
    @State private var selectedImage: UIImage?
    @State private var firstName = ""
    @State private var username = ""
    @State private var memberSince = Date()
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Profile Image Section
                    VStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(width: 120, height: 120)
                        } else {
                            if let imageURL = viewModel.profileImageURL {
                                AsyncImage(url: URL(string: imageURL)) { phase in
                                    switch phase {
                                    case .success(let image):
                                        image
                                            .resizable()
                                            .aspectRatio(contentMode: .fill)
                                            .frame(width: 120, height: 120)
                                            .clipShape(Circle())
                                            .shadow(radius: 3)
                                    case .failure(_):
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 120, height: 120)
                                            .foregroundColor(.gray)
                                    case .empty:
                                        ProgressView()
                                    @unknown default:
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 120, height: 120)
                                            .foregroundColor(.gray)
                                    }
                                }
                            } else {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray)
                            }
                        }
                        
                        // Photo Picker Button
                        PhotosPicker(selection: $selectedItem,
                                   matching: .images,
                                   photoLibrary: .shared()) {
                            Text("Change Profile Picture")
                                .font(.headline)
                        }
                        .padding(.top, 8)
                    }
                    .padding()
                    
                    if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .padding()
                    }
                    
                    // Profile Information Section
                    VStack(spacing: 5) {
                        Text(firstName)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        Text("@\(username)")
                            .foregroundColor(.gray)
                        
                        Text("member since \(memberSince.formatted(.dateTime.year()))")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    
                    Spacer()
                    
                    Button(action: signOut) {
                        Text("log out")
                            .frame(width: 100)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(25)
                    }
                    .padding(.bottom)
                    
                }
            }
            .navigationTitle("Profile")
        }
        .onChange(of: selectedItem) { newItem in
            Task {
                if let data = try? await newItem?.loadTransferable(type: Data.self),
                   let image = UIImage(data: data) {
                    selectedImage = image
                    await viewModel.uploadProfileImage(image)
                }
            }
        }
        .task {
            await viewModel.fetchCurrentUserProfile()
            await loadUserData()
        }
    }
    
    private func loadUserData() async {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                firstName = document.get("firstName") as? String ?? ""
                username = document.get("username") as? String ?? ""
                if let timestamp = document.get("memberSince") as? Timestamp {
                    memberSince = timestamp.dateValue()
                }
            }
        }
    }
    
    private func signOut() {
        try? Auth.auth().signOut()
    }
}