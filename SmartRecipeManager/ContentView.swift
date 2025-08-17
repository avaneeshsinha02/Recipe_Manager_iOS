import SwiftUI
import CoreData

struct ContentView: View {
    @AppStorage("isLoggedIn") private var isLoggedIn = false
    @AppStorage("colorScheme") private var colorScheme = "system"

    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView(isLoggedIn: $isLoggedIn)
            } else {
                AuthView(isLoggedIn: $isLoggedIn)
            }
        }
        .preferredColorScheme(colorScheme == "dark" ? .dark : (colorScheme == "light" ? .light : nil))
    }
}
