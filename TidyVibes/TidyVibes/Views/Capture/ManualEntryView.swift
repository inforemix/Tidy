import SwiftUI

struct ManualEntryView: View {
    @Binding var detectedItems: [DetectedItem]
    @Binding var isProcessing: Bool
    @State private var itemText: String = ""

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            VStack(spacing: 12) {
                Image(systemName: "text.cursor")
                    .font(.system(size: 50))
                    .foregroundColor(.orange)

                Text("Type your items")
                    .font(.title2)
                    .fontWeight(.semibold)

                Text("Separate items with commas.\nUse \"x2\" or \"x5\" for quantities.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
            }

            // Text input area
            ZStack(alignment: .topLeading) {
                TextEditor(text: $itemText)
                    .frame(height: 120)
                    .padding(8)
                    .scrollContentBackground(.hidden)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)

                if itemText.isEmpty {
                    Text("scissors, tape x2, pens x5, passport, batteries...")
                        .foregroundColor(.gray.opacity(0.5))
                        .padding(.horizontal, 12)
                        .padding(.vertical, 16)
                        .allowsHitTesting(false)
                }
            }
            .padding(.horizontal)

            Spacer()

            // Process button — parses locally, no API key needed
            Button(action: processItems) {
                Label("Add Items", systemImage: "plus.circle.fill")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
            }
            .background(itemText.isEmpty ? Color(.systemGray4) : Color.orange)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(itemText.isEmpty)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Type Items")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Local Parsing (no API key required)

    private func processItems() {
        let items = parseItemsLocally(itemText)
        if !items.isEmpty {
            detectedItems = items
        }
    }

    /// Parses comma-separated text into DetectedItems without any network call.
    /// Handles quantity suffixes like "x2", "x 3", "×5".
    private func parseItemsLocally(_ text: String) -> [DetectedItem] {
        let parts = text.components(separatedBy: ",")
        var items: [DetectedItem] = []

        for part in parts {
            var trimmed = part.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !trimmed.isEmpty else { continue }

            var quantity = 1

            // Match trailing quantity: "tape x2", "pens × 5", "item x 10"
            if let range = trimmed.range(
                of: #"\s*[x×]\s*(\d+)\s*$"#,
                options: [.regularExpression, .caseInsensitive]
            ) {
                let matched = String(trimmed[range])
                let digits = matched.components(separatedBy: CharacterSet.decimalDigits.inverted).joined()
                quantity = Int(digits) ?? 1
                trimmed = String(trimmed[trimmed.startIndex..<range.lowerBound])
                    .trimmingCharacters(in: .whitespaces)
            }

            guard !trimmed.isEmpty else { continue }
            items.append(DetectedItem(name: trimmed, quantity: quantity))
        }

        return items
    }
}
