import Foundation

enum StorageType: String, CaseIterable, Codable {
    case drawer = "drawer"
    case cabinet = "cabinet"
    case bin = "bin"
    case shelf = "shelf"
    case other = "other"

    var icon: String {
        switch self {
        case .drawer: return "square.split.2x2"
        case .cabinet: return "door.left.hand.closed"
        case .bin: return "shippingbox"
        case .shelf: return "books.vertical"
        case .other: return "square.dashed"
        }
    }
}

enum OrganizationStyle: String, CaseIterable, Codable {
    case smart = "smart"
    case category = "category"
    case frequency = "frequency"
    case size = "size"
    case workflow = "workflow"

    var displayName: String {
        switch self {
        case .smart: return "Smart"
        case .category: return "By Category"
        case .frequency: return "By Frequency"
        case .size: return "By Size"
        case .workflow: return "By Workflow"
        }
    }

    var description: String {
        switch self {
        case .smart: return "AI decides the best arrangement"
        case .category: return "Similar items grouped together"
        case .frequency: return "Daily items accessible, rare items back"
        case .size: return "Tetris-style space optimization"
        case .workflow: return "Items used together stored together"
        }
    }
}
