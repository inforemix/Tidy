import XCTest
@testable import TidyVibes

final class DetectedItemParsingTests: XCTestCase {

    // MARK: - DetectedItem Decoding

    func testDecodeDetectedItemWithBoundingBox() throws {
        let json = """
        [
          {
            "id": "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
            "name": "scissors",
            "quantity": 1,
            "boundingBox": {
              "x": 0.1,
              "y": 0.2,
              "width": 0.15,
              "height": 0.1
            }
          }
        ]
        """.data(using: .utf8)!

        let items = try JSONDecoder().decode([DetectedItem].self, from: json)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].name, "scissors")
        XCTAssertEqual(items[0].quantity, 1)
        XCTAssertNotNil(items[0].boundingBox)
        XCTAssertEqual(items[0].boundingBox?.x, 0.1)
        XCTAssertEqual(items[0].boundingBox?.width, 0.15)
    }

    func testDecodeDetectedItemWithoutBoundingBox() throws {
        let json = """
        [
          {
            "id": "E621E1F8-C36C-495A-93FC-0C247A3E6E5F",
            "name": "tape",
            "quantity": 3
          }
        ]
        """.data(using: .utf8)!

        let items = try JSONDecoder().decode([DetectedItem].self, from: json)

        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items[0].name, "tape")
        XCTAssertEqual(items[0].quantity, 3)
        XCTAssertNil(items[0].boundingBox)
    }

    func testDecodeMultipleItems() throws {
        let json = """
        [
          {"id": "A0000000-0000-0000-0000-000000000001", "name": "pen", "quantity": 5},
          {"id": "A0000000-0000-0000-0000-000000000002", "name": "eraser", "quantity": 1},
          {"id": "A0000000-0000-0000-0000-000000000003", "name": "ruler", "quantity": 2}
        ]
        """.data(using: .utf8)!

        let items = try JSONDecoder().decode([DetectedItem].self, from: json)

        XCTAssertEqual(items.count, 3)
        XCTAssertEqual(items[0].name, "pen")
        XCTAssertEqual(items[0].quantity, 5)
        XCTAssertEqual(items[2].name, "ruler")
    }

    func testDecodeEmptyArray() throws {
        let json = "[]".data(using: .utf8)!
        let items = try JSONDecoder().decode([DetectedItem].self, from: json)
        XCTAssertTrue(items.isEmpty)
    }

    // MARK: - BoundingBox Computed Properties

    func testBoundingBoxCenterCalculation() {
        let box = DetectedItem.BoundingBox(x: 0.1, y: 0.2, width: 0.4, height: 0.6)

        XCTAssertEqual(box.centerX, 0.3, accuracy: 0.001)
        XCTAssertEqual(box.centerY, 0.5, accuracy: 0.001)
    }

    // MARK: - ItemGroup Decoding

    func testDecodeItemGroup() throws {
        let json = """
        {
          "category": "office_supplies",
          "displayName": "Office Supplies",
          "items": ["pen", "pencil", "eraser"]
        }
        """.data(using: .utf8)!

        let group = try JSONDecoder().decode(ItemGroup.self, from: json)

        XCTAssertEqual(group.category, "office_supplies")
        XCTAssertEqual(group.displayName, "Office Supplies")
        XCTAssertEqual(group.items.count, 3)
        XCTAssertTrue(group.items.contains("pen"))
    }

    // MARK: - GroupingResponse Decoding

    func testDecodeGroupingResponse() throws {
        let json = """
        {
          "groups": [
            {
              "category": "office",
              "displayName": "Office",
              "items": ["pen", "tape"]
            },
            {
              "category": "tools",
              "displayName": "Tools",
              "items": ["hammer"]
            }
          ]
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(GroupingResponse.self, from: json)

        XCTAssertEqual(response.groups.count, 2)
        XCTAssertEqual(response.groups[0].items.count, 2)
        XCTAssertEqual(response.groups[1].displayName, "Tools")
    }

    // MARK: - DetectedItem Equatable

    func testDetectedItemEquality() {
        let id = UUID()
        let a = DetectedItem(id: id, name: "pen", quantity: 1)
        let b = DetectedItem(id: id, name: "pen", quantity: 1)

        XCTAssertEqual(a, b)
    }

    func testDetectedItemInequality() {
        let a = DetectedItem(name: "pen", quantity: 1)
        let b = DetectedItem(name: "tape", quantity: 1)

        XCTAssertNotEqual(a, b)
    }

    // MARK: - DetectedItem Init Defaults

    func testDetectedItemDefaultValues() {
        let item = DetectedItem(name: "marker")

        XCTAssertEqual(item.quantity, 1)
        XCTAssertNil(item.boundingBox)
        XCTAssertFalse(item.id.uuidString.isEmpty)
    }

    // MARK: - Malformed JSON

    func testMalformedJSONThrows() {
        let json = "not valid json".data(using: .utf8)!

        XCTAssertThrowsError(try JSONDecoder().decode([DetectedItem].self, from: json))
    }

    func testMissingRequiredFieldThrows() {
        let json = """
        [{"name": "pen"}]
        """.data(using: .utf8)!

        // Missing "id" and "quantity" — Codable requires them unless defaults exist
        // DetectedItem has let fields so this should throw
        XCTAssertThrowsError(try JSONDecoder().decode([DetectedItem].self, from: json))
    }

    // MARK: - Round-trip Encoding

    func testDetectedItemRoundTrip() throws {
        let original = DetectedItem(
            name: "scissors",
            quantity: 2,
            boundingBox: DetectedItem.BoundingBox(x: 0.1, y: 0.2, width: 0.3, height: 0.4)
        )

        let data = try JSONEncoder().encode(original)
        let decoded = try JSONDecoder().decode(DetectedItem.self, from: data)

        XCTAssertEqual(decoded.name, original.name)
        XCTAssertEqual(decoded.quantity, original.quantity)
        XCTAssertEqual(decoded.boundingBox?.x, original.boundingBox?.x)
    }
}
