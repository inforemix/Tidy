import SwiftUI
import SwiftData

struct AddHouseView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    @State private var houseName = ""
    @State private var address = ""
    @State private var selectedPreset: HousePreset?
    @State private var customIcon = "house.fill"
    @State private var customColor = "#4A90E2"

    var body: some View {
        NavigationView {
            Form {
                Section("House Name") {
                    TextField("e.g. Main Home, Beach House", text: $houseName)
                }

                Section("Address (Optional)") {
                    TextField("e.g. 123 Main St, Anytown, USA", text: $address)
                }

                Section("Choose a preset") {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 80))
                    ], spacing: 12) {
                        ForEach(HousePreset.presets, id: \.name) { preset in
                            presetButton(preset)
                        }
                    }
                    .padding(.vertical, 8)
                }

                Section {
                    Button(action: saveHouse) {
                        Text("Create House")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(houseName.isEmpty)
                }
            }
            .navigationTitle("Add House/Address")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func presetButton(_ preset: HousePreset) -> some View {
        let isSelected = selectedPreset?.name == preset.name
        return Button(action: {
            selectedPreset = preset
            if houseName.isEmpty {
                houseName = preset.name
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

    private func saveHouse() {
        let house = House(name: houseName, address: address.isEmpty ? nil : address, icon: customIcon, color: customColor)
        modelContext.insert(house)
        try? modelContext.save()
        dismiss()
    }
}
