import SwiftUI
import SwiftData

struct AddLocationView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    let room: Room

    @State private var locationName = ""

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
                        Text("Add to \(room.name)")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(locationName.isEmpty)
                }
            }
            .navigationTitle("Add Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func saveLocation() {
        let location = Location(name: locationName)
        location.room = room
        location.sortOrder = room.locations.count
        modelContext.insert(location)
        try? modelContext.save()
        dismiss()
    }
}
