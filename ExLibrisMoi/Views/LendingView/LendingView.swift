import SwiftUI

struct LendingView: View {
    @StateObject private var viewModel = LendingViewModel()
    @State private var showingAddLoan = false
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Segmented control
                Picker("View", selection: $selectedTab) {
                    Text("Lending").tag(0)
                    Text("Borrowing").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                // Content
                if selectedTab == 0 {
                    // Existing lending content
                    LendingContent(
                        viewModel: viewModel,
                        showingAddLoan: $showingAddLoan
                    )
                } else {
                    // Borrowed books content
                    BorrowedBooksView()
                }
            }
            .navigationTitle("Lending")
            .toolbar {
                if selectedTab == 0 {
                    Button(action: { showingAddLoan = true }) {
                        Image(systemName: "plus")
                    }
                }
            }
        }
        .sheet(isPresented: $showingAddLoan) {
            AddLoanView()
        }
    }
}

// Move existing content to a separate view
struct LendingContent: View {
    @ObservedObject var viewModel: LendingViewModel
    @Binding var showingAddLoan: Bool
    
    var body: some View {
        Group {
            if viewModel.isLoading {
                ProgressView("Loading loans...")
            } else if viewModel.loans.isEmpty {
                ContentUnavailableView {
                    Label("No Active Loans", systemImage: "book.closed")
                } description: {
                    Text("Start by lending a book to a friend")
                } actions: {
                    Button("Lend a Book") {
                        showingAddLoan = true
                    }
                }
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        Text("CURRENT LOANS")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal)
                        
                        ForEach(viewModel.loans) { loan in
                            LoanRowView(loan: loan)
                                .padding(.horizontal)
                        }
                    }
                    .padding(.vertical)
                }
            }
        }
        .onAppear {
            viewModel.fetchLoans()
        }
    }
}

struct LoanRowView: View {
    let loan: Loan
    @StateObject private var bookViewModel = BookViewModel()
    @StateObject private var borrowerViewModel = UserViewModel()
    
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
        NavigationLink(destination: LoanDetailView(loan: loan)) {
            VStack(alignment: .leading, spacing: 12) {
                if let book = bookViewModel.book {
                    HStack(spacing: 12) {
                        // Book cover
                        BookCoverView(book: book)
                            .frame(width: 60, height: 90)
                        
                        // Book and borrower info
                        VStack(alignment: .leading, spacing: 4) {
                            Text(book.title)
                                .font(.headline)
                            
                            if let borrower = borrowerViewModel.user {
                                HStack {
                                    Text("Borrower:")
                                        .foregroundColor(.secondary)
                                    Text([borrower.firstName, borrower.lastName]
                                        .compactMap { $0 }
                                        .joined(separator: " "))
                                }
                                .font(.subheadline)
                            }
                            
                            HStack {
                                Text("Lend date:")
                                    .foregroundColor(.secondary)
                                Text(loan.formattedLendDate)
                            }
                            .font(.subheadline)
                            
                            HStack {
                                Text("Due date:")
                                    .foregroundColor(.secondary)
                                Text(loan.formattedDueDate)
                            }
                            .font(.subheadline)
                        }
                        
                        Spacer()
                        
                        // Borrower profile picture and status
                        VStack(alignment: .trailing, spacing: 8) {
                            if let borrower = borrowerViewModel.user {
                                AsyncImage(url: URL(string: borrower.photoURL ?? "")) { image in
                                    image
                                        .resizable()
                                        .scaledToFill()
                                } placeholder: {
                                    Image(systemName: "person.circle.fill")
                                }
                                .frame(width: 40, height: 40)
                                .clipShape(Circle())
                            }
                            
                            Text(loanStatus.text)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(loanStatus.color.opacity(0.2))
                                .foregroundColor(loanStatus.color)
                                .cornerRadius(4)
                        }
                    }
                } else {
                    // Add loading state or error handling
                    ProgressView("Loading loan details...")
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .padding(12)
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 2)
            .onAppear {
                print("Debug: Loading loan - Book ID: \(loan.bookId), Borrower ID: \(loan.borrowerId)")
                bookViewModel.fetchBook(id: loan.bookId)
                borrowerViewModel.fetchUser(id: loan.borrowerId)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}
