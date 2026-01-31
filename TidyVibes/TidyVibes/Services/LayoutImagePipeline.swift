import Foundation
import UIKit

// MARK: - Arrangement Plan

struct ArrangementPlan: Codable {
    let plan: String
    let placements: [Placement]

    struct Placement: Codable {
        let item: String
        let region: String
        let bbox: [Double]  // [x, y, width, height] normalized 0-1
    }
}

// MARK: - Layout Image Pipeline
/// Custom pipeline: Grok plans the arrangement, Gemini generates the image,
/// then bounding box labels are composited on top.

class LayoutImagePipeline {
    static let shared = LayoutImagePipeline()

    /// Full pipeline: plan arrangement → generate image → composite labels
    func generateLayoutImage(
        items: [Item],
        storage: StorageSpace,
        style: OrganizationStyle
    ) async throws -> (image: UIImage, plan: ArrangementPlan) {

        // STEP 1: LLM plans the arrangement (Grok)
        let plan = try await planArrangement(items: items, storage: storage, style: style)

        // STEP 2: Generate image from plan (Gemini)
        let prompt = buildImagePrompt(plan: plan, storage: storage)
        let generatedImage = try await APIProviderManager.shared.imageGenerator.generateImage(prompt: prompt)

        // STEP 3: Composite bounding box labels onto image
        let composited = compositeLabels(image: generatedImage, plan: plan)

        return (image: composited, plan: plan)
    }

    // MARK: - Step 1: Plan Arrangement (Grok text)

    private func planArrangement(
        items: [Item],
        storage: StorageSpace,
        style: OrganizationStyle
    ) async throws -> ArrangementPlan {
        let itemList = items.map { "\($0.name) (qty: \($0.quantity))" }.joined(separator: ", ")

        let prompt = """
        You are organizing items in a storage space.

        Storage: \(storage.name) (\(storage.widthInches)" x \(storage.depthInches)" x \(storage.heightInches)")
        Items: \(itemList)
        Style: \(style.displayName) — \(style.description)

        Plan an organized arrangement. For each item, specify:
        - Which region it should go in (top-left, top-center, top-right, center-left, center, center-right, bottom-left, bottom-center, bottom-right)
        - A bounding box [x, y, width, height] in normalized 0-1 coordinates

        Return JSON:
        {
          "plan": "Brief description of the arrangement strategy",
          "placements": [
            {"item": "item name", "region": "top-left", "bbox": [0.05, 0.05, 0.25, 0.15]}
          ]
        }

        Rules:
        - Do not overlap bounding boxes
        - Leave 5% padding from edges
        - Group similar items together based on the style
        - Return ONLY the JSON, no other text
        """

        let response = try await APIProviderManager.shared.layoutPlanner.callGrokText(prompt: prompt)
        return try parseArrangementPlan(from: response)
    }

    // MARK: - Step 2: Build Image Prompt

    private func buildImagePrompt(plan: ArrangementPlan, storage: StorageSpace) -> String {
        let placementDescriptions = plan.placements.map { p in
            "\(p.item) placed in the \(p.region)"
        }.joined(separator: ", ")

        return """
        Generate a photorealistic top-down view of an organized \(storage.storageType) \
        (\(storage.widthInches) x \(storage.depthInches) inches). \
        Contents arranged as follows: \(placementDescriptions). \
        \(plan.plan). Clean, well-lit, minimalist styling. \
        Soft shadows, white/cream background. No text labels.
        """
    }

    // MARK: - Step 3: Composite Labels

    private func compositeLabels(image: UIImage, plan: ArrangementPlan) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: image.size)
        return renderer.image { _ in
            image.draw(at: .zero)

            let imageSize = image.size

            for placement in plan.placements {
                guard placement.bbox.count == 4 else { continue }
                let rect = CGRect(
                    x: placement.bbox[0] * imageSize.width,
                    y: placement.bbox[1] * imageSize.height,
                    width: placement.bbox[2] * imageSize.width,
                    height: placement.bbox[3] * imageSize.height
                )

                // Draw semi-transparent bounding box
                UIColor.systemTeal.withAlphaComponent(0.25).setFill()
                UIBezierPath(roundedRect: rect, cornerRadius: 4).fill()

                UIColor.systemTeal.setStroke()
                let border = UIBezierPath(roundedRect: rect, cornerRadius: 4)
                border.lineWidth = 2
                border.stroke()

                // Draw label background
                let label = placement.item
                let attributes: [NSAttributedString.Key: Any] = [
                    .font: UIFont.systemFont(ofSize: max(12, imageSize.width * 0.02), weight: .medium),
                    .foregroundColor: UIColor.white
                ]
                let labelSize = label.size(withAttributes: attributes)
                let labelBgRect = CGRect(
                    x: rect.midX - labelSize.width / 2 - 4,
                    y: rect.maxY - labelSize.height - 6,
                    width: labelSize.width + 8,
                    height: labelSize.height + 4
                )
                UIColor.black.withAlphaComponent(0.6).setFill()
                UIBezierPath(roundedRect: labelBgRect, cornerRadius: 3).fill()

                // Draw label text
                let labelPoint = CGPoint(
                    x: rect.midX - labelSize.width / 2,
                    y: rect.maxY - labelSize.height - 4
                )
                label.draw(at: labelPoint, withAttributes: attributes)
            }
        }
    }

    // MARK: - Parsing

    private func parseArrangementPlan(from response: String) throws -> ArrangementPlan {
        var jsonString = response
        if let start = response.range(of: "{"),
           let end = response.range(of: "}", options: .backwards) {
            jsonString = String(response[start.lowerBound...end.upperBound])
        }
        guard let data = jsonString.data(using: .utf8) else {
            throw VisionAPIError.parsingFailed
        }
        return try JSONDecoder().decode(ArrangementPlan.self, from: data)
    }
}
