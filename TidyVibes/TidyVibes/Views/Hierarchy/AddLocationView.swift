import SwiftUI
import SwiftData

struct AddLocationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    let room: Room

    /// Pass an existing location to enable edit mode; leave nil for create mode.
    var existingLocation: Location?

    @State private var locationName = ""

    private var isEditing: Bool { existingLocation != nil }

    private let suggestions = [
        "Closet", "Nightstand", "Under Bed", "Desk",
        "Bookshelf", "Dresser Top", "Wall Shelf", "Cabinet",
        "Pantry Shelf", "Counter", "Drawer Unit", "Wardrobe"
    ]

    var body: some View {
        NavigationView {
            Form {
                Section("Location Name") {
                    TextField("e.g. Closet, Under desk, Wall shelf", text: $locationName)
                }

                Section("Suggestions") {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 100))
                    ], spacing: 8) {
                        ForEach(suggestions, id: \.self) { suggestion in
                            Button(action: {
                                locationName = suggestion
                            }) {
                                Text(suggestion)
                                    .font(.caption)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(locationName == suggestion ? Color.orange.opacity(0.2) : Color(.systemGray6))
                                    .foregroundColor(locationName == suggestion ? .orange : .primary)
                                    .cornerRadius(8)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 8)
                                            .stroke(locationName == suggestion ? Color.orange : Color.clear, lineWidth: 1)
                                    )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(.vertical, 4)
                }

                Section {
                    Button(action: saveLocation) {
                        Text(isEditing ? "Save Changes" : "Add to \(room.name)")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(locationName.isEmpty)
                }
            }
            .navigationTitle(isEditing ? "Edit Location" : "Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .onAppear {
                if let location = existingLocation {
                    locationName = location.name
                }
            }
        }
    }

    private func saveLocation() {
        if let location = existingLocation {
            location.name = locationName
        } else {
            let location = Location(name: locationName)
            location.room = room
            location.sortOrder = room.locations.count
            modelContext.insert(location)
        }
        try? modelContext.save()
        dismiss()
    }
}
