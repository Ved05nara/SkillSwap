import SwiftUI

struct ContentView: View {
    @EnvironmentObject var appData: AppData
    @EnvironmentObject var authService: AuthService

    var body: some View {
        Group {
            if authService.isAuthenticated {
                TabView {
                    HomeView()
                        .environmentObject(appData)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }

                    ExploreView()
                        .environmentObject(appData)
                        .tabItem {
                            Label("Explore", systemImage: "magnifyingglass")
                        }

                    RequestsView()
                        .environmentObject(appData)
                        .tabItem {
                            Label("Requests", systemImage: "arrow.left.arrow.right")
                        }

                    ProfileView()
                        .environmentObject(appData)
                        .tabItem {
                            Label("Profile", systemImage: "person.fill")
                        }
                    
                    CampusMapView()
                        .tabItem {
                            Label("Map", systemImage: "map.fill")
                        }
                }
                .tint(.indigo)
                .task {
                    await appData.loadStudents()
                    await appData.loadRequests()
                }
            } else {
                AuthView()
                    .environmentObject(authService)
                    .environmentObject(appData)
            }
        }
    }
}
