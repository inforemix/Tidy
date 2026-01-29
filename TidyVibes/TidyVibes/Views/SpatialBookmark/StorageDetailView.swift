import SwiftUI
import SwiftData

struct StorageDetailView: View {
    let space: StorageSpace

    @State private var showingLayoutSuggestion = false
    @State private var showingSearch = false
    @State private var highlightedItemId: UUID?

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
                HStack(spacing: 12) {
                    Button(action: { showingSearch = true }) {
                        Label("Search", systemImage: "magnifyingglass")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                    }

                    Button(action: { showingLayoutSuggestion = true }) {
                        Label("Suggest Layout", systemImage: "sparkles")
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.accentColor.opacity(0.1))
                            .foregroundColor(.accentColor)
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal)

                // Items list
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
        .navigationTitle(space.name)
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showingSearch) {
            SearchView(spaces: [space], onItemSelected: { item in
                highlightedItemId = item.id
                showingSearch = false
            })
        }
    }
}
