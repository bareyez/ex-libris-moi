import SwiftUI

struct FilterButton: View {
    let title: String
    @Binding var selection: String?
    
    var body: some View {
        Button(action: {
            // Handle filter selection
        }) {
            HStack {
                Text(title)
                Image(systemName: "chevron.down")
                    .font(.caption)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .foregroundColor(.primary)
    }
} 