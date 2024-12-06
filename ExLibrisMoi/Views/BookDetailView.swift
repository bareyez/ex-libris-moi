import SwiftUI

struct BookDetailView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = BookDetailViewModel()
    let book: Book
    @State private var userRating: Int
    @State private var lendingStatus: Book.LendingStatus
    @State private var showingDeleteAlert = false
    
    // Initialize state with book values
    init(book: Book) {
        self.book = book
        _userRating = State(initialValue: book.userRating)
        _lendingStatus = State(initialValue: book.lendingStatus)
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .center, spacing: 0) {
                // Book cover and title header
                BookHeaderView(book: book)
                
                // Status and Rating
                VStack(spacing: 24) {
                    // Lending Status
                    HStack {
                        Text("Status:")
                            .font(.headline)
                        
                        Menu {
                            ForEach(Book.LendingStatus.allCases, id: \.self) { status in
                                Button(action: { lendingStatus = status }) {
                                    if status == lendingStatus {
                                        Label(status.rawValue.capitalized, systemImage: "checkmark")
                                    } else {
                                        Text(status.rawValue.capitalized)
                                    }
                                }
                            }
                        } label: {
                            Text(lendingStatus.rawValue.capitalized)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 8)
                                .background(statusColor.opacity(0.2))
                                .foregroundColor(statusColor)
                                .cornerRadius(8)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                    
                    // Rating
                    VStack(alignment: .center, spacing: 8) {
                        Text("Your rating")
                            .font(.headline)
                        
                        HStack {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= userRating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .onTapGesture {
                                        userRating = index
                                        Task {
                                            await viewModel.updateBookRating(book, rating: index)
                                        }
                                    }
                            }
                        }
                    }
                }
                .padding()
                
                // Book Description
                VStack(alignment: .leading, spacing: 16) {
                    Text("Book Description")
                        .font(.headline)
                    
                    if let description = book.description {
                        Text(description)
                            .font(.body)
                    } else {
                        Text("No description available")
                            .foregroundColor(.secondary)
                    }
                }
                .padding()
                
                // More details
                VStack(alignment: .leading, spacing: 16) {
                    Text("More details")
                        .font(.headline)
                    
                    DetailRow(title: "Published Date", value: book.publishedDate)
                    if let publisher = book.publisher {
                        DetailRow(title: "Publisher", value: publisher)
                    }
                    if let language = book.language {
                        DetailRow(title: "Language", value: language)
                    }
                    if let genres = book.genre {
                        DetailRow(title: "Genre(s)", value: genres.joined(separator: ", "))
                    }
                    DetailRow(title: "ISBN", value: book.isbn)
                    DetailRow(title: "Date Added", value: formatDate(book.dateAdded))
                }
                .padding()
                
                // Add this at the bottom after the "More details" section
                VStack(spacing: 16) {
                    Divider()
                    
                    Button(role: .destructive, action: {
                        showingDeleteAlert = true
                    }) {
                        HStack {
                            Image(systemName: "trash")
                            Text("Remove from Library")
                        }
                        .foregroundColor(.red)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.red, lineWidth: 1)
                        )
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle("Book Details")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Remove Book", isPresented: $showingDeleteAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteBook(book)
                    dismiss()
                }
            }
        } message: {
            Text("Are you sure you want to remove '\(book.title)' from your library? This action cannot be undone.")
        }
        .overlay {
            if viewModel.isLoading {
                ProgressView()
                    .padding()
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .shadow(radius: 2)
            }
        }
    }
    
    private var statusColor: Color {
        switch lendingStatus {
        case .available:
            return .green
        case .lent:
            return .orange
        case .reading:
            return .blue
        }
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter.string(from: date)
    }
}

// MARK: - Supporting Views
struct BookHeaderView: View {
    let book: Book
    
    var body: some View {
        VStack(spacing: 16) {
            // Book cover
            BookCoverView(book: book)
                .frame(height: 240)
            
            // Title and Author
            VStack(spacing: 8) {
                Text(book.title)
                    .font(.title2)
                    .bold()
                    .multilineTextAlignment(.center)
                
                Text("by \(book.author)")
                    .font(.title3)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)
        }
        .padding(.vertical)
    }
}

struct DetailRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundColor(.secondary)
                .frame(width: 120, alignment: .leading)
            
            Text(value)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
}