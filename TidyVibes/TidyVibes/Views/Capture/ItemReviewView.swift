import SwiftUI

struct ItemReviewView: View {
    @Binding var detectedItems: [DetectedItem]
    @State private var editingItem: DetectedItem?
    @State private var showingAddItem = false
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: 0) {
            // Header
            VStack(alignment: .leading, spacing: 8) {
                Text("Review your items")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Tap to edit, swipe to delete")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding()

            // Items list
            List {
                ForEach(detectedItems) { item in
                    HStack {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(item.name)
                                .font(.body)

                            if item.quantity > 1 {
                                Text("Quantity: \(item.quantity)")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                            }
                        }

                        Spacer()

                        Image(systemName: "pencil")
                            .foregroundColor(.accentColor)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture {
                        editingItem = item
                    }
                }
                .onDelete(perform: deleteItems)

                Button(action: { showingAddItem = true }) {
                    Label("Add item", systemImage: "plus.circle.fill")
                        .font(.body)
                }
            }

            // Continue button
            Button(action: onContinue) {
                Text("Continue")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(detectedItems.isEmpty ? Color(.systemGray4) : Color.accentColor)
                    .foregroundColor(.white)
                    .cornerRadius(12)
            }
            .disabled(detectedItems.isEmpty)
            .padding()
        }
        .navigationTitle("Items")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(item: $editingItem) { item in
            EditItemSheet(item: item) { updatedItem in
                if let index = detectedItems.firstIndex(where: { $0.id == item.id }) {
                    detectedItems[index] = updatedItem
                }
            }
        }
        .sheet(isPresented: $showingAddItem) {
            AddItemSheet { newItem in
                detectedItems.append(newItem)
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        detectedItems.remove(atOffsets: offsets)
    }
}

struct EditItemSheet: View {
    let item: DetectedItem
    let onSave: (DetectedItem) -> Void

    @State private var name: String
    @State private var quantity: Int
    @Environment(\.dismiss) var dismiss

    init(item: DetectedItem, onSave: @escaping (DetectedItem) -> Void) {
        self.item = item
        self.onSave = onSave
        _name = State(initialValue: item.name)
        _quantity = State(initialValue: item.quantity)
    }

    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Name", text: $name)
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                }
            }
            .navigationTitle("Edit Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        let updated = DetectedItem(id: item.id, name: name, quantity: quantity, boundingBox: item.boundingBox)
                        onSave(updated)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}

struct AddItemSheet: View {
    let onAdd: (DetectedItem) -> Void

    @State private var name: String = ""
    @State private var quantity: Int = 1
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            Form {
                Section("Item Details") {
                    TextField("Name", text: $name)
                    Stepper("Quantity: \(quantity)", value: $quantity, in: 1...99)
                }
            }
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        let newItem = DetectedItem(name: name, quantity: quantity)
                        onAdd(newItem)
                        dismiss()
                    }
                    .disabled(name.isEmpty)
                }
            }
        }
    }
}
