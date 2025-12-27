import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            ShotListView()
                .tabItem {
                    Image(systemName: "list.bullet")
                }

            TimerView()
                .tabItem {
                    Image(systemName: "timer")
                }

            NavigationStack {
                AchievementGalleryView()
            }
            .tabItem {
                Image(systemName: "trophy")
            }
        }
    }
}

#Preview {
    MainTabView()
        .fontDesign(.monospaced)
        .preferredColorScheme(.dark)
        .tint(.orange)
        .modelContainer(for: [Shot.self, Bean.self], inMemory: true)
}
