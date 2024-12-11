import SwiftUI

struct DiscoverView: View {
    private let apiKey = Configuration.NYT_API_KEY
    @State private var books: [NYTBook] = []
    @State private var selectedList = "hardcover-fiction"
    @State private var showBookDetail = false
    @State private var selectedBook: NYTBook?
    @State private var publishedDate: String = ""
    @State private var preloadedImages: [Int: UIImage] = [:]
    
    // Add a dictionary to map API values to display names
    private let categoryNames: [String: String] = [
        "hardcover-fiction": "Hardcover Fiction",
        "hardcover-nonfiction": "Hardcover Nonfiction",
        "paperback-fiction": "Paperback Fiction",
        "paperback-nonfiction": "Paperback Nonfiction",
        "young-adult-hardcover": "Hardcover Young Adult",
        "advice-how-to-and-miscellaneous": "Advice & How-To"
    ]
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("Explore these New York Times' Bestsellers!")
                    .font(.headline)
                    .foregroundColor(.secondary)
                    .padding(.horizontal)
                
                // Updated Menu with all categories
                Menu {
                    ForEach(Array(categoryNames.keys.sorted()), id: \.self) { key in
                        Button(categoryNames[key] ?? key) {
                            selectedList = key
                        }
                    }
                } label: {
                    HStack {
                        Text(categoryNames[selectedList] ?? selectedList)
                            .foregroundColor(.primary)
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                }
                .padding(.horizontal)
                .onChange(of: selectedList) { _ in
                    fetchBooks()
                }
                
                // Published date
                if !publishedDate.isEmpty {
                    Text("As of \(publishedDate):")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .padding(.horizontal)
                }

                List(books) { book in
                    HStack(alignment: .center, spacing: 16) {
                        // Rank number
                        Text("\(book.rank)")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.secondary)
                            .frame(width: 30)
                        
                        // Book cover
                        AsyncImage(url: URL(string: book.bookImage)) { image in
                            image
                                .resizable()
                                .scaledToFit()
                        } placeholder: {
                            Rectangle()
                                .foregroundColor(.gray.opacity(0.2))
                        }
                        .frame(width: 60, height: 90)
                        .cornerRadius(5)
                        
                        // Book details
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title)
                                .font(.headline)
                                .lineLimit(2)
                            Text("by \(book.author)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            Text(book.description)
                                .font(.caption)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }
                    .padding(.vertical, 8)
                    .onTapGesture {
                        selectedBook = book
                        showBookDetail.toggle()
                    }
                    .listRowInsets(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 16))
                }
                .listStyle(.plain)
            }
            .navigationTitle("Discover")
            .sheet(isPresented: $showBookDetail) {
                if let book = selectedBook {
                    DiscoverBookDetailView(book: book)
                }
            }
            .onAppear {
                fetchBooks()
            }
        }
    }

    func fetchBooks() {
        let urlString = "https://api.nytimes.com/svc/books/v3/lists/current/\(selectedList).json?api-key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data {
                let decoder = JSONDecoder()
                if let bookResponse = try? decoder.decode(BookResponse.self, from: data) {
                    DispatchQueue.main.async {
                        self.books = bookResponse.results.books
                        if let date = formatPublishedDate(bookResponse.results.publishedDate) {
                            self.publishedDate = date
                        }
                        
                        // Preload images
                        for book in bookResponse.results.books {
                            preloadImage(for: book)
                        }
                    }
                }
            }
        }.resume()
    }
    
    // Helper function to format the date
    private func formatPublishedDate(_ dateString: String) -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        guard let date = dateFormatter.date(from: dateString) else { return nil }
        
        dateFormatter.dateFormat = "MMMM d, yyyy"
        return dateFormatter.string(from: date)
    }

    private func preloadImage(for book: NYTBook) {
        guard let url = URL(string: book.bookImage) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let data = data, let image = UIImage(data: data) {
                DispatchQueue.main.async {
                    self.preloadedImages[book.rank] = image
                }
            }
        }.resume()
    }
}

struct BookResponse: Codable {
    let results: BookResults
}

struct BookResults: Codable {
    let books: [NYTBook]
    let publishedDate: String
    
    enum CodingKeys: String, CodingKey {
        case books
        case publishedDate = "published_date"
    }
} 