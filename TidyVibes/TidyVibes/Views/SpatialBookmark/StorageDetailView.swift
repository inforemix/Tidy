import SwiftUI
import SwiftData

struct StorageDetailView: View {
    let space: StorageSpace

    enum ViewMode: String, CaseIterable {
        case list = "List"
        case mindMap = "Map"
        case spatial = "Spatial"
    }

    @State private var viewMode: ViewMode = .mindMap
    @State private var showingLayoutSuggestion = false
    @State private var showingLayoutImage = false
    @State private var showingSearch = false
    @State private var highlightedItemId: UUID?
    @State private var layoutSuggestion: LayoutSuggestion?
    @State private var isLoadingSuggestion = false

    var body: some View {
        VStack(spacing: 0) {
            // Storage info header
            storageHeader
                .padding()

            // View mode picker
            Picker("View", selection: $viewMode) {
                ForEach(ViewMode.allCases, id: \.self) { mode in
                    Text(mode.rawValue).tag(mode)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.bottom, 12)

            // Main content
            Group {
                switch viewMode {
                case .list:
                    listContent
                case .mindMap:
                    mindMapContent
                case .spatial:
                    spatialContent
                }
            }
            .frame(maxHeight: .infinity)
        }
        .navigationTitle(space.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Menu {
                    Button(action: { showingSearch = true }) {
                        Label("Search Items", systemImage: "magnifyingglass")
                    }
                    Button(action: { generateSuggestion() }) {
                        Label("Suggest Layout", systemImage: "sparkles")
                    }
                    .disabled(isLoadingSuggestion || space.items.isEmpty)
                    Button(action: { showingLayoutImage = true }) {
                        Label("Visualize Layout", systemImage: "photo.badge.plus")
                    }
                    .disabled(space.items.isEmpty)
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
        .overlay {
            if isLoadingSuggestion {
                LoadingOverlay(message: "Analyzing items...")
            }
        }
    }

    // MARK: - Storage Header

    private var storageHeader: some View {
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
    }

    // MARK: - List Content

    private var listContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                Text("All Items")
                    .font(.headline)
                    .padding(.horizontal)

                if space.items.isEmpty {
                    emptyState
                } else {
                    ForEach(space.items) { item in
                        ItemRowView(item: item)
                            .onTapGesture {
                                highlightedItemId = item.id
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    highlightedItemId = nil
                                }
                            }
                    }
                }
            }
            .padding(.vertical)
        }
    }

    // MARK: - Mind Map Content

    private var mindMapContent: some View {
        Group {
            if space.items.isEmpty {
                emptyState
            } else {
                MindMapView(space: space, highlightedItemId: $highlightedItemId)
                    .padding(.horizontal, 8)
            }
        }
    }

    // MARK: - Spatial Content

    private var spatialContent: some View {
        ScrollView {
            VStack(spacing: 16) {
                SpatialBookmarkView(space: space, highlightedItemId: highlightedItemId)
                    .frame(height: 300)
                    .padding(.horizontal)

                // Action buttons
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

                // Items list below spatial view
                VStack(alignment: .leading, spacing: 12) {
                    Text("All Items")
                        .font(.headline)
                        .padding(.horizontal)

                    ForEach(space.items) { item in
                        ItemRowView(item: item)
                            .onTapGesture {
                                highlightedItemId = item.id
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    highlightedItemId = nil
                                }
                            }
                    }
                }
                .padding(.vertical)
            }
        }
    }

    // MARK: - Empty State

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.largeTitle)
                .foregroundColor(.secondary)
            Text("No items yet")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(.top, 60)
    }

    // MARK: - Actions

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
