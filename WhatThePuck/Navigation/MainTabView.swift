import SwiftUI
import SwiftData

struct MainTabView: View {
    var body: some View {
        TabView {
            ShotListView()
                .tabItem {
                    Label("Shots", systemImage: "list.bullet")
                }

            TimerView()
                .tabItem {
                    Label("Timer", systemImage: "timer")
                }

            BeanListView()
                .tabItem {
                    Label("Beans", systemImage: "leaf")
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
