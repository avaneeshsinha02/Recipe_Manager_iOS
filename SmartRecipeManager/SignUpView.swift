import SwiftUI

struct SignUpView: View {
    @State private var email = ""
    @State private var password = ""
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    @Binding var showSignUp: Bool

    var body: some View {
        ZStack {
            Color.background.ignoresSafeArea()
            VStack(spacing: 20) {
                Spacer()
                
                Image("AppLogo")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 150, height: 150)
                    .padding(.bottom, 20)
                
                Text("Create Account")
                    .font(.largeTitle).fontWeight(.bold).foregroundColor(.brandPrimary)

                VStack(spacing: 15) {
                    TextField("Email", text: $email)
                        .padding().background(Color.secondary.opacity(0.1)).cornerRadius(10)
                        .keyboardType(.emailAddress).autocapitalization(.none)

                    SecureField("Password", text: $password)
                        .padding().background(Color.secondary.opacity(0.1)).cornerRadius(10)
                }
                .padding(.horizontal)
                
                Text("Password must atleast be 6 characters and include a number and a special character!")
                    .multilineTextAlignment(.center)
                    .font(.caption).foregroundColor(.secondaryText).padding(.horizontal)

                Button(action: signUp) {
                    Text("Sign Up")
                        .font(.headline).foregroundColor(.white).padding()
                        .frame(maxWidth: .infinity).background(Color.brandPrimary).cornerRadius(10)
                }
                .padding(.horizontal)
                
                Spacer()
                
                VStack(spacing: 8) {
                    Text("If you already have an account, we remember you!")
                        .multilineTextAlignment(.center)
                        .foregroundColor(.primaryText)
                    Button("Log In") {
                        showSignUp = false
                    }
                    .foregroundColor(.brandPrimary)
                    .fontWeight(.bold)
                }
                .padding(.bottom)
            }
            .padding()
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Sign Up Error"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
            }
        }
    }
    
    func signUp() {
        if password.count < 6 {
            alertMessage = "Password must atleast be 6 characters and include a number and a special character!"
            showAlert = true
            return
        }

        var users = UserDefaults.standard.dictionary(forKey: "registeredUsers") as? [String: String] ?? [:]
        
        if users[email] != nil {
            alertMessage = "This email is already registered."
            showAlert = true
            return
        }
        
        users[email] = password
        UserDefaults.standard.set(users, forKey: "registeredUsers")
        
        alertMessage = "Sign up successful! Please log in."
        showAlert = true
        showSignUp = false
    }
}
