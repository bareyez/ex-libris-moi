import SwiftUI

struct CommunityView: View {
    @StateObject private var viewModel = CommunityViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar in a fixed position
                VStack(spacing: 0) {
                    SearchBar(text: $viewModel.searchText, placeholder: "Search friends by username...")
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled(true)
                        .onChange(of: viewModel.searchText) { newValue in
                            viewModel.searchText = newValue.lowercased()
                            viewModel.searchUsers()
                        }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
                .background(Color(.systemBackground))
                
                // Content area
                ScrollView {
                    // Search Results Section (only show when searching)
                    if !viewModel.searchText.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Search Results")
                                .font(.headline)
                                .padding(.horizontal)
                            
                            if viewModel.isLoading {
                                ProgressView()
                                    .frame(maxWidth: .infinity)
                            } else if viewModel.searchResults.isEmpty {
                                Text("No users found")
                                    .foregroundColor(.secondary)
                                    .frame(maxWidth: .infinity)
                            } else {
                                ForEach(viewModel.searchResults) { user in
                                    NavigationLink(destination: UserProfileView(user: user)) {
                                        UserRow(user: user)
                                    }
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                    
                    // Friends List Section
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Friends")
                            .font(.headline)
                            .padding(.horizontal)
                        
                        if viewModel.friends.isEmpty {
                            Text("No friends added yet")
                                .foregroundColor(.secondary)
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ForEach(viewModel.friends) { friend in
                                NavigationLink(destination: UserProfileView(user: friend)) {
                                    FriendRow(user: friend)
                                }
                            }
                        }
                    }
                    .padding(.vertical)
                }
                .scrollDismissesKeyboard(.immediately)
            }
            .navigationTitle("Community")
            .task {
                // Fetch friends when view appears
                await viewModel.fetchFriends()
            }
        }
    }
}

struct UserRow: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            Group {
                if let photoURL = user.photoURL,
                   !photoURL.isEmpty,
                   let url = URL(string: photoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                        case .failure(_):
                            DefaultProfileImage()
                        case .empty:
                            ProgressView()
                                .frame(width: 50, height: 50)
                        @unknown default:
                            DefaultProfileImage()
                        }
                    }
                } else {
                    DefaultProfileImage()
                }
            }
            .frame(width: 50, height: 50)
            
            // User Info
            VStack(alignment: .leading, spacing: 4) {
                Text("@\(user.username)")
                    .font(.headline)
                    .foregroundColor(.blue)
                
                if let firstName = user.firstName, let lastName = user.lastName {
                    Text("\(firstName) \(lastName)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}

// Helper view for default profile image
struct DefaultProfileImage: View {
    var body: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .foregroundColor(.gray)
            .frame(width: 50, height: 50)
    }
}

// Simplified row for friends list
struct FriendRow: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile Image
            Group {
                if let photoURL = user.photoURL,
                   !photoURL.isEmpty,
                   let url = URL(string: photoURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                        case .failure(_):
                            DefaultProfileImage()
                                .frame(width: 40, height: 40)
                        case .empty:
                            ProgressView()
                                .frame(width: 40, height: 40)
                        @unknown default:
                            DefaultProfileImage()
                                .frame(width: 40, height: 40)
                        }
                    }
                } else {
                    DefaultProfileImage()
                        .frame(width: 40, height: 40)
                }
            }
            
            // Username only
            Text("@\(user.username)")
                .font(.headline)
                .foregroundColor(.blue)
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .foregroundColor(.gray)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .shadow(radius: 2)
    }
}
