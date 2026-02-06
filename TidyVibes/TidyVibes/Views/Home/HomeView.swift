import SwiftUI
import SwiftData
import UniformTypeIdentifiers

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \House.sortOrder) private var houses: [House]
    @Query(sort: \Room.sortOrder) private var rooms: [Room]
    @Query private var allSpaces: [StorageSpace]

    @State private var showingCapture = false
    @State private var showingSearch = false
    @State private var showingAddHouse = false
    @State private var showingAddRoom = false
    @State private var draggingHouse: House?

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
            ZStack {
                // Background
                Color(hex: "#F5F3F0")
                    .ignoresSafeArea()

                Group {
                    if houses.isEmpty && rooms.isEmpty && allSpaces.isEmpty {
                        EmptyStateView(showingCapture: $showingCapture)
                    } else {
                        ScrollView {
                            LazyVStack(spacing: 16) {
                                // Header with greeting
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("TIDY")
                                            .font(.system(size: 28, weight: .light, design: .rounded))
                                            .foregroundColor(Color(hex: "#2D2D2D"))
                                            .tracking(4)
                                        Text("VIBE")
                                            .font(.system(size: 28, weight: .light, design: .rounded))
                                            .foregroundColor(Color(hex: "#2D2D2D"))
                                            .tracking(4)
                                    }

                                    Spacer()

                                    // Add button
                                    Menu {
                                        Button(action: { showingAddHouse = true }) {
                                            Label("Add House", systemImage: "house.fill")
                                        }
                                        Button(action: { showingAddRoom = true }) {
                                            Label("Add Room", systemImage: "door.left.hand.open")
                                        }
                                        Button(action: { showingCapture = true }) {
                                            Label("Add Items", systemImage: "plus.square.on.square")
                                        }
                                    } label: {
                                        Image(systemName: "plus")
                                            .font(.system(size: 20, weight: .medium))
                                            .foregroundColor(Color(hex: "#6B5FDB"))
                                            .frame(width: 44, height: 44)
                                            .background(Color.white)
                                            .clipShape(Circle())
                                            .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                                    }
                                }
                                .padding(.horizontal, 24)
                                .padding(.top, 16)

                                // Search bar
                                Button(action: { showingSearch = true }) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "magnifyingglass")
                                            .font(.system(size: 16))
                                            .foregroundColor(Color(hex: "#9E9E9E"))
                                        Text("Search for an item...")
                                            .font(.system(size: 15))
                                            .foregroundColor(Color(hex: "#9E9E9E"))
                                        Spacer()
                                    }
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 14)
                                    .background(Color.white)
                                    .cornerRadius(16)
                                    .shadow(color: .black.opacity(0.05), radius: 8, x: 0, y: 2)
                                }
                                .padding(.horizontal, 24)

                                // House sections (top level) — long-press to reorder
                                ForEach(houses) { house in
                                    HouseSectionView(house: house)
                                        .onDrag {
                                            draggingHouse = house
                                            return NSItemProvider(object: house.id.uuidString as NSString)
                                        }
                                        .onDrop(of: [.text], delegate: HouseDropDelegate(
                                            item: house,
                                            draggingItem: $draggingHouse,
                                            houses: houses,
                                            modelContext: modelContext
                                        ))
                                }

                                // Unassigned rooms (rooms without a house)
                                if !unassignedRooms.isEmpty {
                                    UnassignedRoomsSectionView(rooms: unassignedRooms)
                                }

                                // Unsorted section for unassigned storage
                                if !unsortedSpaces.isEmpty {
                                    UnsortedSectionView(spaces: unsortedSpaces)
                                }

                                Spacer(minLength: 24)
                            }
                            .padding(.vertical, 8)
                        }
                    }
                }

            }
            .navigationBarHidden(true)
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
        VStack(spacing: 12) {
            // Header
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isCollapsed.toggle()
                }
            }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.orange.opacity(0.12))
                            .frame(width: 48, height: 48)

                        Image(systemName: "questionmark.folder.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.orange)
                    }

                    Text("Unassigned Rooms")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "#2D2D2D"))

                    Spacer()

                    if isCollapsed {
                        Text("\(rooms.count)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#2D2D2D"))
                    }

                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .rotationEffect(.degrees(isCollapsed ? -90 : 0))
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            }
            .buttonStyle(.plain)

            // Rooms
            if !isCollapsed {
                VStack(spacing: 8) {
                    ForEach(rooms) { room in
                        RoomSectionView(room: room)
                    }
                }
                .padding(.leading, 16)
            }
        }
        .padding(.horizontal, 24)
    }
}

// MARK: - House Drop Delegate

struct HouseDropDelegate: DropDelegate {
    let item: House
    @Binding var draggingItem: House?
    let houses: [House]
    let modelContext: ModelContext

    func performDrop(info: DropInfo) -> Bool {
        draggingItem = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let dragging = draggingItem, dragging.id != item.id else { return }
        let sorted = houses.sorted { $0.sortOrder < $1.sortOrder }
        guard let fromIndex = sorted.firstIndex(where: { $0.id == dragging.id }),
              let toIndex = sorted.firstIndex(where: { $0.id == item.id }) else { return }
        if fromIndex != toIndex {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                var reordered = sorted
                let moved = reordered.remove(at: fromIndex)
                reordered.insert(moved, at: toIndex)
                for (i, house) in reordered.enumerated() {
                    house.sortOrder = i
                }
                try? modelContext.save()
            }
        }
    }

    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
}

// MARK: - Unsorted Section

struct UnsortedSectionView: View {
    let spaces: [StorageSpace]
    @State private var isCollapsed = false

    var body: some View {
        VStack(spacing: 12) {
            // Header
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    isCollapsed.toggle()
                }
            }) {
                HStack(spacing: 14) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.12))
                            .frame(width: 48, height: 48)

                        Image(systemName: "tray.fill")
                            .font(.system(size: 20))
                            .foregroundColor(.gray)
                    }

                    Text("Unsorted")
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(Color(hex: "#2D2D2D"))

                    Spacer()

                    if isCollapsed {
                        Text("\(spaces.count)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color(hex: "#2D2D2D"))
                    }

                    Image(systemName: "chevron.down")
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(Color(hex: "#9E9E9E"))
                        .rotationEffect(.degrees(isCollapsed ? -90 : 0))
                }
                .padding(16)
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            }
            .buttonStyle(.plain)

            // Storage spaces
            if !isCollapsed {
                VStack(spacing: 6) {
                    ForEach(spaces) { space in
                        NavigationLink(destination: StorageDetailView(space: space)) {
                            StorageCardView(space: space)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
        .padding(.horizontal, 24)
    }
}
