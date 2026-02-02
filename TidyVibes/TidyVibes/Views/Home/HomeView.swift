import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \House.sortOrder) private var houses: [House]
    @Query(sort: \Room.sortOrder) private var rooms: [Room]
    @Query private var allSpaces: [StorageSpace]

    @State private var showingCapture = false
    @State private var showingSearch = false
    @State private var showingAddHouse = false
    @State private var showingAddRoom = false

    /// Storage spaces not assigned to any location
    var unsortedSpaces: [StorageSpace] {
        allSpaces.filter { $0.location == nil }
    }

    /// Rooms not assigned to any house
    var unassignedRooms: [Room] {
        rooms.filter { $0.house == nil }
    }

    var body: some View {
        NavigationStack {
            Group {
                if houses.isEmpty && rooms.isEmpty && allSpaces.isEmpty {
                    EmptyStateView(showingCapture: $showingCapture)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // Search bar
                            Button(action: { showingSearch = true }) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.secondary)
                                    Text("Search for an item...")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)
                            .padding(.bottom, 12)

                            // House sections (top level)
                            ForEach(houses) { house in
                                HouseSectionView(house: house)
                            }

                            // Unassigned rooms (rooms without a house)
                            if !unassignedRooms.isEmpty {
                                UnassignedRoomsSectionView(rooms: unassignedRooms)
                            }

                            // Unsorted section for unassigned storage
                            if !unsortedSpaces.isEmpty {
                                UnsortedSectionView(spaces: unsortedSpaces)
                            }
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("TidyVibes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        Button(action: { showingAddHouse = true }) {
                            Label("Add House/Address", systemImage: "house.fill")
                        }
                        Button(action: { showingAddRoom = true }) {
                            Label("Add Room", systemImage: "door.left.hand.open")
                        }
                        Button(action: { showingCapture = true }) {
                            Label("Add Storage", systemImage: "plus.circle.fill")
                        }
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingCapture) {
                CaptureFlowView()
            }
            .sheet(isPresented: $showingSearch) {
                SearchView(spaces: Array(allSpaces), onItemSelected: { _ in
                    showingSearch = false
                })
            }
            .sheet(isPresented: $showingAddHouse) {
                AddHouseView()
            }
            .sheet(isPresented: $showingAddRoom) {
                AddRoomView()
            }
        }
    }
}

// MARK: - Unassigned Rooms Section

struct UnassignedRoomsSectionView: View {
    let rooms: [Room]
    @State private var isCollapsed = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isCollapsed.toggle()
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 16)

                    Image(systemName: "questionmark.folder.fill")
                        .font(.body)
                        .foregroundColor(.orange)

                    Text("Unassigned Rooms")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    if isCollapsed {
                        Text("\(rooms.count) room\(rooms.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
            }
            .buttonStyle(.plain)

            // Rooms
            if !isCollapsed {
                ForEach(rooms) { room in
                    RoomSectionView(room: room)
                        .padding(.leading, 24)
                }
            }

            Divider()
                .padding(.leading, 16)
        }
    }
}

// MARK: - Unsorted Section

struct UnsortedSectionView: View {
    let spaces: [StorageSpace]
    @State private var isCollapsed = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
            Button(action: {
                withAnimation(.easeInOut(duration: 0.3)) {
                    isCollapsed.toggle()
                }
            }) {
                HStack(spacing: 10) {
                    Image(systemName: isCollapsed ? "chevron.right" : "chevron.down")
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .frame(width: 16)

                    Image(systemName: "tray.fill")
                        .font(.body)
                        .foregroundColor(.gray)

                    Text("Unsorted")
                        .font(.headline)
                        .foregroundColor(.primary)

                    Spacer()

                    if isCollapsed {
                        Text("\(spaces.count) storage\(spaces.count == 1 ? "" : "s")")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 12)
                .background(Color(.systemBackground))
            }
            .buttonStyle(.plain)

            // Storage spaces
            if !isCollapsed {
                ForEach(spaces) { space in
                    NavigationLink(destination: StorageDetailView(space: space)) {
                        StorageCardView(space: space)
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.plain)
                }
            }

            Divider()
                .padding(.leading, 16)
        }
    }
}
