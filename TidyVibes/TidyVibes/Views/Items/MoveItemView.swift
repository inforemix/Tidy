import SwiftUI
import SwiftData

struct MoveItemView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    let item: Item

    @Query(sort: \House.sortOrder) private var houses: [House]
    @Query(sort: \Room.sortOrder) private var rooms: [Room]
    @Query private var allLocations: [Location]
    @Query private var allSpaces: [StorageSpace]

    @State private var selectedHouse: House?
    @State private var selectedRoom: Room?
    @State private var selectedLocation: Location?
    @State private var selectedStorage: StorageSpace?

    var filteredRooms: [Room] {
        if let house = selectedHouse {
            return house.rooms.sorted { $0.sortOrder < $1.sortOrder }
        } else {
            return rooms.filter { $0.house == nil }
        }
    }

    var filteredLocations: [Location] {
        if let room = selectedRoom {
            return room.locations.sorted { $0.sortOrder < $1.sortOrder }
        } else {
            return []
        }
    }

    var filteredStorages: [StorageSpace] {
        if let location = selectedLocation {
            return location.storageSpaces
        } else if selectedRoom != nil {
            return allSpaces.filter { $0.location == nil }
        } else {
            return []
        }
    }

    var canMove: Bool {
        selectedStorage != nil && selectedStorage?.id != item.storageSpace?.id
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Current Location") {
                    if let storage = item.storageSpace {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(storage.hierarchyPath)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text("Current storage location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    } else {
                        Text("Not assigned to any storage")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                }

                Section("Select New Location") {
                    if !houses.isEmpty {
                        Picker("House", selection: $selectedHouse) {
                            Text("Select house...").tag(nil as House?)
                            ForEach(houses) { house in
                                HStack {
                                    if let icon = house.icon {
                                        Image(systemName: icon)
                                    }
                                    Text(house.name)
                                }
                                .tag(house as House?)
                            }
                        }
                        .onChange(of: selectedHouse) { _, _ in
                            selectedRoom = nil
                            selectedLocation = nil
                            selectedStorage = nil
                        }
                    }

                    if selectedHouse != nil || !rooms.filter({ $0.house == nil }).isEmpty {
                        Picker("Room", selection: $selectedRoom) {
                            Text("Select room...").tag(nil as Room?)
                            ForEach(filteredRooms) { room in
                                HStack {
                                    if let icon = room.icon {
                                        Image(systemName: icon)
                                    }
                                    Text(room.name)
                                }
                                .tag(room as Room?)
                            }
                        }
                        .onChange(of: selectedRoom) { _, _ in
                            selectedLocation = nil
                            selectedStorage = nil
                        }
                    }

                    if let room = selectedRoom, !room.locations.isEmpty {
                        Picker("Location", selection: $selectedLocation) {
                            Text("Select location...").tag(nil as Location?)
                            ForEach(filteredLocations) { location in
                                Text(location.name)
                                    .tag(location as Location?)
                            }
                        }
                        .onChange(of: selectedLocation) { _, _ in
                            selectedStorage = nil
                        }
                    }

                    if !filteredStorages.isEmpty {
                        Picker("Storage", selection: $selectedStorage) {
                            Text("Select storage...").tag(nil as StorageSpace?)
                            ForEach(filteredStorages) { storage in
                                Text(storage.name)
                                    .tag(storage as StorageSpace?)
                            }
                        }
                    }
                }

                if let storage = selectedStorage {
                    Section("New Location") {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(storage.hierarchyPath)
                                .font(.subheadline)
                                .foregroundColor(.primary)
                            Text("\(storage.items.count) items currently stored")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                }

                Section {
                    Button(action: moveItem) {
                        Text("Move Item")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(!canMove)
                }
            }
            .navigationTitle("Move \(item.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func moveItem() {
        if let newStorage = selectedStorage {
            item.storageSpace = newStorage
            item.lastMoved = Date()
            item.updatedAt = Date()
            try? modelContext.save()
            dismiss()
        }
    }
}
