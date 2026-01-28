import SwiftUI

enum CaptureMethod {
    case photo
    case voice
}

struct CaptureFlowView: View {
    @Environment(\.dismiss) var dismiss

    @State private var captureMethod: CaptureMethod?
    @State private var capturedImage: UIImage?
    @State private var detectedItems: [DetectedItem] = []
    @State private var isProcessing = false
    @State private var showingCamera = false
    @State private var currentStep: CaptureStep = .method

    enum CaptureStep {
        case method
        case capture
        case review
        case storage
    }

    var body: some View {
        NavigationStack {
            Group {
                switch currentStep {
                case .method:
                    methodSelectionView
                case .capture:
                    captureView
                case .review:
                    NavigationView {
                        ItemReviewView(detectedItems: $detectedItems) {
                            currentStep = .storage
                        }
                    }
                case .storage:
                    NavigationView {
                        StorageSelectionView(detectedItems: detectedItems)
                    }
                }
            }
            .overlay {
                if isProcessing {
                    LoadingOverlay(message: "Processing with AI...")
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }

    private var methodSelectionView: some View {
        VStack(spacing: 32) {
            Spacer()

            VStack(spacing: 16) {
                Text("How do you want to add items?")
                    .font(.title2)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)

                Text("Choose your preferred method")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .padding(.horizontal)

            VStack(spacing: 16) {
                // Photo option
                Button(action: {
                    captureMethod = .photo
                    showingCamera = true
                }) {
                    HStack {
                        Image(systemName: "camera.fill")
                            .font(.title2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Take a Photo")
                                .font(.headline)

                            Text("Lay out items and snap a picture")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor.opacity(0.1))
                    .cornerRadius(12)
                }

                // Voice option
                Button(action: {
                    captureMethod = .voice
                    currentStep = .capture
                }) {
                    HStack {
                        Image(systemName: "mic.fill")
                            .font(.title2)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("Speak Your Items")
                                .font(.headline)

                            Text("Dictate what's in your storage")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
            }
            .padding(.horizontal)

            Spacer()
        }
        .sheet(isPresented: $showingCamera) {
            CameraView(image: $capturedImage)
                .onDisappear {
                    if let image = capturedImage {
                        Task {
                            await processImage(image)
                        }
                    }
                }
        }
    }

    private var captureView: some View {
        Group {
            if captureMethod == .voice {
                VoiceCaptureView(detectedItems: $detectedItems, isProcessing: $isProcessing)
                    .onChange(of: detectedItems) { _, newItems in
                        if !newItems.isEmpty {
                            currentStep = .review
                        }
                    }
            } else {
                EmptyView()
            }
        }
    }

    private func processImage(_ image: UIImage) async {
        isProcessing = true
        do {
            let items = try await GPTService.shared.detectItems(in: image)
            detectedItems = items
            currentStep = .review
        } catch {
            print("Error detecting items: \(error)")
        }
        isProcessing = false
    }
}
