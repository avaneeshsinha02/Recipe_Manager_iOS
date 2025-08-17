import WidgetKit
import SwiftUI
import CoreData
import AppIntents

struct RefreshRecipeIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh Recipe"
    
    func perform() async throws -> some IntentResult {
        WidgetCenter.shared.reloadTimelines(ofKind: "RecipeWidget")
        return .result()
    }
}

struct Provider: TimelineProvider {
    private let viewContext: NSManagedObjectContext

    init(context: NSManagedObjectContext) {
        self.viewContext = context
    }

    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), recipe: nil)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), recipe: fetchRandomRecipe())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let recipe = fetchRandomRecipe()
        let entry = SimpleEntry(date: Date(), recipe: recipe)
        
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
    
    private func fetchRandomRecipe() -> Recipe? {
        let request = NSFetchRequest<Recipe>(entityName: "Recipe")
        do {
            let allRecipes = try viewContext.fetch(request)
            return allRecipes.randomElement()
        } catch {
            print("Failed to fetch recipes for widget: \(error)")
            return nil
        }
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let recipe: Recipe?
}

struct RecipeWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.colorScheme) var colorScheme

    var body: some View {
        mediumWidgetView
    }
    
    
    @ViewBuilder
    var mediumWidgetView: some View {
        HStack(spacing: 12) {
            if let recipe = entry.recipe, let id = recipe.id {
                recipeImageView(for: recipe)
                    .frame(width: 100)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                
                Link(destination: URL(string: "recipeapp://recipe/\(id.uuidString)")!) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Today's special")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.secondary)
                        
                        if let name = recipe.name, (1...4).contains(name.count) {
                            VStack(alignment: .leading, spacing: -4) {
                                ForEach(Array(name), id: \.self) { character in
                                    Text(String(character))
                                }
                            }
                            .font(.headline).fontWeight(.bold)
                        } else {
                            Text(recipe.name ?? "Recipe")
                                .font(.headline).fontWeight(.bold)
                                .foregroundColor(.primaryText)
                                .lineLimit(2)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        
                        Spacer()
                        Text(recipe.category ?? "")
                            .font(.caption).foregroundColor(.brandPrimary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
            } else {
                noRecipeView
            }
            
            VStack {
                Button(intent: RefreshRecipeIntent()) {
                    ZStack {
                        let lightModeColor = Color(red: 0, green: 31/255, blue: 63/255)
                        let darkModeColor = Color(red: 135/255, green: 206/255, blue: 235/255)
                        
                        Circle()
                            .fill(colorScheme == .dark ? darkModeColor : lightModeColor)
                            .frame(width: 40, height: 40)
                        
                        Image(systemName: "shuffle")
                            .font(.system(size: 18, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .buttonStyle(.plain)
                Spacer()
            }
        }
        .padding()
    }
    
    @ViewBuilder
    private func recipeImageView(for recipe: Recipe) -> some View {
        if let imageData = recipe.imageData, let uiImage = UIImage(data: imageData) {
            Image(uiImage: uiImage).resizable().aspectRatio(contentMode: .fill)
        } else {
            Color.secondary.opacity(0.2).overlay(Image(systemName: "photo"))
        }
    }
    
    @ViewBuilder
    var noRecipeView: some View {
        VStack {
            Image(systemName: "fork.knife.circle")
            Text("No Recipes").font(.caption)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.secondary.opacity(0.1))
    }
}

@main
struct RecipeWidget: Widget {
    let kind: String = "RecipeWidget"
    private let persistenceController = PersistenceController.shared

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider(context: persistenceController.container.viewContext)) { entry in
            RecipeWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Recipe Spotlight")
        .description("Displays a random recipe from your collection.")
        .supportedFamilies([.systemMedium])
    }
}
