import SwiftUI

struct RecipeDetailView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss
    @ObservedObject var recipe: Recipe
    
    @State private var showingEditSheet = false
    @State private var showingDeleteAlert = false

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                
                if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fill).frame(height: 300).clipped()
                } else {
                    Rectangle().fill(Color.secondary.opacity(0.2)).frame(height: 300).overlay(Image(systemName: "photo").font(.system(size: 60)).foregroundColor(.secondaryText))
                }

                LazyVStack(alignment: .leading, spacing: 20) {
                    
                    Text(recipe.name ?? "Untitled Recipe")
                        .font(.largeTitle).fontWeight(.bold).foregroundColor(.brandPrimary)
                        .frame(maxWidth: .infinity, alignment: .center)

                    HStack {
                        Spacer()
                        InfoPill(icon: "clock", text: "\(Int(recipe.cookingTime)) min")
                        InfoPill(icon: "dial.medium", text: "Difficulty \(Int(recipe.difficulty))/5")
                        Spacer()
                    }

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Ingredients").font(.title2).fontWeight(.semibold)
                        ForEach((recipe.ingredients ?? "").split(separator: "\n"), id: \.self) { ingredient in
                            HStack(alignment: .top) {
                                Image(systemName: "circle.fill").font(.system(size: 8)).foregroundColor(.brandPrimary).padding(.top, 6)
                                Text(ingredient).foregroundColor(.primaryText)
                            }
                        }
                    }
                    .padding()
                    .background(Color.background)
                    .cornerRadius(12)

                    VStack(alignment: .leading, spacing: 12) {
                        Text("Instructions").font(.title2).fontWeight(.semibold)
                        Text(recipe.instructions ?? "No instructions provided.").foregroundColor(.primaryText).lineSpacing(5)
                    }
                    .padding()
                    .background(Color.background)
                    .cornerRadius(12)
                    
                }
                .padding(.horizontal)
                .padding(.vertical)
            }
        }
        .background(Color.background.ignoresSafeArea())
        .ignoresSafeArea(edges: .top)
        .navigationTitle(recipe.name ?? "Recipe")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .navigationBarTrailing) {
                Button { toggleFavorite() } label: {
                    Image(systemName: recipe.isFavorite ? "heart.fill" : "heart")
                }
                Button { showingEditSheet.toggle() } label: {
                    Image(systemName: "pencil")
                }
                Button(role: .destructive) { showingDeleteAlert.toggle() } label: {
                    Image(systemName: "trash")
                }
            }
        }
        .foregroundColor(.brandPrimary)
        .sheet(isPresented: $showingEditSheet) {
            AddRecipeView(recipeToEdit: recipe)
        }
        .alert("Delete Recipe?", isPresented: $showingDeleteAlert, actions: {
            Button("Delete", role: .destructive) { deleteRecipe() }
            Button("Cancel", role: .cancel) { }
        }, message: {
            Text("Are you sure you want to delete this recipe? This action cannot be undone.")
        })
    }
    
    private func toggleFavorite() {
        recipe.isFavorite.toggle()
        do {
            try viewContext.save()
        } catch {
            print("Failed to save favorite status: \(error.localizedDescription)")
        }
    }
    
    private func deleteRecipe() {
        viewContext.delete(recipe)
        do {
            try viewContext.save()
            dismiss()
        } catch {
            print("Failed to delete recipe: \(error.localizedDescription)")
        }
    }
}

struct InfoPill: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
            Text(text)
        }
        .font(.subheadline)
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .foregroundColor(.brandPrimary)
        .background(Color.brandPrimary.opacity(0.15))
        .cornerRadius(15)
    }
}
