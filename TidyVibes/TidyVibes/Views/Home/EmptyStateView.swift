import SwiftUI

struct EmptyStateView: View {
    @Binding var showingCapture: Bool

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            Text("🪴")
                .font(.system(size: 64))

            Text("Your spaces are waiting")
                .font(.title2)
                .fontWeight(.semibold)

            Text("Start with your messiest drawer.\nThe one that defeats you every time.")
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)

            Button(action: { showingCapture = true }) {
                Label("Add your first drawer", systemImage: "plus")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .padding(.horizontal, 40)

            Text("Takes about 2 minutes")
                .font(.caption)
                .foregroundColor(.secondary)

            Spacer()
        }
        .padding()
    }
}
