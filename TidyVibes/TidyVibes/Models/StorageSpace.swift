import Foundation
import SwiftData

@Model
class StorageSpace {
    var id: UUID = UUID()
    var name: String
    var storageType: String  // "drawer", "cabinet", "bin", "shelf", "other"

    // Dimensions (from IKEA or manual)
    var widthInches: Double
    var depthInches: Double
    var heightInches: Double

    // IKEA reference (optional)
    var ikeaProductId: String?
    var ikeaProductName: String?

    // Photos
    var photo: Data?  // Original photo of storage

    // Timestamps
    var createdAt: Date = Date()
    var updatedAt: Date = Date()

    // Relationship
    @Relationship(deleteRule: .cascade, inverse: \Item.storageSpace)
    var items: [Item] = []

    init(name: String, storageType: String, width: Double, depth: Double, height: Double) {
        self.name = name
        self.storageType = storageType
        self.widthInches = width
        self.depthInches = depth
        self.heightInches = height
    }
}
