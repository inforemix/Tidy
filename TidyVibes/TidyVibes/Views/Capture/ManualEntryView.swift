import SwiftUI

struct ManualEntryView: View {
    @Binding var detectedItems: [DetectedItem]
    @Binding var isProcessing: Bool
    @State private var itemText: String = ""
    @State private var errorMessage: String?

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

            if let error = errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.horizontal)
            }

            Spacer()

            // Process button
            Button(action: processItems) {
                if isProcessing {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    Label("Process Items", systemImage: "sparkles")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                }
            }
            .background(itemText.isEmpty ? Color(.systemGray4) : Color.orange)
            .foregroundColor(.white)
            .cornerRadius(12)
            .disabled(itemText.isEmpty || isProcessing)
            .padding(.horizontal)
            .padding(.bottom)
        }
        .navigationTitle("Type Items")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func processItems() {
        errorMessage = nil
        isProcessing = true
        Task {
            do {
                let items = try await APIProviderManager.shared
                    .withFallback { provider in
                        try await provider.parseItemInput(itemText)
                    }
                await MainActor.run {
                    detectedItems = items
                    isProcessing = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Failed to parse items: \(error.localizedDescription)"
                    isProcessing = false
                }
            }
        }
    }
}
