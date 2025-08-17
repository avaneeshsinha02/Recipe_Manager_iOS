import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @Binding var isLoggedIn: Bool
    @Binding var showSignUp: Bool

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer()
                
                Image("AppLogo")
                    .resizable().aspectRatio(contentMode: .fit).frame(width: 150, height: 150).padding(.bottom, 20)
                
                Text("Welcome Back")
                    .font(.largeTitle).fontWeight(.bold).foregroundColor(.brandPrimary)

                Text("Log in to manage all your tasty recipes in one place!")
                    .font(.headline)
                    .foregroundColor(.secondaryText)
                    .multilineTextAlignment(.center)

                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .padding().background(Color.secondary.opacity(0.1)).cornerRadius(10)
                        .keyboardType(.emailAddress).autocapitalization(.none)

                    SecureField("Password", text: $password)
                        .padding().background(Color.secondary.opacity(0.1)).cornerRadius(10)
                }
                .padding(.horizontal)

                Button(action: login) {
                    Text("Login")
                        .font(.headline).foregroundColor(.white).padding()
                        .frame(maxWidth: .infinity).background(Color.brandPrimary).cornerRadius(10).shadow(radius: 5)
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("Don't have an account? Click here to get onboarded!")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primaryText)
                    Button("Sign Up") {
                        showSignUp = true
                    }
                    .foregroundColor(.brandPrimary)
                    .fontWeight(.bold)
                }
                .padding(.bottom)
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Login Failed"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func login() {
        let users = UserDefaults.standard.dictionary(forKey: "registeredUsers") as? [String: String] ?? [:]
        
        if let storedPassword = users[email] {
            if storedPassword == password {
                withAnimation { isLoggedIn = true }
            } else {
                alertMessage = "The password you entered is incorrect."
                showAlert = true
            }
        } else {
            alertMessage = "No account found with this email. Please sign up first."
            showAlert = true
        }
    }
}
