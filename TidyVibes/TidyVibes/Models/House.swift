import Foundation
import SwiftData
import SwiftUI

@Model
class House {
    var id: UUID = UUID()
    var name: String
    var address: String?
    var icon: String?       // SF Symbol name, e.g. "house", "building.2"
    var color: String?      // Hex color, e.g. "#4A90E2"
    var sortOrder: Int = 0
    var isCollapsed: Bool = false
    var createdAt: Date = Date()

    @Relationship(deleteRule: .cascade, inverse: \Room.house)
    var rooms: [Room] = []

    init(name: String, address: String? = nil, icon: String? = nil, color: String? = nil) {
        self.name = name
        self.address = address
        self.icon = icon
        self.color = color
    }

    /// Total item count across all rooms, locations and storage spaces
    var totalItemCount: Int {
        rooms.reduce(0) { total, room in
            total + room.totalItemCount
        }
    }

    /// Total room count
    var roomCount: Int {
        rooms.count
    }

    /// Summary text for collapsed view
    var summary: String {
        let roomCount = rooms.count
        let itemCount = totalItemCount
        var parts: [String] = []

        if let addr = address, !addr.isEmpty {
            parts.append(addr)
        }

        parts.append("\(roomCount) room\(roomCount == 1 ? "" : "s")")
        parts.append("\(itemCount) item\(itemCount == 1 ? "" : "s")")

        return parts.joined(separator: " • ")
    }

    /// Resolved SwiftUI color from hex string
    var colorValue: Color {
        guard let hex = color else { return .blue }
        return Color(hex: hex)
    }
}
