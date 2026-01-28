import SwiftUI

struct ItemNodeView: View {
    let item: Item
    let containerSize: CGSize
    let isHighlighted: Bool

    @State private var showingDetail = false

    private var position: CGPoint {
        CGPoint(
            x: item.positionX * containerSize.width,
            y: item.positionY * containerSize.height
        )
    }

    private var itemSize: CGSize {
        // Estimate size based on category or use defaults
        let baseSize: CGFloat = min(containerSize.width, containerSize.height) * 0.15
        return CGSize(width: baseSize * 1.2, height: baseSize)
    }

    var body: some View {
        VStack(spacing: 4) {
            // Item rectangle
            RoundedRectangle(cornerRadius: 8)
                .fill(isHighlighted ? Color.accentColor.opacity(0.3) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isHighlighted ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isHighlighted ? 2 : 1)
                )
                .frame(width: itemSize.width, height: itemSize.height)
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)

            // Item name
            Text(item.name)
                .font(.caption2)
                .lineLimit(1)
                .foregroundColor(isHighlighted ? .accentColor : .primary)

            // Quantity badge
            if item.quantity > 1 {
                Text("×\(item.quantity)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .position(position)
        .onTapGesture {
            showingDetail = true
        }
        .popover(isPresented: $showingDetail) {
            ItemDetailPopover(item: item)
        }
        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
    }
}

struct ItemDetailPopover: View {
    let item: Item

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.name)
                .font(.headline)

            if item.quantity > 1 {
                Label("\(item.quantity) items", systemImage: "number")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            if let category = item.category {
                Label(category.capitalized, systemImage: "tag")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }

            Label("Added \(item.createdAt.formatted(date: .abbreviated, time: .omitted))",
                  systemImage: "calendar")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(minWidth: 200)
    }
}
