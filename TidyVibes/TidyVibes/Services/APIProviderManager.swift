import Foundation

/// Manages AI provider selection with automatic fallback.
/// Default: Gemini (primary), Grok (backup).
class APIProviderManager {
    static let shared = APIProviderManager()

    enum Provider: String, CaseIterable {
        case gemini = "gemini"
        case grok = "grok"

        var displayName: String {
            switch self {
            case .gemini: return "Google Gemini"
            case .grok: return "xAI Grok"
            }
        }
    }

    private let gemini = GeminiVisionService()
    private let grok = GrokVisionService()

    var primaryProvider: Provider = .gemini

    /// Get the active vision service
    var activeService: VisionAPIProtocol {
        switch primaryProvider {
        case .gemini: return gemini
        case .grok: return grok
        }
    }

    /// Get the backup vision service
    var backupService: VisionAPIProtocol {
        switch primaryProvider {
        case .gemini: return grok
        case .grok: return gemini
        }
    }

    /// Image generation is only available via Gemini
    var imageGenerator: ImageGenerationCapable { gemini }

    /// Grok text service used for layout planning
    var layoutPlanner: GrokVisionService { grok }

    /// Execute an operation with automatic fallback to backup provider
    func withFallback<T>(_ operation: (VisionAPIProtocol) async throws -> T) async throws -> T {
        do {
            return try await operation(activeService)
        } catch {
            print("[APIProviderManager] Primary (\(primaryProvider.displayName)) failed: \(error.localizedDescription). Falling back...")
            return try await operation(backupService)
        }
    }
}
