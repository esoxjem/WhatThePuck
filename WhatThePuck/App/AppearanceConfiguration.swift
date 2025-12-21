import UIKit

enum AppearanceConfiguration {
    static func apply() {
        configureNavigationBar()
        configureTabBar()
    }

    private static func configureNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.largeTitleTextAttributes = [.font: UIFont.monospacedSystemFont(ofSize: 34, weight: .bold)]
        appearance.titleTextAttributes = [.font: UIFont.monospacedSystemFont(ofSize: 17, weight: .semibold)]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        UINavigationBar.appearance().compactAppearance = appearance
    }

    private static func configureTabBar() {
        let appearance = UITabBarAppearance()
        appearance.configureWithDefaultBackground()
        let itemAppearance = UITabBarItemAppearance()
        itemAppearance.normal.titleTextAttributes = [.font: UIFont.monospacedSystemFont(ofSize: 10, weight: .medium)]
        itemAppearance.selected.titleTextAttributes = [
            .font: UIFont.monospacedSystemFont(ofSize: 10, weight: .medium),
            .foregroundColor: UIColor.orange
        ]
        itemAppearance.selected.iconColor = .orange
        appearance.stackedLayoutAppearance = itemAppearance
        appearance.inlineLayoutAppearance = itemAppearance
        appearance.compactInlineLayoutAppearance = itemAppearance
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}
