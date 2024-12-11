import SwiftUI

struct DiscoverBookDetailView: View {
    let book: NYTBook
    @Environment(\.dismiss) private var dismiss
    @State private var imageLoaded = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Add top padding to move everything down
                Color.clear.frame(height: 20)  // Adds space at the top
                
                // Book Cover with loading state
                AsyncImage(url: URL(string: book.bookImage)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(width: 150, height: 225)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 225)
                            .cornerRadius(10)
                            .shadow(radius: 5)
                    case .failure:
                        Image(systemName: "book.fill")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 150, height: 225)
                            .foregroundColor(.gray)
                    @unknown default:
                        EmptyView()
                    }
                }
                
                // Book Details
                VStack(spacing: 12) {
                    Text(book.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                    
                    Text("by \(book.author)")
                        .font(.title3)
                        .foregroundColor(.secondary)
                    
                    // Stats
                    HStack(spacing: 20) {
                        StatView(title: "Rank", value: "\(book.rank)")
                        StatView(title: "Weeks on List", value: "\(book.weeksOnList)")
                    }
                    .padding(.vertical)
                    
                    // Description
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Description")
                            .font(.headline)
                        Text(book.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.vertical)
                    
                    // Publisher
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Publisher")
                            .font(.headline)
                        Text(book.publisher)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Buy Links
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Available at")
                            .font(.headline)
                            .padding(.top)
                        
                        ForEach(book.buyLinks, id: \.name) { link in
                            Link(destination: URL(string: link.url)!) {
                                HStack {
                                    Text(link.name)
                                    Spacer()
                                    Image(systemName: "arrow.up.right")
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                .padding()
            }
            .padding(.top) // Add padding to the entire VStack
        }
        .navigationBarTitleDisplayMode(.inline)
    }
}

// Helper view for stats
struct StatView: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(spacing: 4) {
            Text(title)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.headline)
        }
        .frame(minWidth: 80)
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(8)
    }
}