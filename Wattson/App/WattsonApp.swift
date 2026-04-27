import SwiftUI

@main
struct WattsonApp: App {
    @StateObject private var store = HouseholdStore()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(store)
        }
    }
}
