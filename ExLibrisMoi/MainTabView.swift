import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Label("Home", systemImage: "house")
                }
            
            Text("Discover")
                .tabItem {
                    Label("Discover", systemImage: "magnifyingglass")
                }
            
            Text("Community")
                .tabItem {
                    Label("Community", systemImage: "person.3")
                }
            
            Text("Lending")
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
