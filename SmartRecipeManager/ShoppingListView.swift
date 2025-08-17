import SwiftUI
import CoreData

struct ShoppingListView: View {
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Recipe.createdAt, ascending: false)],
        animation: .default)
    private var recipes: FetchedResults<Recipe>
    
    @State private var searchText = ""
    @State private var sortOrder: SortOrder = .newest
    
    @State private var checkedItems: Set<String> = []

    enum SortOrder {
        case newest, alphabetical
    }
    
    private var searchAndSortedResults: [Recipe] {
        let filteredRecipes = recipes.filter { recipe in
            if searchText.isEmpty {
                return true
            }
            let nameMatch = recipe.name?.localizedCaseInsensitiveContains(searchText) ?? false
            let ingredientsMatch = recipe.ingredients?.localizedCaseInsensitiveContains(searchText) ?? false
            return nameMatch || ingredientsMatch
        }
        
        switch sortOrder {
        case .newest:
            return filteredRecipes
        case .alphabetical:
            return filteredRecipes.sorted { $0.name ?? "" < $1.name ?? "" }
        }
    }

    var body: some View {
        NavigationView {
            List {
                ForEach(searchAndSortedResults) { recipe in
                    Section(header:
                        Text(recipe.name ?? "Untitled Recipe")
                            .font(.title3).fontWeight(.bold).foregroundColor(.brandPrimary)
                            .textCase(nil).padding(.vertical, 8)
                    ) {
                        let ingredients = recipe.ingredients?.split(separator: "\n").map(String.init) ?? []
                        ForEach(ingredients, id: \.self) { ingredient in
                            HStack(spacing: 16) {
                                Button(action: { toggleCheck(for: ingredient, from: recipe) }) {
                                    Image(systemName: isChecked(ingredient: ingredient, from: recipe) ? "checkmark.square.fill" : "square")
                                        .foregroundColor(.brandPrimary)
                                }
                                Text(ingredient)
                                    .strikethrough(isChecked(ingredient: ingredient, from: recipe), color: .secondaryText)
                                    .foregroundColor(isChecked(ingredient: ingredient, from: recipe) ? .secondaryText : .primaryText)
                            }
                            .font(.body)
                        }
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Shopping List")
            .searchable(text: $searchText, prompt: "Search Recipes or Ingredients")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: { sortOrder = .newest }) {
                            Label("Newest", systemImage: sortOrder == .newest ? "checkmark" : "")
                        }
                        Button(action: { sortOrder = .alphabetical }) {
                            Label("Alphabetical (A-Z)", systemImage: sortOrder == .alphabetical ? "checkmark" : "")
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down.circle")
                    }
                }
            }
            .onAppear(perform: loadCheckedItems)
            .onChange(of: checkedItems) {
                saveCheckedItems()
            }
        }
    }
    
    
    private func itemID(for ingredient: String, from recipe: Recipe) -> String {
        return "\(recipe.id?.uuidString ?? "")-\(ingredient)"
    }
    
    private func isChecked(ingredient: String, from recipe: Recipe) -> Bool {
        checkedItems.contains(itemID(for: ingredient, from: recipe))
    }
    
    private func toggleCheck(for ingredient: String, from recipe: Recipe) {
        let id = itemID(for: ingredient, from: recipe)
        if isChecked(ingredient: ingredient, from: recipe) {
            checkedItems.remove(id)
        } else {
            checkedItems.insert(id)
        }
    }
    
    private func saveCheckedItems() {
        let checkedItemsArray = Array(checkedItems)
        UserDefaults.standard.set(checkedItemsArray, forKey: "checkedShoppingItems")
    }
    
    private func loadCheckedItems() {
        let checkedItemsArray = UserDefaults.standard.array(forKey: "checkedShoppingItems") as? [String] ?? []
        checkedItems = Set(checkedItemsArray)
    }
}
