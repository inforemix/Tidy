import Foundation
import UIKit

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

class GPTService {
    static let shared = GPTService()

    private let apiKey: String
    private let baseURL = "https://api.openai.com/v1/chat/completions"

    private init() {
        // Load from environment or secure storage
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
