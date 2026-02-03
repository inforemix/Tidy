import SwiftUI

struct StorageCardView: View {
    let space: StorageSpace

    var body: some View {
        HStack(spacing: 10) {
            // Icon
            ZStack {
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color(hex: "#6B5FDB").opacity(0.12))
                    .frame(width: 36, height: 36)

                Image(systemName: StorageType(rawValue: space.storageType)?.icon ?? "square.dashed")
                    .font(.system(size: 14))
                    .foregroundColor(Color(hex: "#6B5FDB"))
            }

            // Text
            VStack(alignment: .leading, spacing: 2) {
                Text(space.name)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(Color(hex: "#2D2D2D"))
                    .lineLimit(1)

                Text("\(space.items.count) item\(space.items.count == 1 ? "" : "s")")
                    .font(.system(size: 11))
                    .foregroundColor(Color(hex: "#9E9E9E"))
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(Color(hex: "#BDBDBD"))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(Color.white.opacity(0.3))
        .cornerRadius(10)
    }
}
