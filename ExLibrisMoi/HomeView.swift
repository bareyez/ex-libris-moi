import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomeView: View {
    @State private var firstName = ""
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                HStack {
                    Text("Hello, \(firstName)!")
                        .font(.custom("Georgia", size: 32))
                        .lineLimit(1)
                        .minimumScaleFactor(0.5)
                    
                    Spacer()
                    
                    Button(action: {}) {
                        Image(systemName: "plus")
                            .font(.title2)
                    }
                }
                .padding()
                
                Text("Your library")
                    .font(.custom("Georgia", size: 24))
                    .padding(.horizontal)
                
                Spacer()
                
                Button(action: {}) {
                    Label("Add your first book!", systemImage: "plus")
                        .font(.custom("Georgia", size: 18))
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color(.systemGray))
                        .foregroundColor(.white)
                        .cornerRadius(10)
                }
                .padding()
                
                Spacer()
            }
        }
        .onAppear {
            fetchUserData()
        }
    }
    
    private func fetchUserData() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        Firestore.firestore().collection("users").document(userId).getDocument { document, error in
            if let document = document, document.exists {
                firstName = document.data()?["firstName"] as? String ?? ""
            }
        }
    }
} 
