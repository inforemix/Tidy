import SwiftUI
import SwiftData

struct HouseSectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var house: House
    @State private var showingAddRoom = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        VStack(spacing: 0) {
            // House header — tap to collapse/expand
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    house.isCollapsed.toggle()
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: house.isCollapsed ? "chevron.right" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 16)

                    if let icon = house.icon {
                        Image(systemName: icon)
                            .font(.title3)
                            .foregroundColor(house.colorValue)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(house.name)
                            .font(.headline)
                            .foregroundColor(.primary)

                        if let address = house.address, !address.isEmpty, house.isCollapsed {
                            Text(address)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                                .lineLimit(1)
                        }
                    }

                    Spacer()

                    if house.isCollapsed {
                        Text(house.summary)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    Menu {
                        Button(action: { showingAddRoom = true }) {
                            Label("Add Room", systemImage: "plus")
                        }
                        Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                            Label("Delete House", systemImage: "trash")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .font(.body)
                            .foregroundColor(.secondary)
                            .padding(6)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
            }
            .buttonStyle(.plain)

            // Expanded content — address and rooms
            if !house.isCollapsed {
                if let address = house.address, !address.isEmpty {
                    HStack {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        Text(address)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Spacer()
                    }
                    .padding(.horizontal, 40)
                    .padding(.vertical, 4)
                }

                let sortedRooms = house.rooms.sorted { $0.sortOrder < $1.sortOrder }
                ForEach(sortedRooms) { room in
                    RoomSectionView(room: room)
                        .padding(.leading, 24)
                }

                if house.rooms.isEmpty {
                    HStack {
                        Image(systemName: "plus.circle.dashed")
                            .foregroundColor(.secondary)
                        Text("Add a room")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.leading, 40)
                    .padding(.vertical, 8)
                    .onTapGesture {
                        showingAddRoom = true
                    }
                }
            }

            Divider()
                .padding(.leading, 16)
        }
        .sheet(isPresented: $showingAddRoom) {
            AddRoomView(house: house)
        }
        .alert("Delete House?", isPresented: $showingDeleteConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteHouse()
            }
        } message: {
            Text("This will delete \(house.name) and all its rooms, locations, storage spaces, and items. This action cannot be undone.")
        }
    }

    private func deleteHouse() {
        modelContext.delete(house)
        try? modelContext.save()
    }
}
