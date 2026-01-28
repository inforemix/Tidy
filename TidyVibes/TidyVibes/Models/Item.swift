import Foundation
import SwiftData

@Model
class Item {
    var id: UUID = UUID()
    var name: String
    var category: String?  // Semantic category from AI
    var quantity: Int = 1

    // Position (normalized 0-1 within storage)
    var positionX: Double = 0.5
    var positionY: Double = 0.5

    // Estimated size (from category defaults or detection)
    var estimatedWidthInches: Double?
    var estimatedDepthInches: Double?

    // Photo (cropped from detection)
    var photo: Data?

    // Timestamps
    var createdAt: Date = Date()
    var updatedAt: Date = Date()
    var lastMoved: Date?

    // Relationship
    var storageSpace: StorageSpace?

    init(name: String, quantity: Int = 1) {
        self.name = name
        self.quantity = quantity
    }
}
