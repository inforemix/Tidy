import SwiftUI
import SwiftData
import MapKit

struct MindMapView: View {
    @Query(sort: \House.sortOrder) private var houses: [House]
    @State private var selectedHouse: House?
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.5, longitudeDelta: 0.5)
    )
    @State private var mapType: MapDisplayType = .map

    enum MapDisplayType {
        case map
        case threeD
    }

    var body: some View {
        ZStack {
            // Background
            Color(hex: "#F5F3F0")
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                HStack {
                    Button(action: {}) {
                        Image(systemName: "chevron.left")
                            .font(.title3)
                            .foregroundColor(Color(hex: "#2D2D2D"))
                    }

                    Spacer()

                    Text("My Locations")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "#2D2D2D"))

                    Spacer()

                    // Placeholder for symmetry
                    Image(systemName: "chevron.left")
                        .font(.title3)
                        .opacity(0)
                }
                .padding(.horizontal, 20)
                .padding(.top, 60)
                .padding(.bottom, 20)

                // Map View
                if mapType == .map {
                    Map(coordinateRegion: $region, annotationItems: houses) { house in
                        MapAnnotation(coordinate: house.coordinate) {
                            VStack(spacing: 4) {
                                ZStack {
                                    Circle()
                                        .fill(house.colorValue.opacity(0.2))
                                        .frame(width: 60, height: 60)

                                    Circle()
                                        .fill(house.colorValue)
                                        .frame(width: 44, height: 44)

                                    Image(systemName: house.icon ?? "house.fill")
                                        .font(.system(size: 20))
                                        .foregroundColor(.white)
                                }
                                .onTapGesture {
                                    selectedHouse = house
                                }

                                Text(house.name)
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(Color(hex: "#2D2D2D"))
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 4)
                                    .background(Color.white)
                                    .cornerRadius(8)
                                    .shadow(color: .black.opacity(0.1), radius: 4, x: 0, y: 2)
                            }
                        }
                    }
                    .edgesIgnoringSafeArea(.horizontal)
                } else {
                    // 3D View placeholder
                    ZStack {
                        Color(hex: "#E8E6E1")

                        Text("3D View Coming Soon")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "#9E9E9E"))
                    }
                }

                Spacer()

                // Bottom tabs
                HStack(spacing: 40) {
                    Button(action: { mapType = .map }) {
                        VStack(spacing: 4) {
                            Image(systemName: "map")
                                .font(.system(size: 20))
                            Text("Map")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(mapType == .map ? Color(hex: "#6B5FDB") : Color(hex: "#9E9E9E"))
                    }

                    Button(action: { mapType = .threeD }) {
                        VStack(spacing: 4) {
                            Image(systemName: "cube")
                                .font(.system(size: 20))
                            Text("3D")
                                .font(.system(size: 12, weight: .medium))
                        }
                        .foregroundColor(mapType == .threeD ? Color(hex: "#6B5FDB") : Color(hex: "#9E9E9E"))
                    }
                }
                .padding(.vertical, 16)
                .padding(.bottom, 20)
            }

            // Selected house detail sheet
            if let house = selectedHouse {
                VStack {
                    Spacer()

                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(house.name)
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(Color(hex: "#2D2D2D"))

                                if let address = house.address {
                                    Text(address)
                                        .font(.system(size: 14))
                                        .foregroundColor(Color(hex: "#9E9E9E"))
                                }
                            }

                            Spacer()

                            Button(action: { selectedHouse = nil }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(Color(hex: "#9E9E9E"))
                                    .padding(8)
                                    .background(Color(hex: "#F5F3F0"))
                                    .clipShape(Circle())
                            }
                        }

                        HStack(spacing: 20) {
                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(house.roomCount)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(hex: "#2D2D2D"))
                                Text("Rooms")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "#9E9E9E"))
                            }

                            VStack(alignment: .leading, spacing: 2) {
                                Text("\(house.totalItemCount)")
                                    .font(.system(size: 24, weight: .bold))
                                    .foregroundColor(Color(hex: "#2D2D2D"))
                                Text("Items")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(hex: "#9E9E9E"))
                            }
                        }
                    }
                    .padding(24)
                    .background(Color.white)
                    .cornerRadius(24)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: -4)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
                .transition(.move(edge: .bottom))
                .animation(.spring(), value: selectedHouse)
            }
        }
    }
}

// Extension to add coordinate property to House
extension House {
    var coordinate: CLLocationCoordinate2D {
        // In a real app, you'd geocode the address
        // For now, return a sample coordinate based on sortOrder
        CLLocationCoordinate2D(
            latitude: 37.7749 + Double(sortOrder) * 0.01,
            longitude: -122.4194 + Double(sortOrder) * 0.01
        )
    }
}
