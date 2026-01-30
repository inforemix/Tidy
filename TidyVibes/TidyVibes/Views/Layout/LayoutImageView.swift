import SwiftUI

struct LayoutImageView: View {
    let space: StorageSpace
    @Environment(\.dismiss) var dismiss

    @State private var generatedImage: UIImage?
    @State private var arrangementPlan: ArrangementPlan?
    @State private var isGenerating = false
    @State private var errorMessage: String?
    @State private var selectedStyle: OrganizationStyle = .smart

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // Style picker
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Organization Style")
                            .font(.subheadline)
                            .fontWeight(.medium)

                        Picker("Style", selection: $selectedStyle) {
                            ForEach(OrganizationStyle.allCases, id: \.self) { style in
                                Text(style.displayName).tag(style)
                            }
                        }
                        .pickerStyle(.segmented)
                    }
                    .padding(.horizontal)

                    // Generated image or placeholder
                    if isGenerating {
                        VStack(spacing: 16) {
                            ProgressView()
                                .scaleEffect(1.5)
                            Text("Planning arrangement...")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    } else if let image = generatedImage {
                        VStack(spacing: 12) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .cornerRadius(12)
                                .shadow(color: .black.opacity(0.1), radius: 8, y: 4)

                            if let plan = arrangementPlan {
                                Text(plan.plan)
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }
                        }
                        .padding(.horizontal)
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "photo.badge.plus")
                                .font(.system(size: 48))
                                .foregroundColor(.secondary)

                            Text("Generate a visual preview of\nyour organized storage")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .frame(height: 300)
                        .frame(maxWidth: .infinity)
                        .background(Color(.systemGray6))
                        .cornerRadius(16)
                        .padding(.horizontal)
                    }

                    if let error = errorMessage {
                        Text(error)
                            .font(.caption)
                            .foregroundColor(.red)
                            .padding(.horizontal)
                    }

                    // Action buttons
                    VStack(spacing: 12) {
                        Button(action: generate) {
                            Label(
                                generatedImage == nil ? "Generate Preview" : "Regenerate",
                                systemImage: "sparkles"
                            )
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                        }
                        .disabled(isGenerating || space.items.isEmpty)

                        if generatedImage != nil {
                            Button(action: applyLayout) {
                                Label("Apply This Layout", systemImage: "checkmark.circle.fill")
                                    .font(.headline)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.green)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                            }
                        }
                    }
                    .padding(.horizontal)

                    if space.items.isEmpty {
                        Text("Add items to this storage space first")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("Visualize Layout")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Done") { dismiss() }
                }
            }
        }
    }

    private func generate() {
        isGenerating = true
        errorMessage = nil

        Task {
            do {
                let result = try await LayoutImagePipeline.shared.generateLayoutImage(
                    items: space.items,
                    storage: space,
                    style: selectedStyle
                )
                await MainActor.run {
                    generatedImage = result.image
                    arrangementPlan = result.plan
                    // Save generated image to storage space
                    space.generatedImage = result.image.jpegData(compressionQuality: 0.8)
                    isGenerating = false
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Generation failed: \(error.localizedDescription)"
                    isGenerating = false
                }
            }
        }
    }

    private func applyLayout() {
        guard let plan = arrangementPlan else { return }

        for placement in plan.placements {
            guard placement.bbox.count == 4 else { continue }
            if let item = space.items.first(where: {
                $0.name.lowercased() == placement.item.lowercased()
            }) {
                item.positionX = placement.bbox[0] + placement.bbox[2] / 2
                item.positionY = placement.bbox[1] + placement.bbox[3] / 2
            }
        }

        space.updatedAt = Date()
        dismiss()
    }
}
