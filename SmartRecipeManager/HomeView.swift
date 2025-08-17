import SwiftUI

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Binding var isLoggedIn: Bool
    
    @AppStorage("colorScheme") private var colorScheme = "system"
    
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.createdAt, ascending: false)], animation: .default)
    private var allRecipes: FetchedResults<Recipe>
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.createdAt, ascending: false)], predicate: NSPredicate(format: "isFavorite == TRUE"), animation: .default)
    private var favoriteRecipes: FetchedResults<Recipe>

    @State private var showingAddRecipeSheet = false
    @State private var selectedCategory: String = "All Recipes"

    @State private var homeSearchText = ""
    
    private var filteredRecipes: [Recipe] {
        if selectedCategory == "All Recipes" {
            return Array(allRecipes)
        } else {
            return allRecipes.filter { $0.category == selectedCategory }
        }
    }
    
    private var searchedAndFilteredRecipes: [Recipe] {
        if homeSearchText.isEmpty {
            return filteredRecipes
        } else {
            return filteredRecipes.filter { recipe in
                (recipe.name?.localizedCaseInsensitiveContains(homeSearchText) ?? false) ||
                (recipe.ingredients?.localizedCaseInsensitiveContains(homeSearchText) ?? false)
            }
        }
    }

    var body: some View {
        NavigationView {
            ScrollView(.vertical) {
                VStack(alignment: .leading, spacing: 24) {
                    Text("Smart Recipe Manager")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                        .foregroundColor(.brandPrimary)
                        .frame(maxWidth: .infinity, alignment: .center)
                        .padding(.top, 8)
                    
                    Text("Featured Recipes")
                        .font(.title2).fontWeight(.bold).padding(.horizontal)
                    
                    if favoriteRecipes.isEmpty {
                        VStack(alignment: .center, spacing: 8) {
                            Text("No Featured Recipes Yet").font(.headline)
                            Text("Tap the ❤️ on a recipe's detail page to add it here.").font(.subheadline).foregroundColor(.secondary)
                        }.frame(maxWidth: .infinity).padding().background(Color.secondary.opacity(0.1)).cornerRadius(12).padding(.horizontal)
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(favoriteRecipes) { recipe in
                                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                        RecipeCardView(recipe: recipe).frame(width: 280)
                                    }.buttonStyle(.plain)
                                }
                            }.padding(.horizontal)
                        }
                    }
                    
                    VStack(spacing: 12) {
                        categoryButton(for: "All Recipes")
                        HStack(spacing: 12) {
                            categoryButton(for: "Breakfast"); categoryButton(for: "Lunch"); categoryButton(for: "Dinner")
                        }
                        HStack(spacing: 12) {
                            categoryButton(for: "Dessert"); categoryButton(for: "Snack"); categoryButton(for: "Vegan")
                        }
                        HStack(spacing: 12) {
                            categoryButton(for: "Vegetarian"); categoryButton(for: "Non Vegetarian"); categoryButton(for: "Healthy")
                        }
                    }
                    .padding(.horizontal)

                    Text(selectedCategory)
                        .font(.title2).fontWeight(.bold).padding(.horizontal)
                    
                    if searchedAndFilteredRecipes.isEmpty {
                        Text(homeSearchText.isEmpty ? "No recipes found in this category." : "No recipes found for '\(homeSearchText)'.")
                            .foregroundColor(.secondary)
                            .frame(maxWidth: .infinity, alignment: .center)
                            .padding()
                    } else {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 16) {
                                ForEach(searchedAndFilteredRecipes) { recipe in
                                    NavigationLink(destination: RecipeDetailView(recipe: recipe)) {
                                        RecipeCardView(recipe: recipe).frame(width: 280)
                                    }.buttonStyle(.plain)
                                }
                            }.padding(.horizontal)
                        }
                    }
                }
                .padding(.vertical)
            }
            .background(Color.secondary.opacity(0.1).ignoresSafeArea())
            .searchable(text: $homeSearchText, prompt: "Search Recipes")
            .toolbar {
                ToolbarItemGroup(placement: .navigationBarLeading) {
                    Button("Logout") {
                        withAnimation { isLoggedIn = false }
                    }
                }
                ToolbarItemGroup(placement: .navigationBarTrailing) {
                    Button { toggleColorScheme() } label: { Image(systemName: themeIcon) }
                    Button { showingAddRecipeSheet.toggle() } label: { Image(systemName: "plus.circle.fill").font(.title2) }
                }
            }
            .foregroundColor(.brandPrimary)
            .sheet(isPresented: $showingAddRecipeSheet) { AddRecipeView() }
        }
    }
    
    @ViewBuilder
    private func categoryButton(for category: String) -> some View {
        Button(action: {
            withAnimation {
                selectedCategory = category
            }
        }) {
            Text(category)
                .font(.caption)
                .fontWeight(.semibold)
                .padding(.vertical, 10)
                .frame(maxWidth: .infinity)
                .background(selectedCategory == category ? Color.brandPrimary : Color.secondary.opacity(0.2))
                .foregroundColor(selectedCategory == category ? .white : .primaryText)
                .cornerRadius(8)
        }
    }
    
    private func toggleColorScheme() {
        if colorScheme == "light" { colorScheme = "dark" }
        else if colorScheme == "dark" { colorScheme = "system" }
        else { colorScheme = "light" }
    }
    
    private var themeIcon: String {
        switch colorScheme {
        case "light": return "sun.max.fill"
        case "dark": return "moon.fill"
        default: return "gearshape"
        }
    }
}
