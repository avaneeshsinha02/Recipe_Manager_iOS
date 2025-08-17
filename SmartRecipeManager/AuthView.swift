import SwiftUI

struct AuthView: View {
    @Binding var isLoggedIn: Bool
    
    @State private var showSignUp = false
    
    var body: some View {
        if showSignUp {
            SignUpView(showSignUp: $showSignUp)
        } else {
            LoginView(isLoggedIn: $isLoggedIn, showSignUp: $showSignUp)
        }
    }
}
