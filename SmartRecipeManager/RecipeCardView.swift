import SwiftUI

struct RecipeCardView: View {
    @ObservedObject var recipe: Recipe

    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading) {
                if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 150)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.secondary.opacity(0.2))
                        .frame(height: 150)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.largeTitle)
                                .foregroundColor(.secondaryText)
                        )
                }
                
                VStack(alignment: .leading, spacing: 5) {
                    Text(recipe.name ?? "Untitled Recipe")
                        .font(.headline)
                        .foregroundColor(.primaryText)
                        .lineLimit(1)
                    
                    Text(recipe.category ?? "General")
                        .font(.subheadline)
                        .foregroundColor(.brandPrimary)
                        .fontWeight(.medium)

                    HStack {
                        Image(systemName: "clock")
                        Text("\(Int(recipe.cookingTime)) min")
                        Spacer()
                        Text("Difficulty \(Int(recipe.difficulty))/5")
                    }
                    .font(.caption)
                    .foregroundColor(.secondaryText)
                }
                .padding()
            }
            
            if recipe.isFavorite {
                Image(systemName: "heart.fill")
                    .foregroundColor(.red)
                    .padding(8)
                    .background(.thinMaterial)
                    .clipShape(Circle())
                    .padding(8)
            }
        }
        .background(Color.background)
        .cornerRadius(12)
        .shadow(color: .black.opacity(0.1), radius: 5, x: 0, y: 2)
    }
}
