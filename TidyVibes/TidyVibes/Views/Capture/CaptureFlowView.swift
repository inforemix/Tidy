import SwiftUI

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

    // MARK: - Method Selection (3 paths)

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
                captureMethodButton(method: .photo) {
                    captureMethod = .photo
                    showingCamera = true
                }

                // Voice option
                captureMethodButton(method: .voice) {
                    captureMethod = .voice
                    currentStep = .capture
                }

                // Manual text option
                captureMethodButton(method: .manual) {
                    captureMethod = .manual
                    currentStep = .capture
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

    private func captureMethodButton(method: CaptureMethod, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack {
                Image(systemName: method.icon)
                    .font(.title2)
                    .foregroundColor(method.accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(method.title)
                        .font(.headline)

                    Text(method.subtitle)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(method.accentColor.opacity(0.1))
            .cornerRadius(12)
        }
    }

    // MARK: - Capture Views

    private var captureView: some View {
        Group {
            switch captureMethod {
            case .voice:
                VoiceCaptureView(detectedItems: $detectedItems, isProcessing: $isProcessing)
                    .onChange(of: detectedItems) { _, newItems in
                        if !newItems.isEmpty {
                            currentStep = .review
                        }
                    }
            case .manual:
                ManualEntryView(detectedItems: $detectedItems, isProcessing: $isProcessing)
                    .onChange(of: detectedItems) { _, newItems in
                        if !newItems.isEmpty {
                            currentStep = .review
                        }
                    }
            default:
                EmptyView()
            }
        }
    }

    // MARK: - Processing

    private func processImage(_ image: UIImage) async {
        isProcessing = true
        do {
            let items = try await APIProviderManager.shared
                .withFallback { provider in
                    try await provider.detectItems(in: image)
                }
            detectedItems = items
            currentStep = .review
        } catch {
            print("Error detecting items: \(error)")
        }
        isProcessing = false
    }
}
