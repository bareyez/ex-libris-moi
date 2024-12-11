import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
            
            CommunityView()
                .tabItem {
                    Label("Community", systemImage: "person.3")
                }
            
            LendingView()
                .tabItem {
                    Label("Lending", systemImage: "arrow.left.arrow.right")
                }
            
            ProfileView()
                .tabItem {
                    Label("Profile", systemImage: "person")
                }
        }
    }
} 
