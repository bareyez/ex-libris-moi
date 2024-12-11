import SwiftUI

struct FriendSearchBar: View {
    @Binding var text: String
    @Binding var selectedFriend: User?
    @StateObject private var viewModel = FriendsViewModel()
    
    var filteredFriends: [User] {
        if text.isEmpty {
            return viewModel.friends
        }
        return viewModel.friends.filter { friend in
            (friend.firstName ?? "").localizedCaseInsensitiveContains(text) ||
            (friend.lastName ?? "").localizedCaseInsensitiveContains(text) ||
            friend.username.localizedCaseInsensitiveContains(text)
        }
    }
    
    var body: some View {
        VStack {
            SearchBar(text: $text, placeholder: "Search friends...")
            
            if viewModel.isLoading {
                ProgressView("Loading friends...")
                    .padding()
            } else if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
                    .padding()
            } else if viewModel.friends.isEmpty {
                Text("No friends found")
                    .foregroundColor(.secondary)
                    .padding()
            } else {
                ScrollView {
                    LazyVStack {
                        ForEach(filteredFriends) { friend in
                            Button {
                                selectedFriend = friend
                                text = ""
                            } label: {
                                HStack {
                                    AsyncImage(url: URL(string: friend.photoURL ?? "")) { image in
                                        image
                                            .resizable()
                                            .scaledToFill()
                                    } placeholder: {
                                        Image(systemName: "person.circle.fill")
                                    }
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    
                                    VStack(alignment: .leading) {
                                        Text([friend.firstName, friend.lastName]
                                            .compactMap { $0 }
                                            .joined(separator: " "))
                                            .font(.headline)
                                        Text("@\(friend.username)")
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                }
                                .padding(.vertical, 4)
                            }
                            .foregroundColor(.primary)
                        }
                    }
                }
                .frame(maxHeight: 200)
            }
        }
        .onAppear {
            viewModel.fetchFriends()
        }
    }
} 
