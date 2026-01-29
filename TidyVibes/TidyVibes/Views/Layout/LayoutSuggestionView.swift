import SwiftUI

struct LayoutSuggestionView: View {
    let space: StorageSpace
    let suggestion: LayoutSuggestion
    let onApply: () -> Void
    let onDismiss: () -> Void

    @State private var selectedStyle: OrganizationStyle = .smart
    @State private var showingStylePicker = false

    var body: some View {
        VStack(spacing: 20) {
            // Header
            HStack {
                VStack(alignment: .leading) {
                    Text("Here's a smarter way to organize this")
                        .font(.headline)
                    Text(suggestion.reasoning)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Button(action: onDismiss) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.secondary)
                }
            }
            .padding()

            // Before/After comparison
            HStack(spacing: 16) {
                VStack {
                    Text("Current")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    SpatialBookmarkView(space: space, highlightedItemId: nil)
                        .frame(height: 200)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                }

                Image(systemName: "arrow.right")
                    .foregroundColor(.accentColor)

                VStack {
                    Text("Suggested")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    SuggestedLayoutPreview(
                        space: space,
                        suggestion: suggestion
                    )
                    .frame(height: 200)
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentColor, lineWidth: 2)
                    )
                }
            }
            .padding(.horizontal)

            // Style picker
            Button(action: { showingStylePicker = true }) {
                HStack {
                    Text("Style:")
                    Text(selectedStyle.displayName)
                        .fontWeight(.semibold)
                    Image(systemName: "chevron.down")
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.1))
                .cornerRadius(8)
            }

            Spacer()

            // Actions
            HStack(spacing: 16) {
                Button(action: { showingStylePicker = true }) {
                    Text("Different style")
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.1))
                        .cornerRadius(12)
                }

                Button(action: onApply) {
                    Text("Apply layout")
                        .fontWeight(.semibold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            }
            .padding()
        }
        .sheet(isPresented: $showingStylePicker) {
            StylePickerView(selectedStyle: $selectedStyle)
        }
    }
}

struct SuggestedLayoutPreview: View {
    let space: StorageSpace
    let suggestion: LayoutSuggestion

    var body: some View {
        GeometryReader { geometry in
            let aspectRatio = space.widthInches / space.depthInches
            let viewWidth = geometry.size.width - 16
            let viewHeight = viewWidth / aspectRatio

            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))

                ForEach(space.items) { item in
                    if let position = suggestion.positions[item.id] {
                        SuggestedItemNode(
                            item: item,
                            position: position,
                            containerSize: CGSize(width: viewWidth, height: viewHeight)
                        )
                    }
                }
            }
            .frame(width: viewWidth, height: viewHeight)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}

struct SuggestedItemNode: View {
    let item: Item
    let position: CGPoint
    let containerSize: CGSize

    var body: some View {
        let screenPosition = CGPoint(
            x: position.x * containerSize.width,
            y: position.y * containerSize.height
        )

        RoundedRectangle(cornerRadius: 6)
            .fill(Color.accentColor.opacity(0.2))
            .overlay(
                Text(item.name)
                    .font(.system(size: 8))
                    .lineLimit(1)
            )
            .frame(width: 40, height: 30)
            .position(screenPosition)
    }
}
