import SwiftUI
import SwiftData

@main
struct TidyVibesApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            House.self,
            Room.self,
            Location.self,
            StorageSpace.self,
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @AppStorage("hasRunPhase5Migration") private var hasRunPhase5Migration = false

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                HomeView()
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
            }
        }
        .modelContainer(sharedModelContainer)
        .onAppear {
            if !hasRunPhase5Migration {
                runPhase5Migration()
            }
        }
    }

    /// Phase 5 data migration: assign orphaned StorageSpaces to a default "Unsorted" room.
    private mutating func runPhase5Migration() {
        let context = sharedModelContainer.mainContext

        // Find storage spaces not assigned to any location
        let allSpaces = (try? context.fetch(FetchDescriptor<StorageSpace>())) ?? []
        let orphanedSpaces = allSpaces.filter { $0.location == nil }

        guard !orphanedSpaces.isEmpty else {
            hasRunPhase5Migration = true
            return
        }

        // Find or create a default house
        let allHouses = (try? context.fetch(FetchDescriptor<House>())) ?? []
        let defaultHouse: House
        if let existing = allHouses.first {
            defaultHouse = existing
        } else {
            defaultHouse = House(name: "My Home", icon: "house.fill", color: "#4A90E2")
            context.insert(defaultHouse)
        }

        // Create the "Unsorted" room under the default house
        let unsortedRoom = Room(name: "Unsorted", icon: "tray.fill", color: "#78909C")
        unsortedRoom.house = defaultHouse
        unsortedRoom.sortOrder = (defaultHouse.rooms.map(\.sortOrder).max() ?? -1) + 1
        context.insert(unsortedRoom)

        // Create a "General" location under the unsorted room
        let generalLocation = Location(name: "General")
        generalLocation.room = unsortedRoom
        context.insert(generalLocation)

        // Assign all orphaned storage spaces to this location
        for space in orphanedSpaces {
            space.location = generalLocation
        }

        try? context.save()
        hasRunPhase5Migration = true
    }
}
