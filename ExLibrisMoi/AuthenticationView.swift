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
            
            Text("ex libris,\nmoi")
                .font(.custom("Georgia", size: 32))
                .multilineTextAlignment(.center)
                .padding()
            
            Text("Your library, your legacy.")
                .font(.custom("Georgia", size: 18))
            
            Spacer()
            
            NavigationLink(destination: LoginView()) {
                Text("Log In")
                .font(.custom("Georgia", size: 18))
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
            }
            
            NavigationLink(destination: SignUpView()) {
                Text("Sign Up")
                    .font(.custom("Georgia", size: 18))
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