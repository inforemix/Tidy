import SwiftUI

struct SearchView: View {
    let spaces: [StorageSpace]
    let onItemSelected: (Item) -> Void

    @State private var searchText = ""
    @Environment(\.dismiss) var dismiss

    private var allItems: [Item] {
        spaces.flatMap { $0.items }
    }

    private var searchResults: [SearchResult] {
        guard !searchText.isEmpty else { return [] }
        return SearchService.shared.search(query: searchText, in: allItems)
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.secondary)
                    TextField("Search for an item...", text: $searchText)
                        .autocorrectionDisabled()
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding()

                // Results
                if searchText.isEmpty {
                    emptySearchView
                } else if searchResults.isEmpty {
                    noResultsView
                } else {
                    searchResultsList
                }
            }
            .navigationTitle("Find Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private var emptySearchView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("Search for your items")
                .font(.headline)
            Text("Try searching for scissors, keys, or any item")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Spacer()
        }
    }

    private var noResultsView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "questionmark.circle")
                .font(.system(size: 60))
                .foregroundColor(.secondary)
            Text("No items found")
                .font(.headline)
            Text("Try a different search term")
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
        }
    }

    private var searchResultsList: some View {
        ScrollView {
            LazyVStack(spacing: 12) {
                ForEach(searchResults) { result in
                    SearchResultRow(result: result) {
                        onItemSelected(result.item)
                        dismiss()
                    }
                }
            }
            .padding()
        }
    }
}

struct SearchResultRow: View {
    let result: SearchResult
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.item.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if let storageName = result.item.storageSpace?.name {
                        Label(storageName, systemImage: "square.split.2x2")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }

                    if result.item.quantity > 1 {
                        Text("Quantity: \(result.item.quantity)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                // Match score indicator
                Circle()
                    .fill(scoreColor(result.score))
                    .frame(width: 12, height: 12)

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.05), radius: 4, y: 2)
        }
    }

    private func scoreColor(_ score: Double) -> Color {
        if score >= 0.9 {
            return .green
        } else if score >= 0.7 {
            return .yellow
        } else {
            return .orange
        }
    }
}
