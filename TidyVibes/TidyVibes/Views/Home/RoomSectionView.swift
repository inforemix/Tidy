import SwiftUI
import SwiftData

struct RoomSectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var room: Room
    @State private var showingAddLocation = false
    @State private var showingEditRoom = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            // Room header — tap to collapse/expand
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    room.isCollapsed.toggle()
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: room.isCollapsed ? "chevron.right" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 16)

                    if let icon = room.icon {
                        Image(systemName: icon)
                            .font(.body)
                            .foregroundColor(room.colorValue)
                    }

                    Text(room.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    if room.isCollapsed {
                        Text(room.summary)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Button(action: { showingAddLocation = true }) {
                        Image(systemName: "plus")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .padding(6)
                            .background(Color(.systemGray5))
                            .clipShape(Circle())
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button(action: { showingAddLocation = true }) {
                    Label("Add Location", systemImage: "plus")
                }
                Button(action: { showingEditRoom = true }) {
                    Label("Edit Room", systemImage: "pencil")
                }
                Divider()
                Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                    Label("Delete Room", systemImage: "trash")
                }
            }

            // Expanded content — locations
            if !room.isCollapsed {
                let sortedLocations = room.locations.sorted { $0.sortOrder < $1.sortOrder }
                ForEach(sortedLocations) { location in
                    LocationSectionView(location: location)
                        .padding(.leading, 24)
                }

                if room.locations.isEmpty {
                    HStack {
                        Image(systemName: "plus.circle.dashed")
                            .foregroundColor(.secondary)
                        Text("Add a location")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 40)
                    .padding(.vertical, 8)
                    .onTapGesture {
                        showingAddLocation = true
                    }
                }
            }

            Divider()
                .padding(.leading, 16)
        }
        .sheet(isPresented: $showingAddLocation) {
            AddLocationView(room: room)
        }
        .sheet(isPresented: $showingEditRoom) {
            AddRoomView(existingRoom: room)
        }
        .alert("Delete Room?", isPresented: $showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                withAnimation {
                    modelContext.delete(room)
                    try? modelContext.save()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will delete \"\(room.name)\" and all its locations, storage spaces, and items. This cannot be undone.")
        }
    }
}
