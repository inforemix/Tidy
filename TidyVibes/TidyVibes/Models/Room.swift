import Foundation
import SwiftData
import SwiftUI

@Model
class Room {
    var id: UUID = UUID()
    var name: String
    var icon: String?       // SF Symbol name, e.g. "bed.double", "fork.knife"
    var color: String?      // Hex color, e.g. "#FF6B6B"
    var sortOrder: Int = 0
    var isCollapsed: Bool = false
    var createdAt: Date = Date()

    var house: House?

    @Relationship(deleteRule: .cascade, inverse: \Location.room)
    var locations: [Location] = []

    init(name: String, icon: String? = nil, color: String? = nil) {
        self.name = name
        self.icon = icon
        self.color = color
    }

    /// Total item count across all locations and storage spaces
    var totalItemCount: Int {
        locations.reduce(0) { total, location in
            total + location.totalItemCount
        }
    }

    /// Summary text for collapsed view
    var summary: String {
        let locCount = locations.count
        let itemCount = totalItemCount
        return "\(locCount) location\(locCount == 1 ? "" : "s"), \(itemCount) item\(itemCount == 1 ? "" : "s")"
    }

    /// Resolved SwiftUI color from hex string
    var colorValue: Color {
        guard let hex = color else { return .accentColor }
        return Color(hex: hex)
    }
}

// MARK: - Color hex extension
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
