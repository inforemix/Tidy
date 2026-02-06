import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct RoomSectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var room: Room
    @State private var showingAddItems = false
    @State private var showingAddLocation = false
    @State private var showingDeleteConfirmation = false
    @State private var draggingLocation: Location?

    /// All items across all locations and storage spaces in this room
    private var allItems: [(item: Item, space: StorageSpace)] {
        room.locations
            .flatMap { location in
                location.storageSpaces.flatMap { space in
                    space.items.map { (item: $0, space: space) }
                }
            }
            .sorted { $0.item.createdAt > $1.item.createdAt }
    }

    var body: some View {
        VStack(spacing: 8) {
            // Room card header
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

                    // Item count when collapsed
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
                Button(action: { showingAddItems = true }) {
                    Label("Add Items", systemImage: "plus.square.on.square")
                }
                Button(action: { showingAddLocation = true }) {
                    Label("Add Location", systemImage: "mappin.and.ellipse")
                }
                Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                    Label("Delete Room", systemImage: "trash")
                }
            }

            // Expanded content — items and storage
            if !room.isCollapsed {
                VStack(spacing: 10) {
                    // Add Items action row
                    Button(action: { showingAddItems = true }) {
                        HStack(spacing: 10) {
                            Image(systemName: "plus.circle.fill")
                                .font(.system(size: 16))
                                .foregroundColor(Color(hex: "#6B5FDB"))

                            Text("Add Items")
                                .font(.system(size: 14, weight: .semibold))
                                .foregroundColor(Color(hex: "#6B5FDB"))

                            Spacer()

                            Image(systemName: "chevron.right")
                                .font(.system(size: 11, weight: .semibold))
                                .foregroundColor(Color(hex: "#6B5FDB").opacity(0.5))
                        }
                        .padding(.horizontal, 14)
                        .padding(.vertical, 12)
                        .background(Color(hex: "#6B5FDB").opacity(0.06))
                        .cornerRadius(10)
                    }
                    .buttonStyle(.plain)

                    if allItems.isEmpty {
                        // Empty state
                        VStack(spacing: 6) {
                            Text("No items yet")
                                .font(.system(size: 13, weight: .medium))
                                .foregroundColor(Color(hex: "#9E9E9E"))
                            Text("Tap \"Add Items\" to get started")
                                .font(.system(size: 12))
                                .foregroundColor(Color(hex: "#BDBDBD"))
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                    } else {
                        // Items grouped by storage space
                        let groupedBySpace = Dictionary(grouping: allItems, by: { $0.space.id })
                        let spaces = room.locations
                            .flatMap { $0.storageSpaces }
                            .sorted { $0.name < $1.name }

                        ForEach(spaces) { space in
                            if let spaceItems = groupedBySpace[space.id], !spaceItems.isEmpty {
                                VStack(spacing: 4) {
                                    // Storage space header
                                    NavigationLink(destination: StorageDetailView(space: space)) {
                                        HStack(spacing: 8) {
                                            Image(systemName: StorageType(rawValue: space.storageType)?.icon ?? "square.dashed")
                                                .font(.system(size: 12))
                                                .foregroundColor(Color(hex: "#6B5FDB"))

                                            Text(space.name)
                                                .font(.system(size: 12, weight: .semibold))
                                                .foregroundColor(Color(hex: "#6B5FDB"))

                                            Spacer()

                                            Text("\(spaceItems.count)")
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundColor(Color(hex: "#9E9E9E"))

                                            Image(systemName: "chevron.right")
                                                .font(.system(size: 9, weight: .semibold))
                                                .foregroundColor(Color(hex: "#BDBDBD"))
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(Color(hex: "#6B5FDB").opacity(0.04))
                                        .cornerRadius(8)
                                    }
                                    .buttonStyle(.plain)

                                    // Item rows
                                    ForEach(spaceItems, id: \.item.id) { entry in
                                        HStack(spacing: 10) {
                                            Circle()
                                                .fill(Color(hex: "#E0E0E0"))
                                                .frame(width: 6, height: 6)

                                            Text(entry.item.name)
                                                .font(.system(size: 13))
                                                .foregroundColor(Color(hex: "#2D2D2D"))
                                                .lineLimit(1)

                                            Spacer()

                                            if entry.item.quantity > 1 {
                                                Text("×\(entry.item.quantity)")
                                                    .font(.system(size: 11, weight: .medium))
                                                    .foregroundColor(Color(hex: "#9E9E9E"))
                                            }

                                            if let category = entry.item.category {
                                                Text(category)
                                                    .font(.system(size: 10))
                                                    .foregroundColor(Color(hex: "#BDBDBD"))
                                                    .lineLimit(1)
                                            }
                                        }
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                    }
                                }
                            }
                        }
                    }
                }
                .padding(.leading, 12)
            }
        }
        .sheet(isPresented: $showingAddItems) {
            CaptureFlowView()
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
