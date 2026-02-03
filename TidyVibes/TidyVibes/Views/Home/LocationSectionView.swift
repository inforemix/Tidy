import SwiftUI

struct LocationSectionView: View {
    @Environment(\.modelContext) private var modelContext
    let location: Location
    @State private var isExpanded = true
    @State private var showingDeleteConfirmation = false

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

                    Menu {
                        Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                            Label("Delete Location", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                            .padding(4)
                    }
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
