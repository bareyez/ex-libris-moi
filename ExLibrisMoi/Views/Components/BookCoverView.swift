import SwiftUI

struct BookCoverView: View {
    let book: Book
    
    var body: some View {
        if let coverURLString = book.coverURL, let coverURL = URL(string: coverURLString) {
            AsyncImage(url: coverURL) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .aspectRatio(2/3, contentMode: .fit)
                        .onAppear {
                            print("Debug: Loading image from URL: \(coverURLString)")
                        }
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .clipped()
                        .onAppear {
                            print("Debug: Successfully loaded image from URL: \(coverURLString)")
                        }
                case .failure(let error):
                    placeholderImage
                        .onAppear {
                            print("Debug: Failed to load image from URL: \(coverURLString)")
                            print("Debug: Error: \(error.localizedDescription)")
                        }
                @unknown default:
                    placeholderImage
                }
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(2/3, contentMode: .fit)
            .cornerRadius(8)
            .shadow(radius: 2)
        } else {
            placeholderImage
                .onAppear {
                    print("Debug: No cover URL available for book: \(book.title)")
                }
        }
    }
    
    private var placeholderImage: some View {
        Rectangle()
            .fill(Color.gray.opacity(0.3))
            .overlay(
                VStack(spacing: 8) {
                    Image(systemName: "book.closed")
                        .font(.largeTitle)
                        .foregroundColor(.gray)
                    
                    Text(book.title)
                        .font(.caption)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 8)
                        .lineLimit(3)
                }
            )
            .frame(maxWidth: .infinity)
            .aspectRatio(2/3, contentMode: .fit)
            .cornerRadius(8)
            .shadow(radius: 2)
    }
}