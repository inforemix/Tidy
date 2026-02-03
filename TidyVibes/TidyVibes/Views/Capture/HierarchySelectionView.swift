import SwiftUI
import SwiftData

struct HierarchySelectionView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    let detectedItems: [DetectedItem]
    let onComplete: () -> Void

    @Query(sort: \House.sortOrder) private var houses: [House]
    @Query(sort: \Room.sortOrder) private var rooms: [Room]
    @Query private var allLocations: [Location]

    @State private var selectedHouse: House?
    @State private var selectedRoom: Room?
    @State private var selectedLocation: Location?
    @State private var showingAddHouse = false
    @State private var showingAddRoom = false
    @State private var showingAddLocation = false
    @State private var showingStorageSelection = false

    var filteredRooms: [Room] {
        if let house = selectedHouse {
            return house.rooms.sorted { $0.sortOrder < $1.sortOrder }
        } else {
            return rooms.filter { $0.house == nil }
        }
    }

    var filteredLocations: [Location] {
        if let room = selectedRoom {
            return room.locations.sorted { $0.sortOrder < $1.sortOrder }
        } else {
            return []
        }
    }

    var canContinue: Bool {
        selectedRoom != nil
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    Text("Choose where to store these items")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }

                if !houses.isEmpty {
                    Section("House/Address") {
                        Picker("Select House", selection: $selectedHouse) {
                            Text("Select house...").tag(nil as House?)
                            ForEach(houses) { house in
                                HStack {
                                    if let icon = house.icon {
                                        Image(systemName: icon)
                                    }
                                    VStack(alignment: .leading) {
                                        Text(house.name)
                                        if let address = house.address {
                                            Text(address)
                                                .font(.caption)
                                                .foregroundColor(.secondary)
                                        }
                                    }
                                }
                                .tag(house as House?)
                            }
                        }
                        .onChange(of: selectedHouse) { _, _ in
                            selectedRoom = nil
                            selectedLocation = nil
                        }

                        Button(action: { showingAddHouse = true }) {
                            Label("Add New House", systemImage: "plus.circle")
                        }
                    }
                }

                if selectedHouse != nil || !rooms.filter({ $0.house == nil }).isEmpty {
                    Section("Room") {
                        Picker("Select Room", selection: $selectedRoom) {
                            Text("Select room...").tag(nil as Room?)
                            ForEach(filteredRooms) { room in
                                HStack {
                                    if let icon = room.icon {
                                        Image(systemName: icon)
                                    }
                                    Text(room.name)
                                }
                                .tag(room as Room?)
                            }
                        }
                        .onChange(of: selectedRoom) { _, _ in
                            selectedLocation = nil
                        }

                        Button(action: { showingAddRoom = true }) {
                            Label("Add New Room", systemImage: "plus.circle")
                        }
                        .disabled(selectedHouse == nil && !houses.isEmpty)
                    }
                }

                if let room = selectedRoom, !room.locations.isEmpty {
                    Section("Location (Optional)") {
                        Picker("Select Location", selection: $selectedLocation) {
                            Text("No specific location").tag(nil as Location?)
                            ForEach(filteredLocations) { location in
                                Text(location.name)
                                    .tag(location as Location?)
                            }
                        }

                        Button(action: { showingAddLocation = true }) {
                            Label("Add New Location", systemImage: "plus.circle")
                        }
                    }
                }

                if canContinue {
                    Section("Summary") {
                        VStack(alignment: .leading, spacing: 8) {
                            if let house = selectedHouse {
                                HStack {
                                    Image(systemName: "house.fill")
                                        .foregroundColor(.secondary)
                                    Text(house.name)
                                }
                            }
                            if let room = selectedRoom {
                                HStack {
                                    Image(systemName: room.icon ?? "door.left.hand.open")
                                        .foregroundColor(.secondary)
                                    Text(room.name)
                                }
                            }
                            if let location = selectedLocation {
                                HStack {
                                    Image(systemName: "mappin.circle.fill")
                                        .foregroundColor(.secondary)
                                    Text(location.name)
                                }
                            }
                        }
                        .font(.subheadline)
                    }

                    Section {
                        Button(action: { showingStorageSelection = true }) {
                            Text("Continue to Storage Selection")
                                .font(.headline)
                                .frame(maxWidth: .infinity)
                        }
                    }
                }
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .sheet(isPresented: $showingAddHouse) {
                AddHouseView()
            }
            .sheet(isPresented: $showingAddRoom) {
                AddRoomView(house: selectedHouse)
            }
            .sheet(isPresented: $showingAddLocation) {
                if let room = selectedRoom {
                    AddLocationView(room: room)
                }
            }
            .sheet(isPresented: $showingStorageSelection) {
                NavigationStack {
                    StorageSelectionWithHierarchyView(
                        detectedItems: detectedItems,
                        selectedLocation: selectedLocation,
                        selectedRoom: selectedRoom,
                        onComplete: onComplete
                    )
                }
            }
        }
    }
}

struct StorageSelectionWithHierarchyView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss

    let detectedItems: [DetectedItem]
    let selectedLocation: Location?
    let selectedRoom: Room?
    let onComplete: () -> Void

    @State private var searchText = ""
    @State private var selectedProduct: IKEAProduct?
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
        storage.location = selectedLocation

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
        storage.location = selectedLocation

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
        onComplete()
    }
}
