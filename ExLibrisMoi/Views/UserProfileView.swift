import SwiftUI
import FirebaseAuth

struct UserProfileView: View {
    let user: User
    @StateObject private var viewModel = UserProfileViewModel()
    @State private var showingErrorAlert = false
    
    // Update grid layout to maintain consistent spacing
    private let gridItems = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile header
                VStack(spacing: 12) {
                    // Profile Image
                    if let photoURL = user.photoURL, let url = URL(string: photoURL) {
                        AsyncImage(url: url) { phase in
                            switch phase {
                            case .success(let image):
                                image
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: 120, height: 120)
                                    .clipShape(Circle())
                                    .shadow(radius: 3)
                                    .onAppear {
                                        print("Debug: Successfully loaded profile image")
                                    }
                            case .failure(let error):
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 120, height: 120)
                                    .foregroundColor(.gray)
                                    .onAppear {
                                        print("Debug: Failed to load profile image: \(error)")
                                    }
                            case .empty:
                                ProgressView()
                                    .frame(width: 120, height: 120)
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
                            .onAppear {
                                print("Debug: No profile image URL available")
                            }
                    }
                    
                    // User Info
                    VStack(spacing: 8) {
                        if let firstName = user.firstName, let lastName = user.lastName {
                            Text("\(firstName) \(lastName)")
                                .font(.title2)
                            .bold()
                        }
                        
                        Text("@\(user.username)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                .onAppear {
                    print("Debug: Loading profile for user: \(user.username)")
                    if let photoURL = user.photoURL {
                        print("Debug: Profile photo URL: \(photoURL)")
                    }
                }
                
                // Add Friend Button - Only show if not already friends
                if !viewModel.isFriend && user.id != Auth.auth().currentUser?.uid {
                    Button(action: {
                        Task {
                            await viewModel.addFriend(user)
                        }
                    }) {
                        Label("Add Friend", systemImage: "person.badge.plus")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding(.horizontal)
                }
                
                // Recent books section with grid
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recently Added Books")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if let errorMessage = viewModel.errorMessage {
                        Text(errorMessage)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else if viewModel.recentBooks.isEmpty {
                        Text("No books added yet")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity)
                            .padding()
                    } else {
                        LazyVGrid(columns: gridItems, spacing: 12) {
                            ForEach(viewModel.recentBooks) { book in
                                BookCoverView(book: book)
                                    .aspectRatio(2/3, contentMode: .fit)
                                    .cornerRadius(8)
                                    .shadow(radius: 2)
                            }
                        }
                        .padding(.horizontal)
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            print("Debug: Starting to fetch user data for: \(user.username) with ID: \(user.id ?? "nil")")
            // First check friend status
            await viewModel.checkFriendStatus(for: user)
            // Then fetch books if it's the current user or a friend
            if user.id == Auth.auth().currentUser?.uid || viewModel.isFriend {
                await viewModel.fetchRecentBooks(for: user)
            }
        }
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}
