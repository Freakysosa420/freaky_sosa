import SwiftUI
import SwiftData

/// The main entry point for the freaky_sosa iOS application.
@main
public struct freaky_sosaApp: App {
    public init() {}

    public var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            // Add your SwiftData model types here as your schema grows
        ])
    }
}
