import SwiftUI
import CoreData
import Foundation

struct MainTabView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isLoggedIn: Bool
    
    @State private var recipeToOpen: Recipe?

    var body: some View {
        TabView {
            HomeView(isLoggedIn: $isLoggedIn)
                .tabItem {
                    Label("Home", systemImage: "house.fill")
                }
            
            ShoppingListView()
                .tabItem {
                    Label("List", systemImage: "list.bullet")
                }
            
            DiscoverView()
                .tabItem {
                    Label("Discover", systemImage: "sparkles")
                }
        }
        .accentColor(.brandPrimary)
        .onOpenURL { url in
            handleIncomingURL(url)
        }
        .sheet(item: $recipeToOpen) { recipe in
            NavigationView {
                RecipeDetailView(recipe: recipe)
            }
        }
    }
    
    private func handleIncomingURL(_ url: URL) {
        guard url.scheme == "recipeapp", url.host == "recipe" else { return }
        
        let recipeIDString = url.lastPathComponent
        if let recipeID = UUID(uuidString: recipeIDString) {
            recipeToOpen = fetchRecipe(with: recipeID)
        }
    }
    
    private func fetchRecipe(with id: UUID) -> Recipe? {
        let request = NSFetchRequest<Recipe>(entityName: "Recipe")
        request.predicate = NSPredicate(format: "id == %@", id as NSUUID)
        request.fetchLimit = 1
        
        do {
            let recipes = try viewContext.fetch(request)
            return recipes.first
        } catch {
            print("Failed to fetch recipe by ID: \(error)")
            return nil
        }
    }
}
