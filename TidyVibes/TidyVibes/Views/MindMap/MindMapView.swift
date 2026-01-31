import SwiftUI

// MARK: - Mind Map Data Types

struct MindMapNode: Identifiable {
    let id: String
    let label: String
    let type: NodeType
    let center: CGPoint
    let size: CGSize
    let itemId: UUID?
    let quantity: Int
    let childCount: Int

    enum NodeType {
        case root
        case category
        case item
    }
}

struct MindMapEdge: Identifiable {
    let id = UUID()
    let from: CGPoint
    let to: CGPoint
}

// MARK: - Mind Map View

struct MindMapView: View {
    let space: StorageSpace
    @Binding var highlightedItemId: UUID?

    // Layout constants
    private let padding: CGFloat = 28
    private let rootNodeSize = CGSize(width: 150, height: 42)
    private let categoryNodeSize = CGSize(width: 130, height: 36)
    private let itemNodeSize = CGSize(width: 150, height: 32)
    private let columnGap: CGFloat = 50
    private let itemVerticalSpacing: CGFloat = 6
    private let categoryVerticalGap: CGFloat = 20

    /// Items grouped by their AI-assigned category, sorted alphabetically.
    private var groupedItems: [(category: String, items: [Item])] {
        let grouped = Dictionary(grouping: space.items) {
            $0.category?.capitalized ?? "Other"
        }
        return grouped
            .sorted { $0.key < $1.key }
            .map { (category: $0.key, items: $0.value.sorted { $0.name < $1.name }) }
    }

    // MARK: - Body

    var body: some View {
        let layoutData = calculateLayout()

        ScrollView([.horizontal, .vertical], showsIndicators: false) {
            ZStack(alignment: .topLeading) {
                // Connector curves
                Canvas { context, _ in
                    for edge in layoutData.edges {
                        let path = curvedEdgePath(from: edge.from, to: edge.to)
                        context.stroke(
                            path,
                            with: .color(.gray.opacity(0.35)),
                            lineWidth: 1.5
                        )
                    }
                }
                .frame(width: layoutData.contentSize.width,
                       height: layoutData.contentSize.height)

                // Nodes
                ForEach(layoutData.nodes) { node in
                    MindMapNodeView(
                        node: node,
                        isHighlighted: node.itemId == highlightedItemId
                    )
                    .position(node.center)
                    .onTapGesture {
                        guard let itemId = node.itemId else { return }
                        withAnimation(.easeInOut(duration: 0.25)) {
                            highlightedItemId = itemId
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                if highlightedItemId == itemId {
                                    highlightedItemId = nil
                                }
                            }
                        }
                    }
                }
            }
            .frame(width: layoutData.contentSize.width,
                   height: layoutData.contentSize.height)
        }
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.04), radius: 8, y: 2)
        )
    }

    // MARK: - Layout Calculation

    private func calculateLayout() -> (nodes: [MindMapNode], edges: [MindMapEdge], contentSize: CGSize) {
        var nodes: [MindMapNode] = []
        var edges: [MindMapEdge] = []

        let groups = groupedItems
        guard !groups.isEmpty else {
            let emptyNode = MindMapNode(
                id: "root", label: space.name, type: .root,
                center: CGPoint(x: padding + rootNodeSize.width / 2, y: padding + rootNodeSize.height / 2),
                size: rootNodeSize, itemId: nil, quantity: 0, childCount: 0
            )
            return ([emptyNode], [], CGSize(width: rootNodeSize.width + padding * 2, height: rootNodeSize.height + padding * 2))
        }

        // Column X centers
        let col0X = padding + rootNodeSize.width / 2
        let col1X = padding + rootNodeSize.width + columnGap + categoryNodeSize.width / 2
        let col2X = padding + rootNodeSize.width + columnGap + categoryNodeSize.width + columnGap + itemNodeSize.width / 2

        // First pass: calculate all item and category Y positions
        var currentY = padding
        var categoryPositions: [(centerY: CGFloat, category: String, itemCount: Int)] = []

        for (groupIndex, group) in groups.enumerated() {
            let groupStartY = currentY

            // Place item nodes
            for (itemIndex, item) in group.items.enumerated() {
                let itemCenterY = currentY + itemNodeSize.height / 2

                nodes.append(MindMapNode(
                    id: "item-\(item.id.uuidString)",
                    label: item.name,
                    type: .item,
                    center: CGPoint(x: col2X, y: itemCenterY),
                    size: itemNodeSize,
                    itemId: item.id,
                    quantity: item.quantity,
                    childCount: 0
                ))

                currentY += itemNodeSize.height
                if itemIndex < group.items.count - 1 {
                    currentY += itemVerticalSpacing
                }
            }

            let groupEndY = currentY

            // Category node: vertically centered within its items
            let firstItemCenterY = groupStartY + itemNodeSize.height / 2
            let lastItemCenterY = groupEndY - itemNodeSize.height / 2
            let categoryCenterY = (firstItemCenterY + lastItemCenterY) / 2

            nodes.append(MindMapNode(
                id: "cat-\(group.category)",
                label: group.category,
                type: .category,
                center: CGPoint(x: col1X, y: categoryCenterY),
                size: categoryNodeSize,
                itemId: nil,
                quantity: 0,
                childCount: group.items.count
            ))

            categoryPositions.append((centerY: categoryCenterY, category: group.category, itemCount: group.items.count))

            // Edges: category → each item
            for (itemIndex, _) in group.items.enumerated() {
                let itemCenterY = groupStartY + CGFloat(itemIndex) * (itemNodeSize.height + itemVerticalSpacing) + itemNodeSize.height / 2
                edges.append(MindMapEdge(
                    from: CGPoint(x: col1X + categoryNodeSize.width / 2, y: categoryCenterY),
                    to: CGPoint(x: col2X - itemNodeSize.width / 2, y: itemCenterY)
                ))
            }

            // Gap before next category group
            if groupIndex < groups.count - 1 {
                currentY += categoryVerticalGap
            }
        }

        // Root node: vertically centered across all categories
        let firstCatY = categoryPositions.first?.centerY ?? padding
        let lastCatY = categoryPositions.last?.centerY ?? padding
        let rootCenterY = (firstCatY + lastCatY) / 2

        nodes.append(MindMapNode(
            id: "root",
            label: space.name,
            type: .root,
            center: CGPoint(x: col0X, y: rootCenterY),
            size: rootNodeSize,
            itemId: nil,
            quantity: 0,
            childCount: space.items.count
        ))

        // Edges: root → each category
        for cat in categoryPositions {
            edges.append(MindMapEdge(
                from: CGPoint(x: col0X + rootNodeSize.width / 2, y: rootCenterY),
                to: CGPoint(x: col1X - categoryNodeSize.width / 2, y: cat.centerY)
            ))
        }

        // Content size
        let contentWidth = col2X + itemNodeSize.width / 2 + padding
        let contentHeight = currentY + padding

        return (nodes, edges, CGSize(width: contentWidth, height: max(contentHeight, 200)))
    }

    // MARK: - Curved Edge Path

    private func curvedEdgePath(from start: CGPoint, to end: CGPoint) -> Path {
        var path = Path()
        path.move(to: start)

        let midX = (start.x + end.x) / 2
        path.addCurve(
            to: end,
            control1: CGPoint(x: midX, y: start.y),
            control2: CGPoint(x: midX, y: end.y)
        )

        return path
    }
}
