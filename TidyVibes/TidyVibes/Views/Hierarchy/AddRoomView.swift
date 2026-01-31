import SwiftUI
import SwiftData

struct AddRoomView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    /// Pass an existing room to enable edit mode; leave nil for create mode.
    var existingRoom: Room?

    @State private var roomName = ""
    @State private var selectedPreset: RoomPreset?
    @State private var customIcon = "square.dashed"
    @State private var customColor = "#78909C"

    private var isEditing: Bool { existingRoom != nil }

    var body: some View {
        NavigationView {
            Form {
                Section("Room Name") {
                    TextField("e.g. Bedroom, Kitchen, Garage", text: $roomName)
                }

                Section("Choose a preset") {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 80))
                    ], spacing: 12) {
                        ForEach(RoomPreset.presets, id: \.name) { preset in
                            presetButton(preset)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    Button(action: saveRoom) {
                        Text(isEditing ? "Save Changes" : "Create Room")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(roomName.isEmpty)
                }
            }
            .navigationTitle(isEditing ? "Edit Room" : "Add Room")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                if let room = existingRoom {
                    roomName = room.name
                    customIcon = room.icon ?? "square.dashed"
                    customColor = room.color ?? "#78909C"
                    // Select matching preset if any
                    selectedPreset = RoomPreset.presets.first { $0.icon == room.icon && $0.color == room.color }
                }
            }
        }
    }

    private func presetButton(_ preset: RoomPreset) -> some View {
        let isSelected = selectedPreset?.name == preset.name
        return Button(action: {
            selectedPreset = preset
            if roomName.isEmpty || isEditing {
                roomName = preset.name
            }
            customIcon = preset.icon
            customColor = preset.color
        }) {
            VStack(spacing: 6) {
                Image(systemName: preset.icon)
                    .font(.title2)
                    .foregroundColor(Color(hex: preset.color))

                Text(preset.name)
                    .font(.caption2)
                    .foregroundColor(.primary)
                    .lineLimit(1)
            }
            .frame(width: 70, height: 70)
            .background(isSelected ? Color(hex: preset.color).opacity(0.15) : Color(.systemGray6))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color(hex: preset.color) : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }

    private func saveRoom() {
        if let room = existingRoom {
            room.name = roomName
            room.icon = customIcon
            room.color = customColor
        } else {
            let room = Room(name: roomName, icon: customIcon, color: customColor)
            modelContext.insert(room)
        }
        try? modelContext.save()
        dismiss()
    }
}
