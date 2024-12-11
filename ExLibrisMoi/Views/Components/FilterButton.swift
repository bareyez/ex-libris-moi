import SwiftUI

struct FilterButton: View {
    let title: String
    @Binding var selection: String?
    let options: [String]
    
    var body: some View {
        Menu {
            Button("All") {
                selection = nil
            }
            
            ForEach(options, id: \.self) { option in
                Button(option) {
                    selection = option
                }
            }
        } label: {
            HStack {
                Text(selection ?? title)
                    .foregroundColor(selection == nil ? .secondary : .primary)
                Image(systemName: selection == nil ? "chevron.down" : "chevron.down.circle.fill")
                    .font(.caption)
                    .foregroundColor(selection == nil ? .secondary : .primary)
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(.systemGray6))
            )
        }
    }
} 