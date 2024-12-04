import SwiftUI
import FirebaseCore

@main
struct ExLibrisMoiApp: App {
    init() {
        FirebaseApp.configure()
    }
    
    var body: some Scene {
        WindowGroup {
            AuthenticationView()
        }
    }
} 
