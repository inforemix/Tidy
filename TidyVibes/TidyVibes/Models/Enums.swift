import Foundation
import SwiftUI

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

// MARK: - Capture Method

enum CaptureMethod: String, CaseIterable {
    case photo = "photo"
    case voice = "voice"
    case manual = "manual"

    var icon: String {
        switch self {
        case .photo: return "camera.fill"
        case .voice: return "mic.fill"
        case .manual: return "text.cursor"
        }
    }

    var title: String {
        switch self {
        case .photo: return "Take a Photo"
        case .voice: return "Speak Your Items"
        case .manual: return "Type Items"
        }
    }

    var subtitle: String {
        switch self {
        case .photo: return "Lay out items and snap a picture"
        case .voice: return "Dictate what's in your storage"
        case .manual: return "Enter comma-separated list"
        }
    }

    var accentColor: Color {
        switch self {
        case .photo: return .accentColor
        case .voice: return .purple
        case .manual: return .orange
        }
    }
}

// MARK: - Room Preset Icons

struct RoomPreset {
    let name: String
    let icon: String
    let color: String

    static let presets: [RoomPreset] = [
        RoomPreset(name: "Bedroom", icon: "bed.double.fill", color: "#6B7FD7"),
        RoomPreset(name: "Kitchen", icon: "fork.knife", color: "#E8A838"),
        RoomPreset(name: "Living Room", icon: "sofa.fill", color: "#4CAF50"),
        RoomPreset(name: "Bathroom", icon: "shower.fill", color: "#29B6F6"),
        RoomPreset(name: "Office", icon: "desktopcomputer", color: "#7E57C2"),
        RoomPreset(name: "Garage", icon: "wrench.and.screwdriver.fill", color: "#8D6E63"),
        RoomPreset(name: "Closet", icon: "door.left.hand.closed", color: "#EC407A"),
        RoomPreset(name: "Laundry", icon: "washer.fill", color: "#26A69A"),
        RoomPreset(name: "Pantry", icon: "cart.fill", color: "#FF7043"),
        RoomPreset(name: "Other", icon: "square.dashed", color: "#78909C"),
    ]
}
