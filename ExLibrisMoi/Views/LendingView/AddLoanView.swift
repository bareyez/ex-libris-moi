import SwiftUI
import FirebaseAuth

struct AddLoanView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var viewModel = HomeViewModel()
    @State private var selectedBook: Book?
    @State private var selectedBorrower: User?
    @State private var lendDate = Date()
    @State private var duration = 30
    @State private var notes = ""
    @State private var searchText = ""
    
    private var availableBooks: [Book] {
        viewModel.books.filter { $0.lendingStatus == .available }
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section("Choose book") {
                    Picker("Book", selection: $selectedBook) {
                        Text("Select a book").tag(nil as Book?)
                        ForEach(availableBooks) { book in
                            Text(book.title).tag(book as Book?)
                        }
                    }
                    
                    if let book = selectedBook {
                        HStack {
                            BookCoverView(book: book)
                                .frame(width: 60, height: 90)
                            
                            VStack(alignment: .leading) {
                                Text(book.title)
                                    .font(.headline)
                                Text(book.author)
                                    .font(.subheadline)
                                Text("Status: Available")
                                    .font(.caption)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                }
                
                if selectedBook != nil {
                    Section("Borrower") {
                        FriendSearchBar(text: $searchText, selectedFriend: $selectedBorrower)
                        
                        if let borrower = selectedBorrower {
                            HStack {
                                AsyncImage(url: URL(string: borrower.photoURL ?? "")) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                                
                                VStack(alignment: .leading) {
                                    Text([borrower.firstName, borrower.lastName]
                                        .compactMap { $0 }
                                        .joined(separator: " "))
                                        .font(.headline)
                                    Text("@\(borrower.username)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                        }
                    }
                    
                    Section("Loan details") {
                        DatePicker("Lend date", selection: $lendDate, displayedComponents: .date)
                        
                        Picker("Duration", selection: $duration) {
                            Text("30 days").tag(30)
                            Text("60 days").tag(60)
                            Text("90 days").tag(90)
                        }
                        
                        let dueDate = Calendar.current.date(byAdding: .day, value: duration, to: lendDate) ?? lendDate
                        Text("Due date: \(dueDate.formatted(date: .long, time: .omitted))")
                            .foregroundColor(.secondary)
                    }
                    
                    Section("Notes (optional)") {
                        TextEditor(text: $notes)
                            .frame(height: 100)
                    }
                }
            }
            .navigationTitle("Lend a book!")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add loan") {
                        Task {
                            await addLoan()
                        }
                    }
                    .disabled(selectedBook == nil || selectedBorrower == nil)
                }
            }
        }
        .onAppear {
            viewModel.fetchBooks()
        }
    }
    
    private func addLoan() async {
        guard let book = selectedBook,
              let bookId = book.id,
              let borrower = selectedBorrower,
              let borrowerId = borrower.id,
              let lenderId = Auth.auth().currentUser?.uid else {
            print("Error: Required IDs are missing")
            return
        }
        
        let dueDate = Calendar.current.date(byAdding: .day, value: duration, to: lendDate) ?? lendDate
        
        let loan = Loan(
            bookId: bookId,
            borrowerId: borrowerId,
            lenderId: lenderId,
            lendDate: lendDate,
            dueDate: dueDate,
            notes: notes.isEmpty ? nil : notes,
            isReturned: false
        )
        
        do {
            try await viewModel.addLoan(loan)
            dismiss()
        } catch {
            print("Error adding loan: \(error)")
        }
    }
} 