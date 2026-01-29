import SwiftUI

struct SpatialBookmarkView: View {
    let space: StorageSpace
    let highlightedItemId: UUID?

    @State private var scale: CGFloat = 1.0
    @State private var offset: CGSize = .zero

    var body: some View {
        GeometryReader { geometry in
            let aspectRatio = space.widthInches / space.depthInches
            let viewWidth = geometry.size.width - 32
            let viewHeight = viewWidth / aspectRatio

            ZStack {
                // Storage boundary
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color(.systemBackground))
                    )
                    .shadow(color: .black.opacity(0.05), radius: 8, y: 4)

                // Items
                ForEach(space.items) { item in
                    ItemNodeView(
                        item: item,
                        containerSize: CGSize(width: viewWidth, height: viewHeight),
                        isHighlighted: item.id == highlightedItemId
                    )
                }
            }
            .frame(width: viewWidth, height: viewHeight)
            .scaleEffect(scale)
            .offset(offset)
            .gesture(
                MagnificationGesture()
                    .onChanged { value in
                        scale = max(1.0, min(3.0, value))
                    }
            )
            .gesture(
                DragGesture()
                    .onChanged { value in
                        if scale > 1.0 {
                            offset = value.translation
                        }
                    }
                    .onEnded { _ in
                        withAnimation {
                            if scale <= 1.0 {
                                offset = .zero
                            }
                        }
                    }
            )
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        }
    }
}
