import SwiftUI
import SwiftData

@main
struct WhatThePuckApp: App {
    init() {
        AppearanceConfiguration.apply()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .fontDesign(.monospaced)
                .preferredColorScheme(.dark)
                .tint(.orange)
        }
        .modelContainer(for: [Shot.self, Bean.self])
    }
}
