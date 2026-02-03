import SwiftUI

struct ItemRowView: View {
    let item: Item
    var onMove: ((Item) -> Void)?

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.name)
                    .font(.body)

                if let category = item.category {
                    Text(category.capitalized)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            if item.quantity > 1 {
                Text("×\(item.quantity)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if onMove != nil {
                Button(action: { onMove?(item) }) {
                    Image(systemName: "arrow.right.circle")
                        .foregroundColor(.accentColor)
                        .font(.title3)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal)
    }
}
