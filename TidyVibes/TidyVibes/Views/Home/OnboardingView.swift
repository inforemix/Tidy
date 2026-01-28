import SwiftUI

struct OnboardingView: View {
    @Binding var hasCompletedOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            OnboardingPage(
                emoji: "🧠",
                title: "Your spatial memory, externalized",
                description: "TidyVibes remembers where everything is so you don't have to.",
                page: 0
            )
            .tag(0)

            OnboardingPage(
                emoji: "📸",
                title: "Capture in seconds",
                description: "Lay out your items, snap a photo. AI does the rest.",
                page: 1
            )
            .tag(1)

            OnboardingPage(
                emoji: "✨",
                title: "See the magic",
                description: "Get smart layout suggestions and find anything instantly.",
                page: 2,
                showGetStarted: true,
                onGetStarted: { hasCompletedOnboarding = true }
            )
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct OnboardingPage: View {
    let emoji: String
    let title: String
    let description: String
    let page: Int
    var showGetStarted = false
    var onGetStarted: (() -> Void)?

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Text(emoji)
                .font(.system(size: 80))

            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)

            Text(description)
                .font(.body)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)

            Spacer()

            if showGetStarted {
                Button(action: { onGetStarted?() }) {
                    Text("Get Started")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 40)
                .padding(.bottom, 60)
            }
        }
    }
}
