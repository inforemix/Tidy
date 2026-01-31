import SwiftUI

struct LocationSectionView: View {
    let location: Location
    @State private var isExpanded = true

    var body: some View {
        VStack(spacing: 0) {
            // Location header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.25)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 8) {
                    Image(systemName: isExpanded ? "chevron.down" : "chevron.right")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                        .frame(width: 14)

                    Image(systemName: "mappin.circle.fill")
                        .font(.caption)
                        .foregroundColor(.orange)

                    Text(location.name)
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Spacer()

                    Text("\(location.totalItemCount) items")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)

            // Storage spaces within this location
            if isExpanded {
                ForEach(location.storageSpaces) { space in
                    NavigationLink(destination: StorageDetailView(space: space)) {
                        StorageCardView(space: space)
                            .padding(.leading, 24)
                            .padding(.trailing)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }

                if location.storageSpaces.isEmpty {
                    Text("No storage spaces yet")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(.leading, 48)
                        .padding(.vertical, 4)
                }
            }
        }
    }
}
