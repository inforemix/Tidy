import Foundation
import CoreGraphics

struct LayoutSuggestion {
    let positions: [UUID: CGPoint]  // itemId -> normalized (x, y)
    let groups: [ItemGroup]
    let style: OrganizationStyle
    let reasoning: String
}

class LayoutEngine {
    static let shared = LayoutEngine()

    func generateLayout(
        items: [Item],
        groups: [ItemGroup],
        storage: StorageSpace,
        style: OrganizationStyle
    ) -> LayoutSuggestion {

        // 1. Map items to their groups
        let itemGroups = mapItemsToGroups(items: items, groups: groups)

        // 2. Order groups based on style
        let orderedGroups = orderGroups(itemGroups, style: style)

        // 3. Calculate positions using bin packing
        let positions = binPackGroups(
            orderedGroups: orderedGroups,
            containerWidth: storage.widthInches,
            containerDepth: storage.depthInches,
            style: style
        )

        // 4. Generate reasoning
        let reasoning = generateReasoning(groups: groups, style: style)

        return LayoutSuggestion(
            positions: positions,
            groups: groups,
            style: style,
            reasoning: reasoning
        )
    }

    private func mapItemsToGroups(items: [Item], groups: [ItemGroup]) -> [(group: ItemGroup, items: [Item])] {
        var result: [(group: ItemGroup, items: [Item])] = []

        for group in groups {
            let matchingItems = items.filter { item in
                group.items.contains { $0.lowercased() == item.name.lowercased() }
            }
            if !matchingItems.isEmpty {
                result.append((group: group, items: matchingItems))
            }
        }

        // Add ungrouped items
        let groupedNames = Set(groups.flatMap { $0.items.map { $0.lowercased() } })
        let ungrouped = items.filter { !groupedNames.contains($0.name.lowercased()) }
        if !ungrouped.isEmpty {
            let miscGroup = ItemGroup(category: "miscellaneous", displayName: "Other", items: ungrouped.map { $0.name })
            result.append((group: miscGroup, items: ungrouped))
        }

        return result
    }

    private func orderGroups(_ groups: [(group: ItemGroup, items: [Item])], style: OrganizationStyle) -> [(group: ItemGroup, items: [Item])] {
        switch style {
        case .smart, .category:
            // Alphabetical by category
            return groups.sorted { $0.group.displayName < $1.group.displayName }

        case .frequency:
            // More items = more frequently used (proxy)
            return groups.sorted { $0.items.count > $1.items.count }

        case .size:
            // Larger groups (more items) on edges
            let sorted = groups.sorted { $0.items.count > $1.items.count }
            // Interleave: large, small, large, small
            var result: [(group: ItemGroup, items: [Item])] = []
            var left = 0, right = sorted.count - 1
            var addLeft = true
            while left <= right {
                if addLeft {
                    result.append(sorted[left])
                    left += 1
                } else {
                    result.append(sorted[right])
                    right -= 1
                }
                addLeft.toggle()
            }
            return result

        case .workflow:
            // Keep original order (assumes user-defined relationships)
            return groups
        }
    }

    private func binPackGroups(
        orderedGroups: [(group: ItemGroup, items: [Item])],
        containerWidth: Double,
        containerDepth: Double,
        style: OrganizationStyle
    ) -> [UUID: CGPoint] {

        var positions: [UUID: CGPoint] = [:]

        // Simple grid-based bin packing
        let padding: Double = 0.05  // 5% padding from edges
        let spacing: Double = 0.08  // 8% spacing between items

        var currentX = padding
        var currentY = padding
        var rowHeight: Double = 0

        let itemWidth = 0.12  // 12% of container width per item
        let itemHeight = 0.10  // 10% of container depth per item

        for (_, items) in orderedGroups {
            // Start each group on a new "row" if category style
            if style == .category && currentX > padding {
                currentX = padding
                currentY += rowHeight + spacing
                rowHeight = 0
            }

            for item in items {
                // Check if item fits in current row
                if currentX + itemWidth > 1.0 - padding {
                    currentX = padding
                    currentY += rowHeight + spacing
                    rowHeight = 0
                }

                // Check if we've exceeded container depth
                if currentY + itemHeight > 1.0 - padding {
                    // Overflow - place at bottom right
                    currentY = 1.0 - padding - itemHeight
                }

                positions[item.id] = CGPoint(
                    x: currentX + itemWidth / 2,
                    y: currentY + itemHeight / 2
                )

                currentX += itemWidth + spacing
                rowHeight = max(rowHeight, itemHeight)
            }
        }

        return positions
    }

    private func generateReasoning(groups: [ItemGroup], style: OrganizationStyle) -> String {
        let groupNames = groups.map { $0.displayName }.joined(separator: ", ")

        switch style {
        case .smart:
            return "Grouped your items into \(groups.count) categories (\(groupNames)) and arranged them for easy access."
        case .category:
            return "Organized by category: \(groupNames). Similar items are now grouped together."
        case .frequency:
            return "Placed larger groups toward the front where they're easier to reach."
        case .size:
            return "Optimized for space efficiency with larger groups on the edges."
        case .workflow:
            return "Arranged items based on how they're used together."
        }
    }
}
