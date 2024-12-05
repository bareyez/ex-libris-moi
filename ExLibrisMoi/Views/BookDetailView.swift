import SwiftUI

struct BookDetailView: View {
    let book: Book
    @State private var userRating: Int = 0
    @State private var lendingStatus: Book.LendingStatus = .available
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
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
                    
                    // Rating
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your rating")
                            .font(.headline)
                        
                        HStack {
                            ForEach(1...5, id: \.self) { index in
                                Image(systemName: index <= userRating ? "star.fill" : "star")
                                    .foregroundColor(.yellow)
                                    .onTapGesture {
                                        userRating = index
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
                    DetailRow(title: "ISBN", value: book.isbn)
                    DetailRow(title: "Date Added", value: formatDate(book.dateAdded))
                }
                .padding()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
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