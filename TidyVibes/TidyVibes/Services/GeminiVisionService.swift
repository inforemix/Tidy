import Foundation
import UIKit

/// Primary AI provider using Google Gemini API.
/// Supports vision (item detection), text parsing, and image generation.
class GeminiVisionService: VisionAPIProtocol, ImageGenerationCapable {
    private let apiKey: String
    private let baseURL = "https://generativelanguage.googleapis.com/v1beta"
    private let model = "gemini-2.0-flash"

    init() {
        self.apiKey = ProcessInfo.processInfo.environment["GEMINI_API_KEY"] ?? ""
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
            "contents": [[
                "parts": [
                    ["text": prompt],
                    ["inline_data": [
                        "mime_type": "image/jpeg",
                        "data": base64Image
                    ]]
                ]
            ]]
        ]

        let text = try await callGemini(body: body)
        return try parseDetectedItems(from: text)
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

        let body: [String: Any] = [
            "contents": [[
                "parts": [["text": prompt]]
            ]]
        ]

        let response = try await callGemini(body: body)
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

        let body: [String: Any] = [
            "contents": [[
                "parts": [["text": prompt]]
            ]]
        ]

        let response = try await callGemini(body: body)
        return try parseGroups(from: response)
    }

    // MARK: - ImageGenerationCapable

    func generateImage(prompt: String) async throws -> UIImage {
        guard !apiKey.isEmpty else { throw VisionAPIError.apiKeyMissing }

        let body: [String: Any] = [
            "contents": [[
                "parts": [["text": prompt]]
            ]],
            "generationConfig": [
                "responseModalities": ["TEXT", "IMAGE"]
            ]
        ]

        let url = URL(string: "\(baseURL)/models/\(model):generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let candidates = json?["candidates"] as? [[String: Any]],
              let content = candidates.first?["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]] else {
            throw VisionAPIError.imageGenerationFailed
        }

        // Look for inline_data part with image
        for part in parts {
            if let inlineData = part["inline_data"] as? [String: Any],
               let mimeType = inlineData["mime_type"] as? String,
               mimeType.starts(with: "image/"),
               let b64 = inlineData["data"] as? String,
               let imageData = Data(base64Encoded: b64),
               let image = UIImage(data: imageData) {
                return image
            }
        }

        throw VisionAPIError.imageGenerationFailed
    }

    // MARK: - Private Helpers

    private func callGemini(body: [String: Any]) async throws -> String {
        let url = URL(string: "\(baseURL)/models/\(model):generateContent?key=\(apiKey)")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, _) = try await URLSession.shared.data(for: request)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]

        guard let candidates = json?["candidates"] as? [[String: Any]],
              let content = candidates.first?["content"] as? [String: Any],
              let parts = content["parts"] as? [[String: Any]],
              let text = parts.first?["text"] as? String else {
            throw VisionAPIError.invalidResponse
        }

        return text
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
