import Foundation

struct IKEAProduct: Codable, Identifiable {
    let id: String
    let name: String
    let productId: String
    let type: String
    let drawers: [IKEADrawer]?
    let dimensions: IKEADimensions?

    struct IKEADrawer: Codable {
        let position: Int?
        let widthInches: Double
        let depthInches: Double
        let heightInches: Double
    }

    struct IKEADimensions: Codable {
        let widthInches: Double
        let depthInches: Double
        let heightInches: Double
    }
}
