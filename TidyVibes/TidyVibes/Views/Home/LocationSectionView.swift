import SwiftUI
import SwiftData

struct LocationSectionView: View {
    @Environment(\.modelContext) private var modelContext
    let location: Location
    @State private var isExpanded = true
    @State private var showingEditLocation = false
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
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button(action: { showingEditLocation = true }) {
                    Label("Edit Location", systemImage: "pencil")
                }
                Divider()
                Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                    Label("Delete Location", systemImage: "trash")
                }
            }

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
        .sheet(isPresented: $showingEditLocation) {
            if let room = location.room {
                AddLocationView(room: room, existingLocation: location)
            }
        }
        .alert("Delete Location?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                withAnimation {
                    modelContext.delete(location)
                    try? modelContext.save()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete \"\(location.name)\" and all its storage spaces and items. This cannot be undone.")
        }
    }
}
