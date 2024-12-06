import SwiftUI
import CodeScanner

struct BookScannerView: View {
    @StateObject private var viewModel = BookScannerViewModel()
    @State private var isPresentingScanner = false
    @State private var selectedTab = 0
    
    var body: some View {
        VStack {
            // Header
            HStack {
                Spacer()
                Text("Add a book to your library!")
                Spacer()
            }
            .padding()
            
            // Segment Control
            Picker("Mode", selection: $selectedTab) {
                Text("Scanner").tag(0)
                Text("Scanned Books").tag(1)
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            if selectedTab == 0 {
                // Scanner View
                Button(action: {
                    isPresentingScanner = true
                }) {
                    VStack {
                        Image(systemName: "barcode.viewfinder")
                            .font(.largeTitle)
                        Text("Tap to scan")
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemGray6))
                }
                
                Button(action: {
                    // Manual entry
                }) {
                    Label("Enter manually", systemImage: "pencil")
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                }
                .padding()
            } else {
                // Scanned Books List
                ScrollView {
                    LazyVStack(alignment: .leading, spacing: 16) {
                        ForEach(viewModel.scannedBooks) { book in
                            ScannedBookRow(book: book)
                        }
                    }
                    .padding()
                }
            }
            
            if !viewModel.scannedBooks.isEmpty {
                Button(action: viewModel.shelveAllBooks) {
                    Text("Shelve all")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.black)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding()
            }
        }
        .sheet(isPresented: $isPresentingScanner) {
            CodeScannerView(
                codeTypes: [.ean13, .ean8],
                simulatedData: "9780141036144",
                completion: handleScan
            )
        }
        .overlay(
            Group {
                if viewModel.isLoading {
                    ProgressView("Loading...")
                        .padding()
                        .background(Color(.systemBackground))
                        .cornerRadius(8)
                        .shadow(radius: 2)
                }
            }
        )
        .alert("Error", isPresented: .constant(viewModel.errorMessage != nil)) {
            Button("OK") {
                viewModel.errorMessage = nil
            }
        } message: {
            Text(viewModel.errorMessage ?? "")
        }
    }
    
    private func handleScan(result: Result<ScanResult, ScanError>) {
        isPresentingScanner = false
        switch result {
        case .success(let result):
            viewModel.lookupBook(isbn: result.string)
        case .failure(let error):
            print("Scanning failed: \(error.localizedDescription)")
        }
    }
}

struct ScannedBookRow: View {
    let book: Book
    
    var body: some View {
        HStack {
            AsyncImage(url: URL(string: book.coverURL ?? "")) { image in
                image.resizable()
                    .aspectRatio(contentMode: .fit)
            } placeholder: {
                Color.gray
            }
            .frame(width: 60, height: 90)
            
            VStack(alignment: .leading) {
                Text(book.title)
                    .font(.headline)
                Text(book.author)
                    .font(.subheadline)
                Text(book.publishedDate)
                    .font(.caption)
            }
            
            Spacer()
            
            Button(action: {
                // Add individual book
            }) {
                Image(systemName: "plus")
            }
        }
    }
} 
