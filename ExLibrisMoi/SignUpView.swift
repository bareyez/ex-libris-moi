import SwiftUI
import FirebaseFirestore
import FirebaseAuth

struct SignUpView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var email = ""
    @State private var password = ""
    @State private var username = ""
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var isCheckingUsername = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.custom("Georgia", size: 32))
            
            TextField("Your first name", text: $firstName)
                .textFieldStyle(.roundedBorder)
            
            TextField("Your last name", text: $lastName)
                .textFieldStyle(.roundedBorder)
            
            TextField("Choose a username", text: $username)
                .textFieldStyle(.roundedBorder)
                .autocapitalization(.none)
                .onChange(of: username) { newValue in
                    checkUsernameAvailability()
                }
            
            if isCheckingUsername {
                ProgressView()
            }
            
            TextField("Your email address", text: $email)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
            
            SecureField("Create a password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            Text("Password must be at least 8 characters.")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button("Create account") {
                signUp()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray))
            .foregroundColor(.white)
            .cornerRadius(10)
            
            Text("By creating an account, you agree to our Terms of Service and Privacy Policy.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
        .padding()
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .navigationBarBackButtonHidden(false)
    }
    
    private func checkUsernameAvailability() {
        guard !username.isEmpty else { return }
        isCheckingUsername = true
        
        Firestore.firestore().collection("usernames")
            .document(username.lowercased())
            .getDocument { document, error in
                isCheckingUsername = false
                if let document = document, document.exists {
                    errorMessage = "Username is already taken"
                    showError = true
                }
            }
    }
    
    private func signUp() {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                errorMessage = error.localizedDescription
                showError = true
                return
            }
            
            if let user = result?.user {
                let userData = [
                    "firstName": firstName,
                    "lastName": lastName,
                    "email": email,
                    "username": username,
                    "memberSince": Date().timeIntervalSince1970
                ]
                
                // Save username to separate collection for uniqueness check
                Firestore.firestore().collection("usernames")
                    .document(username.lowercased())
                    .setData(["uid": user.uid])
                
                Firestore.firestore().collection("users")
                    .document(user.uid)
                    .setData(userData) { error in
                        if let error = error {
                            errorMessage = error.localizedDescription
                            showError = true
                        }
                    }
            }
        }
    }
} 
