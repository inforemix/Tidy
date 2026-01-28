# TidyVibes — MVP Implementation Plan v2

**Based on:** TidyVibes_PRD_v2.md  
**Date:** January 27, 2026  
**Timeline:** 6-8 weeks  
**Approach:** Incremental vertical slices — each phase delivers a usable feature end-to-end

---

## Key Architectural Decisions

| Decision | Choice | Rationale |
|----------|--------|-----------|
| Visualization | **2D top-down** | Simple, clear, performant. Isometric adds complexity without value |
| Object detection | **Apple Vision + GPT-4V** | Free on-device detection, GPT-4V for accurate labeling |
| Semantic grouping | **GPT-4 with caching → fine-tune later** | Ship fast, optimize later |
| Layout algorithm | **Custom bin packing + heuristics** | Full control, no API latency |
| Dimensions | **IKEA database + optional manual** | Known dimensions = accurate layouts |
| Voice capture | **iOS Speech + GPT-4 parsing** | Built-in transcription, LLM for structure |
| State management | **SwiftData** | Modern Swift-native, less boilerplate |
| Architecture | **MVVM** | Standard SwiftUI pattern, testable |

---

## Project Structure

```
TidyVibes/
├── TidyVibesApp.swift                 # App entry point + SwiftData container
├── Models/
│   ├── StorageSpace.swift             # SwiftData model for storage
│   ├── Item.swift                     # SwiftData model for items
│   ├── IKEAProduct.swift              # Codable model for IKEA data
│   └── Enums.swift                    # StorageType, OrganizationStyle, etc.
├── ViewModels/
│   ├── CaptureViewModel.swift         # Camera + AI detection orchestration
│   ├── VoiceCaptureViewModel.swift    # Voice input → item list parsing
│   ├── StorageViewModel.swift         # Storage CRUD, item management
│   ├── SearchViewModel.swift          # Search logic, fuzzy matching
│   ├── LayoutViewModel.swift          # AI grouping + layout algorithm
│   └── IKEAViewModel.swift            # IKEA product search/selection
├── Views/
│   ├── Home/
│   │   ├── HomeView.swift             # Main screen: list of storage spaces
│   │   └── EmptyStateView.swift       # First-run empty state
│   ├── Capture/
│   │   ├── CaptureFlowView.swift      # Container for capture flow
│   │   ├── CameraView.swift           # Photo capture (UIKit bridge)
│   │   ├── VoiceCaptureView.swift     # Voice input alternative
│   │   ├── ItemReviewView.swift       # Review/edit detected items
│   │   └── StorageSelectionView.swift # IKEA picker + custom dimensions
│   ├── SpatialBookmark/
│   │   ├── SpatialBookmarkView.swift  # 2D top-down visualization
│   │   ├── ItemNodeView.swift         # Individual item rendering
│   │   └── StorageDetailView.swift    # Full storage view + actions
│   ├── Layout/
│   │   ├── LayoutSuggestionView.swift # Before/after comparison
│   │   └── StylePickerView.swift      # Organization style selection
│   ├── Search/
│   │   ├── SearchView.swift           # Search bar + results
│   │   └── SearchResultView.swift     # Highlighted item in context
│   └── Shared/
│       ├── ItemRowView.swift          # Reusable item list row
│       ├── StorageCardView.swift      # Storage space card for home
│       └── LoadingOverlay.swift       # AI processing indicator
├── Services/
│   ├── VisionService.swift            # Apple Vision object detection
│   ├── GPTService.swift               # OpenAI API integration
│   ├── SemanticGroupingService.swift  # Item → category grouping
│   ├── LayoutEngine.swift             # Bin packing + style heuristics
│   ├── SpeechService.swift            # iOS Speech transcription
│   ├── SearchService.swift            # Fuzzy text matching
│   └── IKEADataService.swift          # Load/search IKEA products
├── Utilities/
│   ├── Extensions.swift               # Swift extensions
│   ├── Constants.swift                # Colors, sizing, API keys (ref)
│   └── ItemSizeEstimator.swift        # Category-based size defaults
├── Resources/
│   ├── Assets.xcassets                # Colors, images, app icon
│   └── ikea_products.json             # IKEA dimension database
└── Secrets/
    └── APIKeys.swift                  # Gitignored, Keychain ref
```

---

## Phase 1: Foundation — Data & Capture (Week 1-2)

**Goal:** User can photograph items OR speak item list, see AI-detected items, edit them, and save to a named storage space with IKEA dimensions.

### 1.1 Project Setup

```bash
# Create new Xcode project
- SwiftUI App template
- iOS 17.0+ deployment target
- Device: iPhone
- Include Tests
```

**Tasks:**
- [ ] Create Xcode project (TidyVibes)
- [ ] Configure SwiftData container in App file
- [ ] Set up folder structure per above
- [ ] Add Info.plist entries:
  - `NSCameraUsageDescription` — "TidyVibes needs camera access to photograph your items"
  - `NSPhotoLibraryUsageDescription` — "TidyVibes can import photos from your library"
  - `NSSpeechRecognitionUsageDescription` — "TidyVibes uses speech recognition for voice capture"
  - `NSMicrophoneUsageDescription` — "TidyVibes needs microphone access for voice input"
- [ ] Create `APIKeys.swift` (gitignored) with OpenAI key reference
- [ ] Add `ikea_products.json` to Resources

### 1.2 Data Models

```swift
// MARK: - StorageSpace.swift
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

// MARK: - Item.swift
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

// MARK: - Enums.swift
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

// MARK: - IKEAProduct.swift (Codable, not SwiftData)
struct IKEAProduct: Codable, Identifiable {
    let id: String
    let name: String
    let productId: String
    let type: String
    let drawers: [IKEADrawer]?
    let dimensions: IKEADimensions?
    
    struct IKEADrawer: Codable {
        let position: Int?
        let widthInches: Double
        let depthInches: Double
        let heightInches: Double
    }
    
    struct IKEADimensions: Codable {
        let widthInches: Double
        let depthInches: Double
        let heightInches: Double
    }
}
```

### 1.3 IKEA Data Service

```swift
// MARK: - IKEADataService.swift
import Foundation

class IKEADataService {
    static let shared = IKEADataService()
    
    private var products: [IKEAProduct] = []
    
    private init() {
        loadProducts()
    }
    
    private func loadProducts() {
        guard let url = Bundle.main.url(forResource: "ikea_products", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([IKEAProduct].self, from: data) else {
            print("Failed to load IKEA products")
            return
        }
        products = decoded
    }
    
    func searchProducts(query: String) -> [IKEAProduct] {
        guard !query.isEmpty else { return products }
        let lowercased = query.lowercased()
        return products.filter { 
            $0.name.lowercased().contains(lowercased) ||
            $0.id.lowercased().contains(lowercased)
        }
    }
    
    func getProduct(id: String) -> IKEAProduct? {
        products.first { $0.id == id }
    }
    
    var allProducts: [IKEAProduct] { products }
    
    var popularProducts: [IKEAProduct] {
        // Return most common products first
        let popularIds = ["alex_drawer_unit", "kallax_insert", "malm_6drawer", 
                         "skubb_box", "kuggis_box", "hemnes_8drawer"]
        return popularIds.compactMap { getProduct(id: $0) }
    }
}
```

### 1.4 IKEA Products JSON

Create `ikea_products.json` in Resources:

```json
[
  {
    "id": "alex_drawer_unit",
    "name": "ALEX Drawer Unit",
    "productId": "004.735.56",
    "type": "drawer_unit",
    "drawers": [
      { "position": 1, "widthInches": 12.625, "depthInches": 16.875, "heightInches": 2.75 },
      { "position": 2, "widthInches": 12.625, "depthInches": 16.875, "heightInches": 2.75 },
      { "position": 3, "widthInches": 12.625, "depthInches": 16.875, "heightInches": 2.75 },
      { "position": 4, "widthInches": 12.625, "depthInches": 16.875, "heightInches": 2.75 },
      { "position": 5, "widthInches": 12.625, "depthInches": 16.875, "heightInches": 5.5 }
    ]
  },
  {
    "id": "kallax_insert_2drawer",
    "name": "KALLAX Insert with 2 Drawers",
    "productId": "702.866.45",
    "type": "drawer_insert",
    "drawers": [
      { "position": 1, "widthInches": 13, "depthInches": 13, "heightInches": 5.875 },
      { "position": 2, "widthInches": 13, "depthInches": 13, "heightInches": 5.875 }
    ]
  },
  {
    "id": "malm_6drawer",
    "name": "MALM 6-Drawer Dresser",
    "productId": "102.145.57",
    "type": "drawer_unit",
    "drawers": [
      { "position": 1, "widthInches": 28.75, "depthInches": 16.5, "heightInches": 4.25 },
      { "position": 2, "widthInches": 28.75, "depthInches": 16.5, "heightInches": 4.25 },
      { "position": 3, "widthInches": 28.75, "depthInches": 16.5, "heightInches": 6 },
      { "position": 4, "widthInches": 28.75, "depthInches": 16.5, "heightInches": 6 },
      { "position": 5, "widthInches": 28.75, "depthInches": 16.5, "heightInches": 6 },
      { "position": 6, "widthInches": 28.75, "depthInches": 16.5, "heightInches": 6 }
    ]
  },
  {
    "id": "skubb_box_set",
    "name": "SKUBB Box (Set of 6)",
    "productId": "001.863.90",
    "type": "box",
    "dimensions": { "widthInches": 12.25, "depthInches": 13.5, "heightInches": 5.25 }
  },
  {
    "id": "kuggis_box_lid",
    "name": "KUGGIS Box with Lid",
    "productId": "102.802.03",
    "type": "box",
    "dimensions": { "widthInches": 7, "depthInches": 10.25, "heightInches": 3.25 }
  },
  {
    "id": "tjena_storage_box",
    "name": "TJENA Storage Box with Lid",
    "productId": "603.954.28",
    "type": "box",
    "dimensions": { "widthInches": 9.75, "depthInches": 13.75, "heightInches": 7.75 }
  },
  {
    "id": "hemnes_8drawer",
    "name": "HEMNES 8-Drawer Dresser",
    "productId": "003.113.04",
    "type": "drawer_unit",
    "drawers": [
      { "position": 1, "widthInches": 15, "depthInches": 14.5, "heightInches": 4.5 },
      { "position": 2, "widthInches": 15, "depthInches": 14.5, "heightInches": 4.5 },
      { "position": 3, "widthInches": 15, "depthInches": 14.5, "heightInches": 4.5 },
      { "position": 4, "widthInches": 15, "depthInches": 14.5, "heightInches": 4.5 },
      { "position": 5, "widthInches": 15, "depthInches": 14.5, "heightInches": 6 },
      { "position": 6, "widthInches": 15, "depthInches": 14.5, "heightInches": 6 },
      { "position": 7, "widthInches": 15, "depthInches": 14.5, "heightInches": 6 },
      { "position": 8, "widthInches": 15, "depthInches": 14.5, "heightInches": 6 }
    ]
  },
  {
    "id": "nordli_4drawer",
    "name": "NORDLI 4-Drawer Dresser",
    "productId": "092.394.95",
    "type": "drawer_unit",
    "drawers": [
      { "position": 1, "widthInches": 15.375, "depthInches": 16.125, "heightInches": 5 },
      { "position": 2, "widthInches": 15.375, "depthInches": 16.125, "heightInches": 5 },
      { "position": 3, "widthInches": 15.375, "depthInches": 16.125, "heightInches": 5 },
      { "position": 4, "widthInches": 15.375, "depthInches": 16.125, "heightInches": 5 }
    ]
  },
  {
    "id": "brimnes_4drawer",
    "name": "BRIMNES 4-Drawer Dresser",
    "productId": "403.603.65",
    "type": "drawer_unit",
    "drawers": [
      { "position": 1, "widthInches": 15, "depthInches": 16.5, "heightInches": 5.5 },
      { "position": 2, "widthInches": 15, "depthInches": 16.5, "heightInches": 5.5 },
      { "position": 3, "widthInches": 15, "depthInches": 16.5, "heightInches": 5.5 },
      { "position": 4, "widthInches": 15, "depthInches": 16.5, "heightInches": 5.5 }
    ]
  },
  {
    "id": "kullen_5drawer",
    "name": "KULLEN 5-Drawer Dresser",
    "productId": "803.092.45",
    "type": "drawer_unit",
    "drawers": [
      { "position": 1, "widthInches": 13.25, "depthInches": 15.75, "heightInches": 4.75 },
      { "position": 2, "widthInches": 13.25, "depthInches": 15.75, "heightInches": 4.75 },
      { "position": 3, "widthInches": 13.25, "depthInches": 15.75, "heightInches": 4.75 },
      { "position": 4, "widthInches": 13.25, "depthInches": 15.75, "heightInches": 4.75 },
      { "position": 5, "widthInches": 13.25, "depthInches": 15.75, "heightInches": 4.75 }
    ]
  }
]
```

### 1.5 Camera Capture

```swift
// MARK: - CameraView.swift
import SwiftUI
import UIKit

struct CameraView: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    @Environment(\.dismiss) var dismiss
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, 
                                   didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let image = info[.originalImage] as? UIImage {
                parent.image = image
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
    }
}
```

### 1.6 GPT Service for Object Detection

```swift
// MARK: - GPTService.swift
import Foundation
import UIKit

struct DetectedItem: Codable, Identifiable {
    let id: UUID
    let name: String
    let quantity: Int
    let boundingBox: BoundingBox?
    
    struct BoundingBox: Codable {
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

class GPTService {
    static let shared = GPTService()
    
    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"
    
    private init() {
        // Load from Keychain or secure storage
        self.apiKey = ProcessInfo.processInfo.environment["OPENAI_API_KEY"] ?? ""
    }
    
    // MARK: - Object Detection from Photo
    func detectItems(in image: UIImage) async throws -> [DetectedItem] {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw GPTError.invalidImage
        }
        let base64Image = imageData.base64EncodedString()
        
        let prompt = """
        Analyze this photo and identify all distinct objects/items visible.
        
        Return a JSON array with this exact structure:
        [
          {
            "name": "item name (be specific, e.g. 'scissors' not 'cutting tool')",
            "quantity": 1,
            "boundingBox": {
              "x": 0.1,
              "y": 0.2,
              "width": 0.15,
              "height": 0.1
            }
          }
        ]
        
        Rules:
        - Coordinates are normalized 0-1 from top-left corner
        - Group identical items (e.g., "pens" with quantity 5)
        - Be specific with names (brand if visible)
        - Include ALL visible items, even small ones
        - Return ONLY the JSON array, no other text
        """
        
        let response = try await callGPT4Vision(prompt: prompt, imageBase64: base64Image)
        return try parseDetectedItems(from: response)
    }
    
    // MARK: - Parse Voice Input to Items
    func parseVoiceInput(_ transcript: String) async throws -> [DetectedItem] {
        let prompt = """
        The user is listing items from their drawer/storage. Parse their speech into a structured list.
        
        User said: "\(transcript)"
        
        Return a JSON array:
        [
          {"name": "item name", "quantity": 1}
        ]
        
        Rules:
        - Extract quantities when mentioned (e.g., "five pens" → quantity: 5)
        - Normalize item names (e.g., "a couple scissors" → "scissors" quantity: 2)
        - Split compound items (e.g., "pens and pencils" → two items)
        - Return ONLY the JSON array
        """
        
        let response = try await callGPT(prompt: prompt)
        return try parseDetectedItems(from: response)
    }
    
    // MARK: - Semantic Grouping
    func groupItems(_ items: [String]) async throws -> [ItemGroup] {
        let itemList = items.joined(separator: ", ")
        
        let prompt = """
        Group these household items into logical categories for drawer organization:
        
        Items: \(itemList)
        
        Return JSON:
        {
          "groups": [
            {
              "category": "category_name",
              "displayName": "Display Name",
              "items": ["item1", "item2"]
            }
          ]
        }
        
        Common categories: office_supplies, tools, electronics, documents, 
        crafts, personal_care, kitchen, medical, cables, miscellaneous
        
        Return ONLY the JSON.
        """
        
        let response = try await callGPT(prompt: prompt)
        return try parseGroups(from: response)
    }
    
    // MARK: - Private Helpers
    private func callGPT4Vision(prompt: String, imageBase64: String) async throws -> String {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [
                [
                    "role": "user",
                    "content": [
                        ["type": "text", "text": prompt],
                        ["type": "image_url", "image_url": ["url": "data:image/jpeg;base64,\(imageBase64)"]]
                    ]
                ]
            ],
            "max_tokens": 2000
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let choices = json?["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw GPTError.invalidResponse
        }
        
        return content
    }
    
    private func callGPT(prompt: String) async throws -> String {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let body: [String: Any] = [
            "model": "gpt-4o",
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 1000
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        
        guard let choices = json?["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw GPTError.invalidResponse
        }
        
        return content
    }
    
    private func parseDetectedItems(from response: String) throws -> [DetectedItem] {
        // Extract JSON from response (handle markdown code blocks)
        var jsonString = response
        if let start = response.range(of: "["),
           let end = response.range(of: "]", options: .backwards) {
            jsonString = String(response[start.lowerBound...end.upperBound])
        }
        
        let data = jsonString.data(using: .utf8)!
        return try JSONDecoder().decode([DetectedItem].self, from: data)
    }
    
    private func parseGroups(from response: String) throws -> [ItemGroup] {
        var jsonString = response
        if let start = response.range(of: "{"),
           let end = response.range(of: "}", options: .backwards) {
            jsonString = String(response[start.lowerBound...end.upperBound])
        }
        
        let data = jsonString.data(using: .utf8)!
        let result = try JSONDecoder().decode(GroupingResponse.self, from: data)
        return result.groups
    }
    
    enum GPTError: Error {
        case invalidImage
        case invalidResponse
        case parsingFailed
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
```

### 1.7 Voice Capture Service

```swift
// MARK: - SpeechService.swift
import Speech
import AVFoundation

class SpeechService: ObservableObject {
    @Published var transcript: String = ""
    @Published var isRecording: Bool = false
    @Published var error: String?
    
    private var audioEngine = AVAudioEngine()
    private var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    private var recognitionTask: SFSpeechRecognitionTask?
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale(identifier: "en-US"))
    
    func requestAuthorization() async -> Bool {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: status == .authorized)
            }
        }
    }
    
    func startRecording() throws {
        // Cancel any existing task
        recognitionTask?.cancel()
        recognitionTask = nil
        
        // Configure audio session
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()
        guard let recognitionRequest = recognitionRequest else {
            throw SpeechError.requestFailed
        }
        
        recognitionRequest.shouldReportPartialResults = true
        
        let inputNode = audioEngine.inputNode
        
        recognitionTask = speechRecognizer?.recognitionTask(with: recognitionRequest) { [weak self] result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self?.transcript = result.bestTranscription.formattedString
                }
            }
            
            if error != nil || result?.isFinal == true {
                self?.stopRecording()
            }
        }
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        DispatchQueue.main.async {
            self.isRecording = true
        }
    }
    
    func stopRecording() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionRequest?.endAudio()
        recognitionRequest = nil
        recognitionTask = nil
        
        DispatchQueue.main.async {
            self.isRecording = false
        }
    }
    
    enum SpeechError: Error {
        case notAuthorized
        case requestFailed
    }
}
```

### Phase 1 Deliverable

> User can photograph items → see AI-detected labels → correct mistakes → OR speak item list → select IKEA storage or enter custom dimensions → save to named storage. Data persists locally.

---

## Phase 2: Spatial Bookmark & Search (Week 3-4)

**Goal:** User can visually see items in their storage spaces as a 2D spatial map and search across all spaces.

### 2.1 Home Screen

```swift
// MARK: - HomeView.swift
import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StorageSpace.updatedAt, order: .reverse) private var spaces: [StorageSpace]
    
    @State private var searchText = ""
    @State private var showingCapture = false
    
    var body: some View {
        NavigationStack {
            Group {
                if spaces.isEmpty {
                    EmptyStateView(showingCapture: $showingCapture)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Search bar
                            SearchBar(text: $searchText)
                                .padding(.horizontal)
                            
                            // Storage cards
                            ForEach(spaces) { space in
                                NavigationLink(destination: StorageDetailView(space: space)) {
                                    StorageCardView(space: space)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("TidyVibes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingCapture = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingCapture) {
                CaptureFlowView()
            }
        }
    }
}

// MARK: - EmptyStateView.swift
struct EmptyStateView: View {
    @Binding var showingCapture: Bool
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Text("🪴")
                .font(.system(size: 64))
            
            Text("Your spaces are waiting")
                .font(.title2)
                .fontWeight(.semibold)
            
            Text("Start with your messiest drawer.\nThe one that defeats you every time.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            Button(action: { showingCapture = true }) {
                Label("Add your first drawer", systemImage: "plus")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)
            
            Text("Takes about 2 minutes")
                .font(.caption)
                .foregroundColor(.secondary)
            
            Spacer()
        }
        .padding()
    }
}
```

### 2.2 Spatial Bookmark Canvas

```swift
// MARK: - SpatialBookmarkView.swift
import SwiftUI

struct SpatialBookmarkView: View {
    let space: StorageSpace
    let highlightedItemId: UUID?
    
    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            let aspectRatio = space.widthInches / space.depthInches
            let viewWidth = geometry.size.width - 32
            let viewHeight = viewWidth / aspectRatio
            
            ZStack {
                // Storage boundary
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
                
                // Items
                ForEach(space.items) { item in
                    ItemNodeView(
                        item: item,
                        containerSize: CGSize(width: viewWidth, height: viewHeight),
                        isHighlighted: item.id == highlightedItemId
                    )
                }
            }
            .frame(width: viewWidth, height: viewHeight)
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = max(1.0, min(3.0, value))
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if scale > 1.0 {
                            offset = value.translation
                        }
                    }
                    .onEnded { _ in
                        withAnimation {
                            if scale <= 1.0 {
                                offset = .zero
                            }
                        }
                    }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

// MARK: - ItemNodeView.swift
struct ItemNodeView: View {
    let item: Item
    let containerSize: CGSize
    let isHighlighted: Bool
    
    @State private var showingDetail = false
    
    private var position: CGPoint {
        CGPoint(
            x: item.positionX * containerSize.width,
            y: item.positionY * containerSize.height
        )
    }
    
    private var itemSize: CGSize {
        // Estimate size based on category or use defaults
        let baseSize: CGFloat = min(containerSize.width, containerSize.height) * 0.15
        return CGSize(width: baseSize * 1.2, height: baseSize)
    }
    
    var body: some View {
        VStack(spacing: 4) {
            // Item rectangle
            RoundedRectangle(cornerRadius: 8)
                .fill(isHighlighted ? Color.accentColor.opacity(0.3) : Color.gray.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(isHighlighted ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: isHighlighted ? 2 : 1)
                )
                .frame(width: itemSize.width, height: itemSize.height)
                .shadow(color: .black.opacity(0.05), radius: 2, y: 1)
            
            // Item name
            Text(item.name)
                .font(.caption2)
                .lineLimit(1)
                .foregroundColor(isHighlighted ? .accentColor : .primary)
            
            // Quantity badge
            if item.quantity > 1 {
                Text("×\(item.quantity)")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .position(position)
        .onTapGesture {
            showingDetail = true
        }
        .popover(isPresented: $showingDetail) {
            ItemDetailPopover(item: item)
        }
        .animation(.easeInOut(duration: 0.3), value: isHighlighted)
    }
}

// MARK: - ItemDetailPopover.swift
struct ItemDetailPopover: View {
    let item: Item
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(item.name)
                .font(.headline)
            
            if item.quantity > 1 {
                Label("\(item.quantity) items", systemImage: "number")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let category = item.category {
                Label(category.capitalized, systemImage: "tag")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Label("Added \(item.createdAt.formatted(date: .abbreviated, time: .omitted))", 
                  systemImage: "calendar")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .padding()
        .frame(minWidth: 200)
    }
}
```

### 2.3 Search Service

```swift
// MARK: - SearchService.swift
import Foundation

class SearchService {
    static let shared = SearchService()
    
    // Common synonyms for household items
    private let synonyms: [String: [String]] = [
        "scissors": ["shears", "cutting tool"],
        "charger": ["cable", "cord", "usb"],
        "pen": ["pencil", "marker", "writing"],
        "tape": ["adhesive", "sticky"],
        "batteries": ["battery", "cells"],
        "keys": ["key", "keychain"],
        "headphones": ["earbuds", "earphones", "airpods"]
    ]
    
    func search(query: String, in items: [Item]) -> [SearchResult] {
        let normalizedQuery = query.lowercased().trimmingCharacters(in: .whitespaces)
        
        var results: [SearchResult] = []
        
        for item in items {
            let score = calculateMatchScore(query: normalizedQuery, itemName: item.name.lowercased())
            if score > 0 {
                results.append(SearchResult(item: item, score: score))
            }
        }
        
        return results.sorted { $0.score > $1.score }
    }
    
    private func calculateMatchScore(query: String, itemName: String) -> Double {
        // Exact match
        if itemName == query { return 1.0 }
        
        // Contains match
        if itemName.contains(query) { return 0.9 }
        
        // Synonym match
        for (key, synonymList) in synonyms {
            if (key == query || synonymList.contains(query)) &&
               (key == itemName || synonymList.contains(where: { itemName.contains($0) })) {
                return 0.8
            }
        }
        
        // Levenshtein distance for typos
        let distance = levenshteinDistance(query, itemName)
        let maxLength = max(query.count, itemName.count)
        let similarity = 1.0 - (Double(distance) / Double(maxLength))
        
        if similarity > 0.7 {
            return similarity * 0.7
        }
        
        return 0
    }
    
    private func levenshteinDistance(_ s1: String, _ s2: String) -> Int {
        let s1 = Array(s1)
        let s2 = Array(s2)
        var dist = [[Int]](repeating: [Int](repeating: 0, count: s2.count + 1), count: s1.count + 1)
        
        for i in 0...s1.count { dist[i][0] = i }
        for j in 0...s2.count { dist[0][j] = j }
        
        for i in 1...s1.count {
            for j in 1...s2.count {
                if s1[i-1] == s2[j-1] {
                    dist[i][j] = dist[i-1][j-1]
                } else {
                    dist[i][j] = min(dist[i-1][j] + 1, dist[i][j-1] + 1, dist[i-1][j-1] + 1)
                }
            }
        }
        
        return dist[s1.count][s2.count]
    }
}

struct SearchResult: Identifiable {
    let id = UUID()
    let item: Item
    let score: Double
}
```

### Phase 2 Deliverable

> User can browse storage spaces visually, see items positioned in 2D spatial maps, tap items for details, and search "where is my X?" with instant highlighted results.

---

## Phase 3: AI Layout Suggestions (Week 5-6)

**Goal:** AI analyzes items and suggests better arrangements using semantic grouping + algorithmic placement.

### 3.1 Layout Engine

```swift
// MARK: - LayoutEngine.swift
import Foundation

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
```

### 3.2 Layout Suggestion View

```swift
// MARK: - LayoutSuggestionView.swift
import SwiftUI

struct LayoutSuggestionView: View {
    let space: StorageSpace
    let suggestion: LayoutSuggestion
    let onApply: () -> Void
    let onDismiss: () -> Void
    
    @State private var selectedStyle: OrganizationStyle = .smart
    @State private var showingStylePicker = false
    
    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("✨ Here's a smarter way to organize this")
                        .font(.headline)
                    Text(suggestion.reasoning)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            // Before/After comparison
            HStack(spacing: 16) {
                VStack {
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    SpatialBookmarkView(space: space, highlightedItemId: nil)
                        .frame(height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }
                
                Image(systemName: "arrow.right")
                    .foregroundColor(.accentColor)
                
                VStack {
                    Text("Suggested")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    SuggestedLayoutPreview(
                        space: space,
                        suggestion: suggestion
                    )
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentColor, lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal)
            
            // Style picker
            Button(action: { showingStylePicker = true }) {
                HStack {
                    Text("Style:")
                    Text(selectedStyle.displayName)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.down")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }
            
            Spacer()
            
            // Actions
            HStack(spacing: 16) {
                Button(action: { showingStylePicker = true }) {
                    Text("Different style")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }
                
                Button(action: onApply) {
                    Text("Apply layout")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingStylePicker) {
            StylePickerView(selectedStyle: $selectedStyle)
        }
    }
}

// MARK: - SuggestedLayoutPreview.swift
struct SuggestedLayoutPreview: View {
    let space: StorageSpace
    let suggestion: LayoutSuggestion
    
    var body: some View {
        GeometryReader { geometry in
            let aspectRatio = space.widthInches / space.depthInches
            let viewWidth = geometry.size.width - 16
            let viewHeight = viewWidth / aspectRatio
            
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                
                ForEach(space.items) { item in
                    if let position = suggestion.positions[item.id] {
                        SuggestedItemNode(
                            item: item,
                            position: position,
                            containerSize: CGSize(width: viewWidth, height: viewHeight)
                        )
                    }
                }
            }
            .frame(width: viewWidth, height: viewHeight)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct SuggestedItemNode: View {
    let item: Item
    let position: CGPoint
    let containerSize: CGSize
    
    var body: some View {
        let screenPosition = CGPoint(
            x: position.x * containerSize.width,
            y: position.y * containerSize.height
        )
        
        RoundedRectangle(cornerRadius: 6)
            .fill(Color.accentColor.opacity(0.2))
            .overlay(
                Text(item.name)
                    .font(.system(size: 8))
                    .lineLimit(1)
            )
            .frame(width: 40, height: 30)
            .position(screenPosition)
    }
}
```

### Phase 3 Deliverable

> User taps "Suggest layout" → sees AI-powered organization recommendation with before/after comparison → can apply it with one tap or try different styles.

---

## Phase 4: Polish & Voice (Week 7-8)

**Goal:** Voice updates, onboarding, and beta-ready polish.

### 4.1 Voice Update Support

```swift
// MARK: - VoiceUpdateService.swift
import Foundation

class VoiceUpdateService {
    static let shared = VoiceUpdateService()
    
    enum UpdateAction {
        case move(itemName: String, fromLocation: String?, toLocation: String)
        case add(itemName: String, toLocation: String, quantity: Int)
        case remove(itemName: String, fromLocation: String?)
        case unknown
    }
    
    func parseUpdate(_ transcript: String) async throws -> UpdateAction {
        let prompt = """
        Parse this voice command about moving/adding/removing items:
        
        "\(transcript)"
        
        Return JSON:
        {
          "action": "move" | "add" | "remove",
          "itemName": "item name",
          "fromLocation": "location name or null",
          "toLocation": "location name or null",
          "quantity": 1
        }
        
        Examples:
        - "I moved the scissors to the kitchen drawer" → move, scissors, null, kitchen drawer
        - "Add batteries to my office desk" → add, batteries, null, office desk
        - "Remove the old tape" → remove, old tape, null
        
        Return ONLY the JSON.
        """
        
        let response = try await GPTService.shared.callGPT(prompt: prompt)
        return parseAction(from: response)
    }
    
    private func parseAction(from response: String) -> UpdateAction {
        // Parse JSON response and return appropriate action
        // Implementation details...
        return .unknown
    }
}
```

### 4.2 Onboarding Flow

```swift
// MARK: - OnboardingView.swift
import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0
    
    var body: some View {
        TabView(selection: $currentPage) {
            OnboardingPage(
                emoji: "🧠",
                title: "Your spatial memory, externalized",
                description: "TidyVibes remembers where everything is so you don't have to.",
                page: 0
            )
            .tag(0)
            
            OnboardingPage(
                emoji: "📸",
                title: "Capture in seconds",
                description: "Lay out your items, snap a photo. AI does the rest.",
                page: 1
            )
            .tag(1)
            
            OnboardingPage(
                emoji: "✨",
                title: "See the magic",
                description: "Get smart layout suggestions and find anything instantly.",
                page: 2,
                showGetStarted: true,
                onGetStarted: { hasCompletedOnboarding = true }
            )
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct OnboardingPage: View {
    let emoji: String
    let title: String
    let description: String
    let page: Int
    var showGetStarted = false
    var onGetStarted: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 32) {
            Spacer()
            
            Text(emoji)
                .font(.system(size: 80))
            
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Spacer()
            
            if showGetStarted {
                Button(action: { onGetStarted?() }) {
                    Text("Get Started")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}
```

### 4.3 Constants & Theming

```swift
// MARK: - Constants.swift
import SwiftUI

enum AppColors {
    static let background = Color("Background")  // #FDF6E9 (cream)
    static let surface = Color("Surface")        // #FFFFFF
    static let accent = Color("Accent")          // #2DD4BF (teal)
    static let textPrimary = Color("TextPrimary")
    static let textSecondary = Color("TextSecondary")
}

enum AppSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
}

enum AppCornerRadius {
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
}
```

### Phase 4 Deliverable

> Beta-ready app with onboarding, voice input for updates, polished UI, and all P0/P1 features functional.

---

## Risk Mitigation

| Risk | Likelihood | Impact | Mitigation |
|------|-----------|--------|------------|
| Object detection accuracy too low | Medium | High | GPT-4V is strong; fallback to voice capture |
| Layout algorithm produces poor results | Medium | Medium | Start simple, iterate based on feedback |
| IKEA dimensions incomplete | Low | Medium | Start with top 10 products, expand |
| GPT API costs spike | Low | Medium | Cache grouping results, batch requests |
| Solo dev burnout | High | High | Cut P2 features, strict phase discipline |

---

## Cut List (If Running Behind)

Ordered by what to cut first:

1. **Voice updates** (Phase 4) — Users can manually edit
2. **Multiple organization styles** — Keep "Smart" only
3. **Onboarding flow** — Good empty state is enough
4. **Fuzzy search** — Exact match works
5. **Voice capture** — Photo capture is primary
6. **NEVER cut:** Capture → Spatial view → Search → AI suggestions (core value)

---

## Definition of Done (MVP)

The MVP is ready for beta when a user can:

1. ✅ Open the app and understand what to do
2. ✅ Photograph items OR speak an item list
3. ✅ See AI-detected items and correct mistakes
4. ✅ Select IKEA storage OR enter custom dimensions
5. ✅ Save items to a named storage space
6. ✅ View items as a 2D spatial bookmark
7. ✅ Search "where is my X?" and see highlighted result
8. ✅ Get AI layout suggestions with before/after comparison
9. ✅ Apply suggested layout with one tap
10. ✅ Do all of the above offline (except AI calls)

---

## Immediate Next Steps

1. **Create Xcode project** with SwiftUI + SwiftData
2. **Implement data models** (StorageSpace, Item)
3. **Create ikea_products.json** with top 10 IKEA products
4. **Build camera capture + GPT detection pipeline**
5. **Test with real drawer photos**

Start with the **capture → review → save flow**. Everything else follows from having items in the database.

---

*"The joy is seeing your items present, beautifully arranged."*

Let's build spatial memory.
