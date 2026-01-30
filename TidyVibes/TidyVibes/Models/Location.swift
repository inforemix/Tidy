import Foundation
import SwiftData

@Model
class Location {
    var id: UUID = UUID()
    var name: String
    var sortOrder: Int = 0
    var createdAt: Date = Date()

    var room: Room?

    @Relationship(deleteRule: .cascade, inverse: \StorageSpace.location)
    var storageSpaces: [StorageSpace] = []

    init(name: String) {
        self.name = name
    }

    var totalItemCount: Int {
        storageSpaces.reduce(0) { $0 + $1.items.count }
    }
}
