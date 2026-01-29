import SwiftUI

struct VoiceCaptureView: View {
    @StateObject private var speechService = SpeechService()
    @Binding var detectedItems: [DetectedItem]
    @Binding var isProcessing: Bool
    @Environment(\.dismiss) var dismiss

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            if speechService.isRecording {
                // Recording indicator
                VStack(spacing: 16) {
                    Circle()
                        .fill(Color.red)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Circle()
                                .stroke(Color.red.opacity(0.3), lineWidth: 8)
                                .scaleEffect(speechService.isRecording ? 1.3 : 1.0)
                                .animation(.easeInOut(duration: 1.0).repeatForever(), value: speechService.isRecording)
                        )

                    Text("Listening...")
                        .font(.title2)
                        .fontWeight(.semibold)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "mic.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.accentColor)

                    Text("Speak your items")
                        .font(.title2)
                        .fontWeight(.semibold)

                    Text("Example: 'scissors, five pens, tape, passport'")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
            }

            if !speechService.transcript.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Text("You said:")
                        .font(.caption)
                        .foregroundColor(.secondary)

                    ScrollView {
                        Text(speechService.transcript)
                            .font(.body)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }
                    .frame(height: 100)
                }
                .padding(.horizontal)
            }

            Spacer()

            // Actions
            VStack(spacing: 16) {
                if speechService.isRecording {
                    Button(action: {
                        speechService.stopRecording()
                    }) {
                        Label("Stop Recording", systemImage: "stop.circle.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.red)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                } else if !speechService.transcript.isEmpty {
                    Button(action: {
                        Task {
                            await processTranscript()
                        }
                    }) {
                        Label("Process Items", systemImage: "sparkles")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }

                    Button(action: {
                        speechService.transcript = ""
                        try? speechService.startRecording()
                    }) {
                        Text("Try Again")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .cornerRadius(12)
                    }
                } else {
                    Button(action: {
                        try? speechService.startRecording()
                    }) {
                        Label("Start Recording", systemImage: "mic.fill")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                }
            }
            .padding()
        }
        .navigationTitle("Voice Capture")
        .navigationBarTitleDisplayMode(.inline)
        .task {
            _ = await speechService.requestAuthorization()
        }
    }

    private func processTranscript() async {
        isProcessing = true
        do {
            let items = try await GPTService.shared.parseVoiceInput(speechService.transcript)
            detectedItems = items
            dismiss()
        } catch {
            print("Error processing transcript: \(error)")
        }
        isProcessing = false
    }
}
