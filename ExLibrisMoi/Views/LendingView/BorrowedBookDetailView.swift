import SwiftUI

struct BorrowedBookDetailView: View {
    @Environment(\.dismiss) private var dismiss
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
                
                // Lender Section
                if let lender = lenderViewModel.user {
                    VStack(spacing: 12) {
                        AsyncImage(url: URL(string: lender.photoURL ?? "")) { image in
                            image
                                .resizable()
                                .scaledToFill()
                        } placeholder: {
                            Image(systemName: "person.circle.fill")
                        }
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        
                        Text([lender.firstName, lender.lastName]
                            .compactMap { $0 }
                            .joined(separator: " "))
                            .font(.headline)
                        
                        Text("@\(lender.username)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical)
                }
                
                // Dates Section
                VStack(spacing: 12) {
                    HStack {
                        Text("Borrowed on:")
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
            }
            .padding()
        }
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            bookViewModel.fetchBook(id: loan.bookId, ownerId: loan.lenderId)
            lenderViewModel.fetchUser(id: loan.lenderId)
        }
    }
} 
