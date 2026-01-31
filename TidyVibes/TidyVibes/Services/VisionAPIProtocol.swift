import Foundation
import UIKit

// MARK: - VisionAPIProtocol
/// Provider-agnostic protocol for all AI vision and text services.
/// Implementations: GeminiVisionService (primary), GrokVisionService (backup).
protocol VisionAPIProtocol {
    /// Detect items from a photo, returning identified items with positions
    func detectItems(in image: UIImage) async throws -> [DetectedItem]

    /// Parse a voice transcript or comma-separated text into structured items
    func parseItemInput(_ text: String) async throws -> [DetectedItem]

    /// Group items into semantic categories
    func groupItems(_ items: [String]) async throws -> [ItemGroup]
}

// MARK: - ImageGenerationCapable
/// Providers that support image generation conform to this protocol.
protocol ImageGenerationCapable {
    /// Generate an image from a text prompt
    func generateImage(prompt: String) async throws -> UIImage
}

// MARK: - VisionAPIError
enum VisionAPIError: Error, LocalizedError {
    case invalidImage
    case invalidResponse
    case parsingFailed
    case providerUnavailable
    case imageGenerationFailed
    case apiKeyMissing

    var errorDescription: String? {
        switch self {
        case .invalidImage: return "Could not process the image"
        case .invalidResponse: return "AI returned an unexpected response"
        case .parsingFailed: return "Could not parse AI response"
        case .providerUnavailable: return "AI service is currently unavailable"
        case .imageGenerationFailed: return "Could not generate layout image"
        case .apiKeyMissing: return "API key is not configured"
        }
    }
}
