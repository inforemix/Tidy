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
    var generatedImage: Data?  // AI-generated layout preview

    // Hierarchy
    var location: Location?

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

    /// Full hierarchy path: "Bedroom > Closet > ALEX Drawer Unit"
    var hierarchyPath: String {
        var parts: [String] = []
        if let room = location?.room {
            parts.append(room.name)
        }
        if let loc = location {
            parts.append(loc.name)
        }
        parts.append(name)
        return parts.joined(separator: " > ")
    }
}
