import SwiftUI
import SwiftData

struct HomeView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \StorageSpace.updatedAt, order: .reverse) private var spaces: [StorageSpace]

    @State private var searchText = ""
    @State private var showingCapture = false
    @State private var showingSearch = false

    var body: some View {
        NavigationStack {
            Group {
                if spaces.isEmpty {
                    EmptyStateView(showingCapture: $showingCapture)
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            // Search button
                            Button(action: { showingSearch = true }) {
                                HStack {
                                    Image(systemName: "magnifyingglass")
                                        .foregroundColor(.secondary)
                                    Text("Search for an item...")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                }
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(10)
                            }
                            .padding(.horizontal)

                            // Storage cards
                            ForEach(spaces) { space in
                                NavigationLink(destination: StorageDetailView(space: space)) {
                                    StorageCardView(space: space)
                                }
                            }
                            .padding(.horizontal)
                        }
                        .padding(.vertical)
                    }
                }
            }
            .navigationTitle("TidyVibes")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: { showingCapture = true }) {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                    }
                }
            }
            .sheet(isPresented: $showingCapture) {
                CaptureFlowView()
            }
            .sheet(isPresented: $showingSearch) {
                SearchView(spaces: Array(spaces), onItemSelected: { _ in
                    showingSearch = false
                })
            }
        }
    }
}
