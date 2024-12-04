import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var identifier = ""
    @State private var password = ""
    @State private var errorMessage = ""
    @State private var showError = false
    @State private var isLoading = false
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Log in")
                .font(.custom("Garamond", size: 32))
            
            TextField("Email or Username", text: $identifier)
                .textFieldStyle(.roundedBorder)
                .textInputAutocapitalization(.never)
                .autocorrectionDisabled(true)
            
            SecureField("Password", text: $password)
                .textFieldStyle(.roundedBorder)
            
            Button("Log in") {
                login()
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(.systemGray))
            .foregroundColor(.white)
            .cornerRadius(10)
            .disabled(isLoading)
            
            Button("Forgot password?") {
                // Implement password reset
            }
            .font(.footnote)
        }
        .padding()
        .alert("Error", isPresented: $showError) {
            Button("OK") { }
        } message: {
            Text(errorMessage)
        }
        .navigationBarBackButtonHidden(false)
    }
    
    private func login() {
        isLoading = true
        
        if identifier.contains("@") {
            loginWithEmail(identifier)
        } else {
            lookupEmailForUsername(identifier) { email in
                if let email = email {
                    loginWithEmail(email)
                } else {
                    isLoading = false
                    errorMessage = "Username not found"
                    showError = true
                }
            }
        }
    }
    
    private func lookupEmailForUsername(_ username: String, completion: @escaping (String?) -> Void) {
        let db = Firestore.firestore()
        db.collection("users")
            .whereField("username", isEqualTo: username.lowercased())
            .getDocuments { snapshot, error in
                if let error = error {
                    DispatchQueue.main.async {
                        errorMessage = error.localizedDescription
                        showError = true
                        isLoading = false
                    }
                    completion(nil)
                    return
                }
                
                guard let document = snapshot?.documents.first,
                      let email = document.data()["email"] as? String else {
                    DispatchQueue.main.async {
                        completion(nil)
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    completion(email)
                }
            }
    }
    
    private func loginWithEmail(_ email: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            DispatchQueue.main.async {
                isLoading = false
                if let error = error {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
} 