import SwiftUI

struct LocationSectionView: View {
    @Environment(\.modelContext) private var modelContext
    let location: Location
    @State private var isExpanded = true
    @State private var showingDeleteConfirmation = false

    var body: some View {
        VStack(spacing: 6) {
            // Location card
            Button(action: {
                withAnimation(.spring(response: 0.25, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            }) {
                HStack(spacing: 10) {
                    // Icon
                    Image(systemName: "mappin.circle.fill")
                        .font(.system(size: 14))
                        .foregroundColor(Color(hex: "#FF9500"))

                    // Text
                    Text(location.name)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "#2D2D2D"))

                    Spacer()

                    // Item count
                    Text("\(location.totalItemCount)")
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(Color(hex: "#9E9E9E"))

                    Image(systemName: "chevron.down")
                        .font(.system(size: 10, weight: .semibold))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .rotationEffect(.degrees(isExpanded ? 0 : -90))
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 10)
                .background(Color.white.opacity(0.4))
                .cornerRadius(10)
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                    Label("Delete Location", systemImage: "trash")
                }
            }

            // Storage spaces within this location
            if isExpanded {
                VStack(spacing: 4) {
                    ForEach(location.storageSpaces) { space in
                        NavigationLink(destination: StorageDetailView(space: space)) {
                            StorageCardView(space: space)
                        }
                        .buttonStyle(.plain)
                    }

                    if location.storageSpaces.isEmpty {
                        Text("No storage yet")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#9E9E9E"))
                            .padding(.vertical, 8)
                    }
                }
                .padding(.leading, 8)
            }
        }
        .alert("Delete Location?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteLocation()
            }
        } message: {
            Text("This will delete \(location.name) and all its storage spaces and items. This action cannot be undone.")
        }
    }

    private func deleteLocation() {
        modelContext.delete(location)
        try? modelContext.save()
    }
}
