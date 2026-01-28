import SwiftUI

struct StorageCardView: View {
    let space: StorageSpace

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: StorageType(rawValue: space.storageType)?.icon ?? "square.dashed")
                    .font(.title)
                    .foregroundColor(.accentColor)

                VStack(alignment: .leading, spacing: 4) {
                    Text(space.name)
                        .font(.headline)
                        .foregroundColor(.primary)

                    if let ikeaName = space.ikeaProductName {
                        Text(ikeaName)
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundColor(.secondary)
            }

            Divider()

            HStack {
                Label("\(space.items.count) items", systemImage: "square.grid.2x2")
                    .font(.caption)
                    .foregroundColor(.secondary)

                Spacer()

                Text("Updated \(space.updatedAt.formatted(.relative(presentation: .named)))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
        .shadow(color: .black.opacity(0.05), radius: 8, y: 4)
    }
}
