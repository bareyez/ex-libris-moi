import SwiftUI

struct UserProfileView: View {
    let user: User
    @StateObject private var viewModel = UserProfileViewModel()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Profile header
                VStack(spacing: 12) {
                    if let photoURL = user.photoURL {
                        AsyncImage(url: URL(string: photoURL)) { image in
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.gray)
                        }
                        .frame(width: 100, height: 100)
                        .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 100, height: 100)
                            .foregroundColor(.gray)
                    }
                    
                    Text(user.displayName)
                        .font(.title2)
                        .bold()
                    
                    Text("@\(user.username)")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    if !viewModel.isFriend {
                        Button(action: {
                            Task {
                                await viewModel.addFriend(user)
                            }
                        }) {
                            Text("Add Friend")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
                
                // Recent books section
                VStack(alignment: .leading, spacing: 12) {
                    Text("Recently Added Books")
                        .font(.headline)
                        .padding(.horizontal)
                    
                    if viewModel.isLoading {
                        ProgressView()
                    } else if viewModel.recentBooks.isEmpty {
                        Text("No books added yet")
                            .foregroundColor(.secondary)
                            .padding()
                    } else {
                        ForEach(viewModel.recentBooks) { book in
                            NavigationLink(destination: BookDetailView(book: book)) {
                                RecentBookRow(book: book)
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .task {
            await viewModel.checkFriendStatus(for: user)
            await viewModel.fetchRecentBooks(for: user)
        }
    }
}

struct RecentBookRow: View {
    let book: Book
    
    var body: some View {
        HStack {
            BookCoverView(book: book)
                .frame(width: 60, height: 90)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(book.title)
                    .font(.headline)
                Text(book.author)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding(.horizontal)
    }
} 