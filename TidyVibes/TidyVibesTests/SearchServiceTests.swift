import XCTest
import SwiftData
@testable import TidyVibes

final class SearchServiceTests: XCTestCase {
    private var service: SearchService!
    private var modelContainer: ModelContainer!
    private var modelContext: ModelContext!

    override func setUp() {
        super.setUp()
        service = SearchService.shared

        let schema = Schema([StorageSpace.self, Item.self, Location.self, Room.self, House.self])
        let config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        modelContainer = try! ModelContainer(for: schema, configurations: [config])
        modelContext = ModelContext(modelContainer)
    }

    override func tearDown() {
        service = nil
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

    // MARK: - Exact Match

    func testExactMatchReturnsScore1() {
        let items = [makeItem("scissors")]
        let results = service.search(query: "scissors", in: items)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.score, 1.0)
    }

    func testExactMatchIsCaseInsensitive() {
        let items = [makeItem("Scissors")]
        let results = service.search(query: "SCISSORS", in: items)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.score, 1.0)
    }

    // MARK: - Contains Match

    func testContainsMatchReturnsHighScore() {
        let items = [makeItem("blue scissors")]
        let results = service.search(query: "scissors", in: items)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.score, 0.9)
    }

    // MARK: - Synonym Match

    func testSynonymMatchFindsRelatedItems() {
        let items = [makeItem("shears")]
        let results = service.search(query: "scissors", in: items)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.score, 0.8)
    }

    func testChargerCableSynonym() {
        let items = [makeItem("usb cable")]
        let results = service.search(query: "charger", in: items)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.score, 0.8)
    }

    // MARK: - Fuzzy / Typo Matching

    func testTypoMatchWithLevenshtein() {
        let items = [makeItem("scissors")]
        let results = service.search(query: "scisors", in: items)

        XCTAssertEqual(results.count, 1)
        XCTAssertTrue(results.first!.score > 0, "Typo should still match")
    }

    // MARK: - No Match

    func testNoMatchReturnsEmpty() {
        let items = [makeItem("scissors")]
        let results = service.search(query: "refrigerator", in: items)

        XCTAssertTrue(results.isEmpty)
    }

    func testEmptyQueryReturnsNoResults() {
        let items = [makeItem("scissors")]
        let results = service.search(query: "", in: items)

        XCTAssertTrue(results.isEmpty)
    }

    func testEmptyItemsReturnsEmpty() {
        let results = service.search(query: "scissors", in: [])
        XCTAssertTrue(results.isEmpty)
    }

    // MARK: - Sorting

    func testResultsSortedByScoreDescending() {
        let items = [
            makeItem("blue pen"),        // contains "pen"
            makeItem("pen"),             // exact match
            makeItem("pencil case"),     // synonym-ish via contains
        ]
        let results = service.search(query: "pen", in: items)

        XCTAssertGreaterThanOrEqual(results.count, 2)
        for i in 0..<(results.count - 1) {
            XCTAssertGreaterThanOrEqual(results[i].score, results[i + 1].score)
        }
    }

    // MARK: - Whitespace Handling

    func testQueryWithLeadingTrailingSpaces() {
        let items = [makeItem("tape")]
        let results = service.search(query: "  tape  ", in: items)

        XCTAssertEqual(results.count, 1)
        XCTAssertEqual(results.first?.score, 1.0)
    }
}
