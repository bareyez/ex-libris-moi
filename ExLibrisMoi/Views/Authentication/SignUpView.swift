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
    @State private var showUsernameError = false
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Create Account")
                .font(.largeTitle)
            
            Group {
                TextField("Your first name", text: $firstName)
                TextField("Your last name", text: $lastName)
                TextField("Choose a username", text: $username)
                    .autocapitalization(.none)
                    .onChange(of: username) { newValue in
                        checkUsernameAvailability()
                    }
                TextField("Your email address", text: $email)
                    .textInputAutocapitalization(.never)
                SecureField("Create a password", text: $password)
            }
            .textFieldStyle(.roundedBorder)
            .controlSize(.large)
            
            if isCheckingUsername {
                ProgressView()
            }
            
            Text("Password must be at least 8 characters.")
                .font(.caption)
                .foregroundColor(.gray)
            
            Button("Create account") {
                validateAndSignUp()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray))
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isLoading)
            
            if isLoading {
                ProgressView()
            }
            
            Text("By creating an account, you agree to our Terms of Service and Privacy Policy.")
                .font(.caption)
                .multilineTextAlignment(.center)
                .foregroundColor(.gray)
        }
        .padding()
        .navigationBarBackButtonHidden(false)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .alert("Username Not Available", isPresented: $showUsernameError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("This username is already taken. Please choose another one.")
        }
    }
    
    private func validateAndSignUp() {
        if firstName.isEmpty || lastName.isEmpty || username.isEmpty || email.isEmpty || password.isEmpty {
            errorMessage = "Please fill in all fields"
            showError = true
            return
        }
        
        if password.count < 8 {
            errorMessage = "Password must be at least 8 characters long"
            showError = true
            return
        }
        
        if !email.contains("@") {
            errorMessage = "Please enter a valid email address"
            showError = true
            return
        }
        
        isLoading = true
        signUp()
    }
    
    private func checkUsernameAvailability() {
        guard !username.isEmpty else { return }
        isCheckingUsername = true
        
        Firestore.firestore().collection("usernames")
            .document(username.lowercased())
            .getDocument { document, error in
                isCheckingUsername = false
                if let document = document, document.exists {
                    showUsernameError = true
                }
            }
    }
    
    private func signUp() {
        // First check if username exists
        Firestore.firestore().collection("usernames")
            .document(username.lowercased())
            .getDocument { document, error in
                if let document = document, document.exists {
                    errorMessage = "This username is already taken. Please choose another one."
                    showError = true
                    return
                }
                
                // If username is available, proceed with account creation
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
                                } else {
                                    // Dismiss the view when account creation and data saving is successful
                                    dismiss()
                                }
                            }
                    }
                }
            }
    }
} 
