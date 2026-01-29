import SwiftUI
import SwiftData

struct StorageSelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    let detectedItems: [DetectedItem]

    @State private var searchText = ""
    @State private var selectedProduct: IKEAProduct?
    @State private var selectedDrawer: Int?
    @State private var showingCustomDimensions = false
    @State private var storageName = ""
    @State private var customWidth: Double = 12
    @State private var customDepth: Double = 18
    @State private var customHeight: Double = 4
    @State private var storageType: StorageType = .drawer

    private var searchResults: [IKEAProduct] {
        if searchText.isEmpty {
            return IKEADataService.shared.popularProducts
        } else {
            return IKEADataService.shared.searchProducts(query: searchText)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            if showingCustomDimensions {
                customDimensionsForm
            } else {
                ikeaSelectionView
            }
        }
        .navigationTitle("Select Storage")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var ikeaSelectionView: some View {
        VStack(spacing: 0) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                TextField("Search IKEA products...", text: $searchText)
            }
            .padding()
            .background(Color(.systemGray6))
            .cornerRadius(10)
            .padding()

            // IKEA products list
            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach(searchResults) { product in
                        ProductCard(product: product, isSelected: selectedProduct?.id == product.id) {
                            selectedProduct = product
                            if let drawers = product.drawers, !drawers.isEmpty {
                                selectedDrawer = drawers[0].position ?? 1
                            }
                        }
                    }
                }
                .padding()
            }

            Divider()

            // Custom option
            Button(action: { showingCustomDimensions = true }) {
                HStack {
                    Text("Not IKEA? Enter custom dimensions")
                        .font(.subheadline)
                    Spacer()
                    Image(systemName: "chevron.right")
                }
                .padding()
            }

            // Continue button
            if selectedProduct != nil {
                Button(action: saveStorage) {
                    Text("Continue")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.accentColor)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding()
            }
        }
    }

    private var customDimensionsForm: some View {
        Form {
            Section("Storage Name") {
                TextField("e.g. Kitchen junk drawer", text: $storageName)
            }

            Section("Type") {
                Picker("Storage Type", selection: $storageType) {
                    ForEach(StorageType.allCases, id: \.self) { type in
                        Label(type.rawValue.capitalized, systemImage: type.icon)
                            .tag(type)
                    }
                }
            }

            Section("Dimensions (optional but helps)") {
                HStack {
                    Text("Width")
                    Spacer()
                    TextField("12", value: $customWidth, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                    Text("inches")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Depth")
                    Spacer()
                    TextField("18", value: $customDepth, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                    Text("inches")
                        .foregroundColor(.secondary)
                }

                HStack {
                    Text("Height")
                    Spacer()
                    TextField("4", value: $customHeight, format: .number)
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.trailing)
                        .frame(width: 60)
                    Text("inches")
                        .foregroundColor(.secondary)
                }
            }

            Section {
                Button(action: saveCustomStorage) {
                    Text("Create Storage")
                        .frame(maxWidth: .infinity)
                        .font(.headline)
                }
                .disabled(storageName.isEmpty)
            }
        }
        .navigationTitle("Custom Dimensions")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: { showingCustomDimensions = false }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
    }

    private func saveStorage() {
        guard let product = selectedProduct else { return }

        let width: Double
        let depth: Double
        let height: Double

        if let drawers = product.drawers, let drawer = drawers.first {
            width = drawer.widthInches
            depth = drawer.depthInches
            height = drawer.heightInches
        } else if let dims = product.dimensions {
            width = dims.widthInches
            depth = dims.depthInches
            height = dims.heightInches
        } else {
            return
        }

        let storage = StorageSpace(
            name: product.name,
            storageType: "drawer",
            width: width,
            depth: depth,
            height: height
        )
        storage.ikeaProductId = product.id
        storage.ikeaProductName = product.name

        addItemsToStorage(storage)
    }

    private func saveCustomStorage() {
        let storage = StorageSpace(
            name: storageName,
            storageType: storageType.rawValue,
            width: customWidth,
            depth: customDepth,
            height: customHeight
        )

        addItemsToStorage(storage)
    }

    private func addItemsToStorage(_ storage: StorageSpace) {
        modelContext.insert(storage)

        for detectedItem in detectedItems {
            let item = Item(name: detectedItem.name, quantity: detectedItem.quantity)
            if let bbox = detectedItem.boundingBox {
                item.positionX = bbox.centerX
                item.positionY = bbox.centerY
            }
            item.storageSpace = storage
            modelContext.insert(item)
        }

        try? modelContext.save()
        dismiss()
    }
}

struct ProductCard: View {
    let product: IKEAProduct
    let isSelected: Bool
    let onSelect: () -> Void

    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(product.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(product.productId)
                        .font(.caption)
                        .foregroundColor(.secondary)

                    if let drawers = product.drawers {
                        Text("\(drawers.count) drawer(s)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.accentColor)
                        .font(.title2)
                }
            }
            .padding()
            .background(isSelected ? Color.accentColor.opacity(0.1) : Color(.systemBackground))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(isSelected ? Color.accentColor : Color(.systemGray4), lineWidth: isSelected ? 2 : 1)
            )
        }
    }
}
