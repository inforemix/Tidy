import SwiftUI
import SwiftData

struct HouseSectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var house: House
    @State private var showingAddRoom = false
    @State private var showingDeleteConfirmation = false

    var body: some View {
        VStack(spacing: 12) {
            // House card header
            Button(action: {
                withAnimation(.spring(response: 0.35, dampingFraction: 0.8)) {
                    house.isCollapsed.toggle()
                }
            }) {
                VStack(spacing: 0) {
                    HStack(spacing: 14) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(house.colorValue.opacity(0.12))
                                .frame(width: 48, height: 48)

                            if let icon = house.icon {
                                Image(systemName: icon)
                                    .font(.system(size: 20))
                                    .foregroundColor(house.colorValue)
                            }
                        }

                        // Text
                        VStack(alignment: .leading, spacing: 3) {
                            Text(house.name)
                                .font(.system(size: 17, weight: .semibold))
                                .foregroundColor(Color(hex: "#2D2D2D"))

                            if let address = house.address, !address.isEmpty {
                                Text(address)
                                    .font(.system(size: 13))
                                    .foregroundColor(Color(hex: "#9E9E9E"))
                                    .lineLimit(1)
                            }
                        }

                        Spacer()

                        // Stats or chevron
                        if house.isCollapsed {
                            VStack(alignment: .trailing, spacing: 2) {
                                Text("\(house.roomCount)")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(Color(hex: "#2D2D2D"))
                                Text("rooms")
                                    .font(.system(size: 11))
                                    .foregroundColor(Color(hex: "#9E9E9E"))
                            }
                        }

                        Image(systemName: "chevron.down")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(hex: "#9E9E9E"))
                            .rotationEffect(.degrees(house.isCollapsed ? -90 : 0))
                    }
                    .padding(16)
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .black.opacity(0.06), radius: 8, x: 0, y: 2)
            }
            .buttonStyle(.plain)
            .contextMenu {
                Button(action: { showingAddRoom = true }) {
                    Label("Add Room", systemImage: "plus")
                }
                Button(role: .destructive, action: { showingDeleteConfirmation = true }) {
                    Label("Delete House", systemImage: "trash")
                }
            }

            // Expanded content — rooms
            if !house.isCollapsed {
                VStack(spacing: 8) {
                    let sortedRooms = house.rooms.sorted { $0.sortOrder < $1.sortOrder }
                    ForEach(sortedRooms) { room in
                        RoomSectionView(room: room)
                    }

                    if house.rooms.isEmpty {
                        Button(action: { showingAddRoom = true }) {
                            HStack(spacing: 10) {
                                Image(systemName: "plus.circle.fill")
                                    .font(.system(size: 18))
                                    .foregroundColor(Color(hex: "#6B5FDB"))
                                Text("Add your first room")
                                    .font(.system(size: 15, weight: .medium))
                                    .foregroundColor(Color(hex: "#6B5FDB"))
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(Color(hex: "#6B5FDB").opacity(0.08))
                            .cornerRadius(12)
                        }
                    }
                }
                .padding(.leading, 16)
            }
        }
        .padding(.horizontal, 24)
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
