import Foundation
import UIKit

/// Backup AI provider using xAI Grok API.
/// Supports vision (item detection) and text parsing. No image generation.
class GrokVisionService: VisionAPIProtocol {
    private let apiKey: String
    private let baseURL = "https://api.x.ai/v1/chat/completions"
    private let visionModel = "grok-2-vision-latest"
    private let textModel = "grok-2-latest"

    init() {
        self.apiKey = ProcessInfo.processInfo.environment["GROK_API_KEY"] ?? ""
    }

    // MARK: - VisionAPIProtocol

    func detectItems(in image: UIImage) async throws -> [DetectedItem] {
        guard !apiKey.isEmpty else { throw VisionAPIError.apiKeyMissing }
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            throw VisionAPIError.invalidImage
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

        let body: [String: Any] = [
            "model": visionModel,
            "messages": [[
                "role": "user",
                "content": [
                    ["type": "text", "text": prompt],
                    ["type": "image_url", "image_url": [
                        "url": "data:image/jpeg;base64,\(base64Image)"
                    ]]
                ]
            ]],
            "max_tokens": 2000
        ]

        let response = try await callGrok(body: body)
        return try parseDetectedItems(from: response)
    }

    func parseItemInput(_ text: String) async throws -> [DetectedItem] {
        guard !apiKey.isEmpty else { throw VisionAPIError.apiKeyMissing }

        let prompt = """
        Parse this item list into structured data. The input may be:
        - A voice transcript: "scissors, two rolls of tape, about five pens"
        - A comma-separated list: "scissors, tape x2, pens x5"

        Input: "\(text)"

        Return a JSON array:
        [
          {"name": "item name", "quantity": 1}
        ]

        Rules:
        - Extract quantities when mentioned (e.g., "five pens" → quantity: 5, "tape x2" → quantity: 2)
        - Normalize item names (e.g., "a couple scissors" → "scissors" quantity: 2)
        - Split compound items (e.g., "pens and pencils" → two items)
        - Return ONLY the JSON array, no other text
        """

        let response = try await callGrokText(prompt: prompt)
        return try parseDetectedItems(from: response)
    }

    func groupItems(_ items: [String]) async throws -> [ItemGroup] {
        guard !apiKey.isEmpty else { throw VisionAPIError.apiKeyMissing }
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

        let response = try await callGrokText(prompt: prompt)
        return try parseGroups(from: response)
    }

    // MARK: - Text-Only Call (used by LayoutImagePipeline for planning)

    func callGrokText(prompt: String) async throws -> String {
        guard !apiKey.isEmpty else { throw VisionAPIError.apiKeyMissing }

        let body: [String: Any] = [
            "model": textModel,
            "messages": [["role": "user", "content": prompt]],
            "max_tokens": 1500
        ]

        return try await callGrok(body: body)
    }

    // MARK: - Private Helpers

    private func callGrok(body: [String: Any]) async throws -> String {
        var request = URLRequest(url: URL(string: baseURL)!)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let choices = json?["choices"] as? [[String: Any]],
              let message = choices.first?["message"] as? [String: Any],
              let content = message["content"] as? String else {
            throw VisionAPIError.invalidResponse
        }

        return content
    }

    private func parseDetectedItems(from response: String) throws -> [DetectedItem] {
        var jsonString = response
        if let start = response.range(of: "["),
           let end = response.range(of: "]", options: .backwards) {
            jsonString = String(response[start.lowerBound...end.upperBound])
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw VisionAPIError.parsingFailed
        }
        return try JSONDecoder().decode([DetectedItem].self, from: data)
    }

    private func parseGroups(from response: String) throws -> [ItemGroup] {
        var jsonString = response
        if let start = response.range(of: "{"),
           let end = response.range(of: "}", options: .backwards) {
            jsonString = String(response[start.lowerBound...end.upperBound])
        }

        guard let data = jsonString.data(using: .utf8) else {
            throw VisionAPIError.parsingFailed
        }
        let result = try JSONDecoder().decode(GroupingResponse.self, from: data)
        return result.groups
    }
}
