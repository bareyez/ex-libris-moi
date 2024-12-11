import SwiftUI

struct BorrowedBooksView: View {
    @StateObject private var viewModel = BorrowedBooksViewModel()
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading borrowed books...")
            } else if viewModel.loans.isEmpty {
                ContentUnavailableView {
                    Label("No Borrowed Books", systemImage: "book.closed")
                } description: {
                    Text("Books that others lend to you will appear here")
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        Text("BORROWED BOOKS")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.loans) { loan in
                            BorrowedBookRow(loan: loan)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .onAppear {
            viewModel.fetchBorrowedBooks()
        }
    }
}

struct BorrowedBookRow: View {
    let loan: Loan
    @StateObject private var bookViewModel = BookViewModel()
    @StateObject private var lenderViewModel = UserViewModel()
    
    private var loanStatus: (text: String, color: Color) {
        if loan.isReturned {
            return ("Returned", .green)
        }
        
        let calendar = Calendar.current
        let oneWeek = calendar.date(byAdding: .day, value: -7, to: loan.dueDate) ?? loan.dueDate
        let now = Date()
        
        if now > loan.dueDate {
            return ("Overdue", .red)
        } else if now > oneWeek {
            return ("Due soon", .orange)
        } else {
            return ("Borrowed", .blue)
        }
    }
    
    var body: some View {
        NavigationLink(destination: BorrowedBookDetailView(loan: loan)) {
            VStack(alignment: .leading, spacing: 12) {
                if let book = bookViewModel.book {
                    HStack(spacing: 12) {
                        BookCoverView(book: book)
                            .frame(width: 60, height: 90)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title)
                                .font(.headline)
                            
                            if let lender = lenderViewModel.user {
                                HStack {
                                    Text("Lender:")
                                        .foregroundColor(.secondary)
                                    Text([lender.firstName, lender.lastName]
                                        .compactMap { $0 }
                                        .joined(separator: " "))
                                }
                                .font(.subheadline)
                            }
                            
                            Text("Due: \(loan.formattedDueDate)")
                                .font(.subheadline)
                                .foregroundColor(loanStatus.color)
                        }
                        
                        Spacer()
                        
                        Text(loanStatus.text)
                            .font(.caption)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(loanStatus.color.opacity(0.2))
                            .foregroundColor(loanStatus.color)
                            .cornerRadius(4)
                    }
                } else {
                    ProgressView("Loading book details...")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            bookViewModel.fetchBook(id: loan.bookId, ownerId: loan.lenderId)
            lenderViewModel.fetchUser(id: loan.lenderId)
        }
    }
} 