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
    
    // Grid layout configuration
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var filteredBooks: [Book] {
        if searchText.isEmpty {
            return viewModel.books
        }
        return viewModel.books.filter { book in
            book.title.localizedCaseInsensitiveContains(searchText) ||
            book.author.localizedCaseInsensitiveContains(searchText)
        }
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 16) {
                // Search bar
                SearchBar(text: $searchText, placeholder: "Search for a book in your library...")
                
                // Filters
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        FilterButton(title: "Genre", selection: $selectedGenre)
                        FilterButton(title: "Author", selection: $selectedAuthor)
                        FilterButton(title: "Year", selection: $selectedYear)
                        FilterButton(title: "Format", selection: $selectedFormat)
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
                                        .frame(height: 180)
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
}