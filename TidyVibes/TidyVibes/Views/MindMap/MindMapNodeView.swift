import SwiftUI

struct MindMapNodeView: View {
    let node: MindMapNode
    let isHighlighted: Bool

    var body: some View {
        Group {
            switch node.type {
            case .root:
                rootBody
            case .category:
                categoryBody
            case .item:
                itemBody
            }
        }
        .frame(width: node.size.width, height: node.size.height)
    }

    // MARK: - Root Node (Storage name)

    private var rootBody: some View {
        HStack(spacing: 6) {
            Image(systemName: "archivebox.fill")
                .font(.caption)
                .foregroundColor(.white)

            Text(node.label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white)
                .lineLimit(1)
        }
        .padding(.horizontal, 14)
        .frame(width: node.size.width, height: node.size.height)
        .background(Color.accentColor)
        .clipShape(Capsule())
        .shadow(color: Color.accentColor.opacity(0.25), radius: 4, y: 2)
    }

    // MARK: - Category Node

    private var categoryBody: some View {
        HStack(spacing: 4) {
            Text(node.label)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.accentColor)
                .lineLimit(1)

            if node.childCount > 0 {
                Text("\(node.childCount)")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(Color.accentColor.opacity(0.6))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 12)
        .frame(width: node.size.width, height: node.size.height)
        .background(Color.accentColor.opacity(0.08))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(Color.accentColor.opacity(0.25), lineWidth: 1)
        )
    }

    // MARK: - Item Node (Leaf)

    private var itemBody: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(isHighlighted ? Color.accentColor : Color.gray.opacity(0.35))
                .frame(width: 5, height: 5)

            Text(node.label)
                .font(.caption2)
                .foregroundColor(isHighlighted ? .accentColor : .primary)
                .lineLimit(1)

            Spacer(minLength: 0)

            if node.quantity > 1 {
                Text("x\(node.quantity)")
                    .font(.system(size: 9, weight: .medium, design: .rounded))
                    .foregroundColor(.secondary)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 1)
                    .background(Color(.systemGray5))
                    .clipShape(Capsule())
            }
        }
        .padding(.horizontal, 10)
        .frame(width: node.size.width, height: node.size.height)
        .background(isHighlighted ? Color.accentColor.opacity(0.1) : Color(.systemGray6))
        .clipShape(Capsule())
        .overlay(
            Capsule()
                .stroke(isHighlighted ? Color.accentColor.opacity(0.5) : Color.clear, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.25), value: isHighlighted)
    }
}
