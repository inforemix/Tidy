import SwiftUI
import SwiftData

struct StorageDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) var dismiss
    let space: StorageSpace

    @State private var showingLayoutSuggestion = false
    @State private var showingLayoutImage = false
    @State private var showingSearch = false
    @State private var highlightedItemId: UUID?
    @State private var layoutSuggestion: LayoutSuggestion?
    @State private var isLoadingSuggestion = false
    @State private var showingDeleteStorageConfirmation = false
    @State private var itemToMove: Item?

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Storage info
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Image(systemName: StorageType(rawValue: space.storageType)?.icon ?? "square.dashed")
                            .font(.title2)
                            .foregroundColor(.accentColor)

                        VStack(alignment: .leading) {
                            Text(space.name)
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("\(space.items.count) items")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }

                        Spacer()
                    }

                    Text("W: \(String(format: "%.1f", space.widthInches))\" × D: \(String(format: "%.1f", space.depthInches))\" × H: \(String(format: "%.1f", space.heightInches))\"")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .padding()

                // Spatial visualization
                SpatialBookmarkView(space: space, highlightedItemId: highlightedItemId)
                    .frame(height: 300)
                    .padding()

                // Actions
                VStack(spacing: 12) {
                    HStack(spacing: 12) {
                        Button(action: { showingSearch = true }) {
                            Label("Search", systemImage: "magnifyingglass")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(12)
                        }

                        Button(action: { generateSuggestion() }) {
                            Label("Suggest Layout", systemImage: "sparkles")
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.accentColor.opacity(0.1))
                                .foregroundColor(.accentColor)
                                .cornerRadius(12)
                        }
                        .disabled(isLoadingSuggestion || space.items.isEmpty)
                    }

                    Button(action: { showingLayoutImage = true }) {
                        Label("Visualize Layout", systemImage: "photo.badge.plus")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange.opacity(0.15))
                            .foregroundColor(.orange)
                            .cornerRadius(12)
                    }
                    .disabled(space.items.isEmpty)
                }
                .padding(.horizontal)

                // Items list
                VStack(alignment: .leading, spacing: 12) {
                    Text("All Items")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(space.items) { item in
                        ItemRowView(item: item, onMove: { item in
                            itemToMove = item
                        })
                        .onTapGesture {
                            highlightedItemId = item.id
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                highlightedItemId = nil
                            }
                        }
                    }
                    .onDelete(perform: deleteItems)
                }
                .padding(.vertical)
            }
        }
        .navigationTitle(space.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(role: .destructive, action: { showingDeleteStorageConfirmation = true }) {
                        Label("Delete Storage", systemImage: "trash")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
            }
        }
        .sheet(isPresented: $showingSearch) {
            SearchView(spaces: [space], onItemSelected: { item in
                highlightedItemId = item.id
                showingSearch = false
            })
        }
        .sheet(isPresented: $showingLayoutSuggestion) {
            if let suggestion = layoutSuggestion {
                LayoutSuggestionView(
                    space: space,
                    suggestion: suggestion,
                    onApply: {
                        applyLayoutSuggestion(suggestion)
                        showingLayoutSuggestion = false
                    },
                    onDismiss: {
                        showingLayoutSuggestion = false
                    }
                )
            }
        }
        .sheet(isPresented: $showingLayoutImage) {
            LayoutImageView(space: space)
        }
        .sheet(item: $itemToMove) { item in
            MoveItemView(item: item)
        }
        .alert("Delete Storage?", isPresented: $showingDeleteStorageConfirmation) {
            Button("Cancel", role: .cancel) {}
            Button("Delete", role: .destructive) {
                deleteStorage()
            }
        } message: {
            Text("This will delete \(space.name) and all its items. This action cannot be undone.")
        }
        .overlay {
            if isLoadingSuggestion {
                LoadingOverlay(message: "Analyzing items...")
            }
        }
    }

    private func deleteItems(at offsets: IndexSet) {
        for index in offsets {
            let item = space.items[index]
            modelContext.delete(item)
        }
        try? modelContext.save()
    }

    private func deleteStorage() {
        modelContext.delete(space)
        try? modelContext.save()
        dismiss()
    }

    private func generateSuggestion() {
        isLoadingSuggestion = true
        Task {
            do {
                let itemNames = space.items.map { $0.name }
                let groups = try await APIProviderManager.shared
                    .withFallback { provider in
                        try await provider.groupItems(itemNames)
                    }
                let suggestion = LayoutEngine.shared.generateLayout(
                    items: space.items,
                    groups: groups,
                    storage: space,
                    style: .smart
                )
                await MainActor.run {
                    layoutSuggestion = suggestion
                    isLoadingSuggestion = false
                    showingLayoutSuggestion = true
                }
            } catch {
                print("Error generating layout suggestion: \(error)")
                await MainActor.run {
                    isLoadingSuggestion = false
                }
            }
        }
    }

    private func applyLayoutSuggestion(_ suggestion: LayoutSuggestion) {
        for item in space.items {
            if let position = suggestion.positions[item.id] {
                item.positionX = position.x
                item.positionY = position.y
            }
        }
        space.updatedAt = Date()
    }
}
