import Foundation

struct DetectedItem: Codable, Identifiable, Equatable {
    let id: UUID
    let name: String
    let quantity: Int
    let boundingBox: BoundingBox?

    struct BoundingBox: Codable, Equatable {
        let x: Double      // Normalized 0-1
        let y: Double
        let width: Double
        let height: Double

        var centerX: Double { x + width / 2 }
        var centerY: Double { y + height / 2 }
    }

    init(id: UUID = UUID(), name: String, quantity: Int = 1, boundingBox: BoundingBox? = nil) {
        self.id = id
        self.name = name
        self.quantity = quantity
        self.boundingBox = boundingBox
    }
}

struct ItemGroup: Codable {
    let category: String
    let displayName: String
    let items: [String]
}

struct GroupingResponse: Codable {
    let groups: [ItemGroup]
}
