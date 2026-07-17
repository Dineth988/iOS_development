import SwiftUI

struct ContentView: View {
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }

            StatsView()
                .tabItem {
                    Label("Stats", systemImage: "chart.bar.fill")
                }

            MapView()
                .tabItem {
                    Label("Map", systemImage: "map.fill")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape.fill")
                }
        }
        .environmentObject(settingsViewModel)
        .preferredColorScheme(.dark)
        .onAppear {
            settingsViewModel.startMonitoring()
            LocationProvider.shared.requestPermissionIfNeeded()
        }
        .onDisappear {
            settingsViewModel.stopMonitoring()
        }
        .alert("Daily Challenge", isPresented: $settingsViewModel.isShowingChallengeBanner) {
            Button("Let's go", role: .cancel) {}
        } message: {
            Text("It's time for today's challenge — jump into a quick game!")
        }
    }
}

#Preview {
    ContentView()
}
