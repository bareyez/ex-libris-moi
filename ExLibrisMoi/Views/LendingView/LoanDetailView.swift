import SwiftUI

struct LoanDetailView: View {
    @Environment(\.dismiss) private var dismiss
    let loan: Loan
    @StateObject private var bookViewModel = BookViewModel()
    @StateObject private var borrowerViewModel = UserViewModel()
    @StateObject private var lendingViewModel = LendingViewModel()
    @State private var showingReturnAlert = false
    
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
        ScrollView {
            VStack(spacing: 20) {
                if let book = bookViewModel.book {
                    // Book Section
                    VStack(spacing: 16) {
                        BookCoverView(book: book)
                            .frame(width: 120, height: 180)
                        
                        Text(book.title)
                            .font(.title2)
                            .bold()
                        
                        Text(book.author)
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical)
                }
                
                // Status Badge
                Text(loanStatus.text)
                    .font(.subheadline)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(loanStatus.color.opacity(0.2))
                    .foregroundColor(loanStatus.color)
                    .cornerRadius(6)
                
                // Borrower Section
                if let borrower = borrowerViewModel.user {
                    VStack(spacing: 12) {
                        AsyncImage(url: URL(string: borrower.photoURL ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        
                        Text([borrower.firstName, borrower.lastName]
                            .compactMap { $0 }
                            .joined(separator: " "))
                            .font(.headline)
                        
                        Text("@\(borrower.username)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical)
                }
                
                // Dates Section
                VStack(spacing: 12) {
                    HStack {
                        Text("Lent on:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(loan.formattedLendDate)
                            .bold()
                    }
                    
                    HStack {
                        Text("Due date:")
                            .foregroundColor(.secondary)
                        Spacer()
                        Text(loan.formattedDueDate)
                            .bold()
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(12)
                
                // Notes Section
                if let notes = loan.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Notes")
                            .font(.headline)
                        
                        Text(notes)
                            .foregroundColor(.secondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                
                // Return Button
                if !loan.isReturned {
                    Button(action: {
                        showingReturnAlert = true
                    }) {
                        Text("Mark as Returned")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.top)
                }
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .alert("Return Book", isPresented: $showingReturnAlert) {
            Button("Cancel", role: .cancel) { }
            Button("Return", role: .destructive) {
                Task {
                    await markAsReturned()
                }
            }
        } message: {
            Text("Are you sure you want to mark this book as returned?")
        }
        .onAppear {
            bookViewModel.fetchBook(id: loan.bookId)
            borrowerViewModel.fetchUser(id: loan.borrowerId)
        }
    }
    
    private func markAsReturned() async {
        do {
            try await lendingViewModel.markLoanAsReturned(loan)
            dismiss()
        } catch {
            print("Error marking loan as returned: \(error)")
        }
    }
} 