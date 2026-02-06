import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct RoomSectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var room: Room
    @State private var showingAddLocation = false
    @State private var showingDeleteConfirmation = false
    @State private var draggingLocation: Location?

    var body: some View {
        VStack(spacing: 8) {
            // Room card
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    room.isCollapsed.toggle()
                }
            }) {
                HStack(spacing: 12) {
                    // Icon
                    ZStack {
                        Circle()
                            .fill(room.colorValue.opacity(0.12))
                            .frame(width: 40, height: 40)

                        if let icon = room.icon {
                            Image(systemName: icon)
                                .font(.system(size: 16))
                                .foregroundColor(room.colorValue)
                        }
                    }

                    // Text
                    Text(room.name)
                        .font(.system(size: 15, weight: .medium))
                        .foregroundColor(Color(hex: "#2D2D2D"))

                    Spacer()

                    // Item count
                    if room.isCollapsed {
                        Text("\(room.totalItemCount) items")
                            .font(.system(size: 12))
                            .foregroundColor(Color(hex: "#9E9E9E"))
                    }

                    Image(systemName: "chevron.down")
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .rotationEffect(.degrees(room.isCollapsed ? -90 : 0))
                }
                .padding(.horizontal, 14)
                .padding(.vertical, 12)
                .background(Color.white.opacity(0.6))
                .cornerRadius(12)
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button(action: { showingAddLocation = true }) {
                    Label("Add Location", systemImage: "plus")
                }
                Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                    Label("Delete Room", systemImage: "trash")
                }
            }

            // Expanded content — locations
            if !room.isCollapsed {
                VStack(spacing: 6) {
                    let sortedLocations = room.locations.sorted { $0.sortOrder < $1.sortOrder }
                    ForEach(sortedLocations) { location in
                        LocationSectionView(location: location)
                            .onDrag {
                                draggingLocation = location
                                return NSItemProvider(object: location.id.uuidString as NSString)
                            }
                            .onDrop(of: [.text], delegate: LocationDropDelegate(
                                item: location,
                                draggingItem: $draggingLocation,
                                locations: sortedLocations,
                                modelContext: modelContext
                            ))
                    }

                    if room.locations.isEmpty {
                        Button(action: { showingAddLocation = true }) {
                            HStack(spacing: 8) {
                                Image(systemName: "plus.circle")
                                    .font(.system(size: 14))
                                    .foregroundColor(Color(hex: "#6B5FDB"))
                                Text("Add a location")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(Color(hex: "#6B5FDB"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(Color(hex: "#6B5FDB").opacity(0.06))
                            .cornerRadius(10)
                        }
                    }
                }
                .padding(.leading, 12)
            }
        }
        .sheet(isPresented: $showingAddLocation) {
            AddLocationView(room: room)
        }
        .alert("Delete Room?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteRoom()
            }
        } message: {
            Text("This will delete \(room.name) and all its locations, storage spaces, and items. This action cannot be undone.")
        }
    }

    private func deleteRoom() {
        modelContext.delete(room)
        try? modelContext.save()
    }
}

// MARK: - Location Drop Delegate

struct LocationDropDelegate: DropDelegate {
    let item: Location
    @Binding var draggingItem: Location?
    let locations: [Location]
    let modelContext: ModelContext

    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let dragging = draggingItem, dragging.id != item.id else { return }
        guard let fromIndex = locations.firstIndex(where: { $0.id == dragging.id }),
              let toIndex = locations.firstIndex(where: { $0.id == item.id }) else { return }
        if fromIndex != toIndex {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                var reordered = locations
                let moved = reordered.remove(at: fromIndex)
                reordered.insert(moved, at: toIndex)
                for (i, location) in reordered.enumerated() {
                    location.sortOrder = i
                }
                try? modelContext.save()
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}
