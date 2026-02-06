import SwiftUI
import SwiftData

struct RoomSectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var room: Room
    @State private var showingAddLocation = false
    @State private var showingDeleteConfirmation = false

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
