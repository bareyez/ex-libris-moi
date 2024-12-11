import SwiftUI
import FirebaseAuth

struct HomeView: View {
    @StateObject private var viewModel = HomeViewModel()
    @State private var searchText = ""
    @State private var selectedGenre: String?
    @State private var selectedAuthor: String?
    @State private var selectedYear: String?
    @State private var selectedFormat: String?
    @State private var showingScanner = false
    @State private var selectedRating: Int?
    @State private var selectedStatus: Book.LendingStatus?
    
    // Grid layout configuration
    private let columns = [
        GridItem(.adaptive(minimum: 120, maximum: 120), spacing: 16),
        GridItem(.adaptive(minimum: 120, maximum: 120), spacing: 16),
        GridItem(.adaptive(minimum: 120, maximum: 120), spacing: 16)
    ]
    
    private var genres: [String] {
        let allGenres = viewModel.books.flatMap { book in 
            book.genre ?? ["Unknown"]
        }
        return Array(Set(allGenres)).sorted()
    }
    
    private var authors: [String] {
        Array(Set(viewModel.books.map { book in 
            book.author 
        })).sorted()
    }
    
    private var years: [String] {
        Array(Set(viewModel.books.map { book in
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyyy-MM-dd"
            if let date = dateFormatter.date(from: book.publishedDate) {
                return String(Calendar.current.component(.year, from: date))
            }
            return "Unknown"
        })).sorted()
    }
    
    private var ratings: [String] {
        // Ratings 1-5
        return (1...5).map { String($0) }
    }
    
    private var statuses: [String] {
        Book.LendingStatus.allCases.map { $0.rawValue.capitalized }
    }
    
    private var hasActiveFilters: Bool {
        selectedGenre != nil ||
        selectedAuthor != nil ||
        selectedYear != nil ||
        selectedRating != nil ||
        selectedStatus != nil ||
        !searchText.isEmpty
    }
    
    var filteredBooks: [Book] {
        var result = viewModel.books
        
        if let selectedGenre = selectedGenre {
            result = result.filter { book in
                guard let genres = book.genre else { return false }
                return genres.contains(selectedGenre)
            }
        }
        
        if let selectedAuthor = selectedAuthor {
            result = result.filter { $0.author == selectedAuthor }
        }
        
        if let selectedYear = selectedYear {
            result = result.filter { book in
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                guard let date = dateFormatter.date(from: book.publishedDate) else { return false }
                return Calendar.current.component(.year, from: date) == Int(selectedYear)
            }
        }
        
        if let selectedRating = selectedRating {
            result = result.filter { $0.userRating == selectedRating }
        }
        
        if let selectedStatus = selectedStatus {
            result = result.filter { $0.lendingStatus == selectedStatus }
        }
        
        if !searchText.isEmpty {
            result = result.filter { book in
                book.title.localizedCaseInsensitiveContains(searchText) ||
                book.author.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        return result
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Search bar
                SearchBar(text: $searchText, placeholder: "Search for a book in your library...")
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        Button(action: clearAllFilters) {
                            HStack {
                                Image(systemName: "xmark.circle.fill")
                                Text("Clear")
                            }
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemGray6))
                            )
                            .foregroundColor(.red)
                        }
                        .opacity(hasActiveFilters ? 1 : 0.5)
                        .disabled(!hasActiveFilters)
                        
                        FilterButton(title: "Genre", selection: $selectedGenre, options: genres)
                        FilterButton(title: "Author", selection: $selectedAuthor, options: authors)
                        FilterButton(title: "Year", selection: $selectedYear, options: years)
                        FilterButton(title: "Rating", selection: Binding(
                            get: { selectedRating?.description },
                            set: { selectedRating = Int($0 ?? "") }
                        ), options: ratings)
                        FilterButton(title: "Status", selection: Binding(
                            get: { selectedStatus?.rawValue.capitalized },
                            set: { newValue in
                                if let value = newValue?.lowercased() {
                                    selectedStatus = Book.LendingStatus(rawValue: value)
                                } else {
                                    selectedStatus = nil
                                }
                            }
                        ), options: statuses)
                    }
                    .padding(.horizontal)
                }
                
                if viewModel.isLoading {
                    Spacer()
                    ProgressView("Loading your library...")
                        .padding()
                    Spacer()
                } else if viewModel.books.isEmpty {
                    ContentUnavailableView {
                        Label("No Books Yet", systemImage: "book.closed")
                    } description: {
                        Text("Add your first book to get started")
                    } actions: {
                        Button("Scan a Book") {
                            showingScanner = true
                        }
                    }
                } else {
                    // Book grid
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredBooks) { book in
                                NavigationLink(destination: BookDetailView(book: book)) {
                                    BookCoverView(book: book)
                                        .frame(width: 120, height: 180)
                                }
                            }
                        }
                        .padding()
                    }
                    .refreshable {
                        await viewModel.refreshBooks()
                    }
                }
            }
            .navigationTitle("Your library")
            .toolbar {
                Button(action: { showingScanner = true }) {
                    Image(systemName: "plus")
                }
            }
            .onTapGesture {
                dismissKeyboard()
            }
        }
        .sheet(isPresented: $showingScanner) {
            BookScannerView()
        }
        .onAppear {
            viewModel.fetchBooks()
        }
        .onReceive(NotificationCenter.default.publisher(for: .libraryDidChange)) { _ in
            viewModel.fetchBooks()
        }
    }
    func dismissKeyboard() {
            UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
        }
    
    private func clearAllFilters() {
        selectedGenre = nil
        selectedAuthor = nil
        selectedYear = nil
        selectedRating = nil
        selectedStatus = nil
        searchText = ""
    }
}