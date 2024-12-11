import Foundation
import FirebaseFirestore

struct Loan: Identifiable, Codable {
    @DocumentID var id: String?
    let bookId: String
    let borrowerId: String
    let lenderId: String
    let lendDate: Date
    let dueDate: Date
    let notes: String?
    var isReturned: Bool
    
    var formattedLendDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: lendDate)
    }
    
    var formattedDueDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, yyyy"
        return formatter.string(from: dueDate)
    }
    
    enum CodingKeys: String, CodingKey {
        case id
        case bookId
        case borrowerId
        case lenderId
        case lendDate
        case dueDate
        case notes
        case isReturned
    }
} 