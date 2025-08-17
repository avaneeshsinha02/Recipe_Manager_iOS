import SwiftUI

struct DiscoverView: View {
    @Environment(\.managedObjectContext) private var viewContext
    
    @State private var apiRecipe: APIRecipe?
    @State private var isLoading = false
    @State private var isSaving = false // NEW: State to show a saving indicator
    @State private var errorMessage: String?
    @State private var showSaveConfirmation = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    if isLoading {
                        ProgressView("Finding a tasty recipe...")
                            .padding()
                    } else if let recipe = apiRecipe {
                        recipeDetailContent(for: recipe)
                    } else {
                        VStack {
                            Image(systemName: "fork.knife.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.secondary)
                            Text(errorMessage ?? "Tap the button to discover a new recipe!")
                                .font(.headline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("Discover")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        Task { await loadRandomRecipe() }
                    }) {
                        Image(systemName: "dice")
                    }
                    .disabled(isLoading || isSaving)
                }
            }
            .alert("Recipe Saved!", isPresented: $showSaveConfirmation) {
                Button("OK", role: .cancel) { }
            }
        }
    }
    
    @ViewBuilder
    private func recipeDetailContent(for recipe: APIRecipe) -> some View {
        AsyncImage(url: URL(string: recipe.thumbnailURLString)) { image in
            image.resizable()
        } placeholder: {
            ProgressView()
        }
        .aspectRatio(contentMode: .fit)
        .cornerRadius(12)
        .padding(.horizontal)
        
        Text(recipe.name)
            .font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)

        VStack(alignment: .leading, spacing: 12) {
            Text("Ingredients").font(.title2).fontWeight(.semibold)
            ForEach(recipe.ingredientsList, id: \.self) { ingredient in
                Text("• \(ingredient)")
            }
        }
        .padding()
        
        VStack(alignment: .leading, spacing: 12) {
            Text("Instructions").font(.title2).fontWeight(.semibold)
            Text(recipe.instructions)
        }
        .padding()
        
        Button(action: {
            Task { await saveAPIRecipeToCoreData(apiRecipe: recipe) }
        }) {
            if isSaving {
                ProgressView()
            } else {
                Label("Save to My Recipes", systemImage: "plus.circle.fill")
            }
        }
        .font(.headline)
        .foregroundColor(.white)
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.brandPrimary)
        .cornerRadius(10)
        .disabled(isSaving)
        .padding()
    }
    
    private func loadRandomRecipe() async {
        isLoading = true
        errorMessage = nil
        apiRecipe = nil
        
        do {
            apiRecipe = try await NetworkManager.shared.fetchRandomRecipe()
        } catch {
            errorMessage = "Sorry, couldn't fetch a recipe. Please check your internet connection and try again."
        }
        
        isLoading = false
    }
    
    private func saveAPIRecipeToCoreData(apiRecipe: APIRecipe) async {
        isSaving = true
        
        let newRecipe = Recipe(context: viewContext)
        newRecipe.id = UUID()
        newRecipe.createdAt = Date()
        newRecipe.name = apiRecipe.name
        newRecipe.ingredients = apiRecipe.ingredientsList.joined(separator: "\n")
        newRecipe.instructions = apiRecipe.instructions
        
        if let url = URL(string: apiRecipe.thumbnailURLString) {
            if let (data, _) = try? await URLSession.shared.data(from: url) {
                newRecipe.imageData = data
            }
        }
        
        newRecipe.category = "All Recipes"
        newRecipe.cookingTime = 30
        newRecipe.difficulty = 3
        newRecipe.isFavorite = false
        
        do {
            try viewContext.save()
            showSaveConfirmation = true
        } catch {
            print("Failed to save discovered recipe: \(error)")
        }
        
        isSaving = false
    }
}
