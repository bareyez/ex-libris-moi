import SwiftUI
import FirebaseAuth

struct AuthenticationView: View {
    @State private var isAuthenticated = false
    
    var body: some View {
        NavigationStack {
            if isAuthenticated {
                MainTabView()
            } else {
                WelcomeView()
            }
        }
        .onAppear {
            Auth.auth().addStateDidChangeListener { auth, user in
                isAuthenticated = user != nil
            }
        }
    }
}

struct WelcomeView: View {
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            Image("exlibrismoi_launch")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
                .padding()
            
            Text("Your library, your legacy.")
                .font(.title3)
            
            Spacer()
            
            NavigationLink(destination: LoginView()) {
                Text("Log In")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
            NavigationLink(destination: SignUpView()) {
                Text("Sign Up")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray))
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
        }
        .padding()
    }
} 