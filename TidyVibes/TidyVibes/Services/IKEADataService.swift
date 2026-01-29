import Foundation

class IKEADataService {
    static let shared = IKEADataService()

    private var products: [IKEAProduct] = []

    private init() {
        loadProducts()
    }

    private func loadProducts() {
        guard let url = Bundle.main.url(forResource: "ikea_products", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let decoded = try? JSONDecoder().decode([IKEAProduct].self, from: data) else {
            print("Failed to load IKEA products")
            return
        }
        products = decoded
    }

    func searchProducts(query: String) -> [IKEAProduct] {
        guard !query.isEmpty else { return products }
        let lowercased = query.lowercased()
        return products.filter {
            $0.name.lowercased().contains(lowercased) ||
            $0.id.lowercased().contains(lowercased)
        }
    }

    func getProduct(id: String) -> IKEAProduct? {
        products.first { $0.id == id }
    }

    var allProducts: [IKEAProduct] { products }

    var popularProducts: [IKEAProduct] {
        // Return most common products first
        let popularIds = ["alex_drawer_unit", "kallax_insert_2drawer", "malm_6drawer",
                         "skubb_box_set", "kuggis_box_lid", "hemnes_8drawer"]
        return popularIds.compactMap { getProduct(id: $0) }
    }
}
