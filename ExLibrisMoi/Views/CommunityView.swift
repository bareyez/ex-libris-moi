import SwiftUI

struct CommunityView: View {
    @StateObject private var viewModel = CommunityViewModel()
    @State private var searchText = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Search bar
                SearchBar(text: $viewModel.searchText, placeholder: "Search friends by username...")
                    .onChange(of: viewModel.searchText) { _ in
                        viewModel.searchUsers()
                    }
                
                if viewModel.isLoading {
                    ProgressView()
                } else if !viewModel.searchText.isEmpty {
                    // Search results
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.searchResults) { user in
                                NavigationLink(destination: UserProfileView(user: user)) {
                                    UserRow(user: user)
                                }
                            }
                        }
                        .padding()
                    }
                } else {
                    // Friends list
                    VStack(alignment: .leading) {
                        Text("FRIENDS")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .padding(.horizontal)
                        
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                ForEach(viewModel.friends) { friend in
                                    NavigationLink(destination: UserProfileView(user: friend)) {
                                        UserRow(user: friend)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                }
            }
            .navigationTitle("Community")
        }
        .task {
            await viewModel.fetchFriends()
        }
    }
}

struct UserRow: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            // Profile image
            if let photoURL = user.photoURL {
                AsyncImage(url: URL(string: photoURL)) { image in
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                } placeholder: {
                    Image(systemName: "person.circle.fill")
                        .foregroundColor(.gray)
                }
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.gray)
            }
            
            VStack(alignment: .leading) {
                Text("@\(user.username)")
                    .font(.headline)
                Text(user.displayName)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
        }
    }
} 