import SwiftUI
import SwiftData

@main
struct WhatThePuckApp: App {
    @State private var achievementTracker = AchievementTracker()

    init() {
        AppearanceConfiguration.apply()
    }

    var body: some Scene {
        WindowGroup {
            MainTabView()
                .fontDesign(.monospaced)
                .preferredColorScheme(.dark)
                .tint(.orange)
                .environment(achievementTracker)
        }
        .modelContainer(for: [Shot.self, Bean.self, Achievement.self])
    }
}
