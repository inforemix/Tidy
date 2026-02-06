import XCTest
import SwiftData
import CoreGraphics
@testable import TidyVibes

final class LayoutEngineTests: XCTestCase {
    private var engine: LayoutEngine!
    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!

    override func setUp() {
        super.setUp()
        engine = LayoutEngine.shared

        let schema = Schema([StorageSpace.self, Item.self, Location.self, Room.self, House.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() {
        engine = nil
        modelContainer = nil
        modelContext = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func makeItem(_ name: String) -> Item {
        let item = Item(name: name)
        modelContext.insert(item)
        try! modelContext.save()
        return item
    }

    private func makeStorage(width: Double = 12.0, depth: Double = 16.0, height: Double = 4.0) -> StorageSpace {
        let space = StorageSpace(name: "Test Drawer", storageType: "drawer", width: width, depth: depth, height: height)
        modelContext.insert(space)
        try! modelContext.save()
        return space
    }

    // MARK: - Basic Layout Generation

    func testGenerateLayoutReturnsPositionsForAllItems() {
        let items = [makeItem("pen"), makeItem("tape"), makeItem("scissors")]
        let groups = [ItemGroup(category: "office", displayName: "Office", items: ["pen", "tape", "scissors"])]
        let storage = makeStorage()

        let result = engine.generateLayout(items: items, groups: groups, storage: storage, style: .smart)

        XCTAssertEqual(result.positions.count, 3)
        for item in items {
            XCTAssertNotNil(result.positions[item.id], "Missing position for \(item.name)")
        }
    }

    func testAllPositionsWithinBounds() {
        let items = (1...8).map { makeItem("item\($0)") }
        let groups = [ItemGroup(category: "misc", displayName: "Misc", items: items.map { $0.name })]
        let storage = makeStorage()

        let result = engine.generateLayout(items: items, groups: groups, storage: storage, style: .smart)

        for (_, pos) in result.positions {
            XCTAssertGreaterThanOrEqual(pos.x, 0.0, "X position out of bounds (below 0)")
            XCTAssertLessThanOrEqual(pos.x, 1.0, "X position out of bounds (above 1)")
            XCTAssertGreaterThanOrEqual(pos.y, 0.0, "Y position out of bounds (below 0)")
            XCTAssertLessThanOrEqual(pos.y, 1.0, "Y position out of bounds (above 1)")
        }
    }

    // MARK: - Empty Items

    func testEmptyItemsReturnsEmptyPositions() {
        let groups = [ItemGroup(category: "office", displayName: "Office", items: ["pen"])]
        let storage = makeStorage()

        let result = engine.generateLayout(items: [], groups: groups, storage: storage, style: .smart)

        XCTAssertTrue(result.positions.isEmpty)
    }

    // MARK: - Ungrouped Items

    func testUngroupedItemsGetPositions() {
        let items = [makeItem("pen"), makeItem("random_widget")]
        let groups = [ItemGroup(category: "office", displayName: "Office", items: ["pen"])]
        let storage = makeStorage()

        let result = engine.generateLayout(items: items, groups: groups, storage: storage, style: .smart)

        XCTAssertEqual(result.positions.count, 2, "Ungrouped items should still get positions")
    }

    // MARK: - Organization Styles

    func testCategoryStyleGroupsStartOnNewRow() {
        let items = [makeItem("pen"), makeItem("tape"), makeItem("hammer"), makeItem("wrench")]
        let groups = [
            ItemGroup(category: "office", displayName: "Office", items: ["pen", "tape"]),
            ItemGroup(category: "tools", displayName: "Tools", items: ["hammer", "wrench"]),
        ]
        let storage = makeStorage()

        let result = engine.generateLayout(items: items, groups: groups, storage: storage, style: .category)

        // Office items should have same Y, tools items should have same Y, but different rows
        let officeItems = items.prefix(2)
        let toolItems = items.suffix(2)
        let officeYs = officeItems.compactMap { result.positions[$0.id]?.y }
        let toolYs = toolItems.compactMap { result.positions[$0.id]?.y }

        XCTAssertEqual(officeYs.count, 2)
        XCTAssertEqual(toolYs.count, 2)
        // Categories should start on different rows
        if let officeY = officeYs.first, let toolY = toolYs.first {
            XCTAssertNotEqual(officeY, toolY, "Different categories should be on different rows")
        }
    }

    func testSmartStyleProducesReasoning() {
        let items = [makeItem("pen")]
        let groups = [ItemGroup(category: "office", displayName: "Office", items: ["pen"])]
        let storage = makeStorage()

        let result = engine.generateLayout(items: items, groups: groups, storage: storage, style: .smart)

        XCTAssertFalse(result.reasoning.isEmpty)
        XCTAssertTrue(result.reasoning.contains("Office"))
    }

    func testFrequencyStyleProducesReasoning() {
        let items = [makeItem("pen")]
        let groups = [ItemGroup(category: "office", displayName: "Office", items: ["pen"])]
        let storage = makeStorage()

        let result = engine.generateLayout(items: items, groups: groups, storage: storage, style: .frequency)

        XCTAssertTrue(result.reasoning.contains("front") || result.reasoning.contains("reach"))
    }

    func testWorkflowStylePreservesOriginalOrder() {
        let items = [makeItem("pen"), makeItem("tape"), makeItem("scissors")]
        let groups = [
            ItemGroup(category: "step1", displayName: "Step 1", items: ["pen"]),
            ItemGroup(category: "step2", displayName: "Step 2", items: ["tape"]),
            ItemGroup(category: "step3", displayName: "Step 3", items: ["scissors"]),
        ]
        let storage = makeStorage()

        let result = engine.generateLayout(items: items, groups: groups, storage: storage, style: .workflow)

        XCTAssertEqual(result.style, .workflow)
        XCTAssertTrue(result.reasoning.contains("used together"))
    }

    // MARK: - Style Preserved

    func testLayoutPreservesRequestedStyle() {
        let items = [makeItem("pen")]
        let groups = [ItemGroup(category: "office", displayName: "Office", items: ["pen"])]
        let storage = makeStorage()

        for style in OrganizationStyle.allCases {
            let result = engine.generateLayout(items: items, groups: groups, storage: storage, style: style)
            XCTAssertEqual(result.style, style)
        }
    }
}
