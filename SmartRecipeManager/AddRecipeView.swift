import SwiftUI
import PhotosUI
import WidgetKit

struct AddRecipeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var category: String = "Breakfast"
    @State private var ingredients: String = ""
    @State private var instructions: String = ""
    @State private var cookingTime: Double = 30
    @State private var difficulty: Double = 3
    @State private var imageData: Data?
    
    @State private var showingImageSourceOptions = false
    @State private var showingImagePicker = false
    @State private var imagePickerSourceType: UIImagePickerController.SourceType = .camera
    
    private var recipeToEdit: Recipe?
    private var isEditing: Bool { recipeToEdit != nil }

    let categories = [
        "Breakfast", "Lunch", "Dinner",
        "Dessert", "Snack", "Vegan",
        "Vegetarian", "Non Vegetarian", "Healthy"
    ]
    
    init(recipeToEdit: Recipe? = nil) {
        self.recipeToEdit = recipeToEdit
        if let recipe = recipeToEdit {
            _name = State(initialValue: recipe.name ?? "")
            _category = State(initialValue: recipe.category ?? "Breakfast")
            _ingredients = State(initialValue: recipe.ingredients ?? "")
            _instructions = State(initialValue: recipe.instructions ?? "")
            _cookingTime = State(initialValue: recipe.cookingTime)
            _difficulty = State(initialValue: recipe.difficulty)
            _imageData = State(initialValue: recipe.imageData)
        }
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Recipe Details")) {
                    TextField("Recipe Name", text: $name)
                    Picker("Category", selection: $category) {
                        ForEach(categories, id: \.self) { Text($0) }
                    }
                }
                
                Section(header: Text("Photo")) {
                    Button {
                        showingImageSourceOptions = true
                    } label: {
                        HStack {
                            if let data = imageData, let uiImage = UIImage(data: data) {
                                Image(uiImage: uiImage).resizable().scaledToFit().frame(width: 50, height: 50).cornerRadius(8)
                            } else {
                                Image(systemName: "photo.badge.plus").font(.title)
                            }
                            Text("Select a photo")
                        }
                    }
                }

                Section(header: Text("Ingredients")) { TextEditor(text: $ingredients).frame(height: 150) }
                Section(header: Text("Instructions")) { TextEditor(text: $instructions).frame(height: 200) }
                
                Section(header: Text("Timings & Difficulty")) {
                    Stepper("Cooking Time: \(Int(cookingTime)) minutes", value: $cookingTime, in: 5...240, step: 5)
                    VStack {
                        Text("Difficulty: \(Int(difficulty))/5")
                        Slider(value: $difficulty, in: 1...5, step: 1)
                    }
                }
            }
            .navigationTitle(isEditing ? "Edit Recipe" : "New Recipe")
            .navigationBarItems(
                leading: Button("Cancel") { dismiss() },
                trailing: Button("Save") { saveRecipe() }.disabled(name.isEmpty)
            )
            .actionSheet(isPresented: $showingImageSourceOptions) {
                ActionSheet(title: Text("Choose Image Source"), buttons: [
                    .default(Text("Take Photo")) {
                        self.imagePickerSourceType = .camera
                        self.showingImagePicker = true
                    },
                    .default(Text("Choose from Library")) {
                        self.imagePickerSourceType = .photoLibrary
                        self.showingImagePicker = true
                    },
                    .cancel()
                ])
            }
            .sheet(isPresented: $showingImagePicker) {
                ImagePicker(sourceType: imagePickerSourceType, imageData: $imageData)
            }
        }
    }

    private func saveRecipe() {
        withAnimation {
            let recipe = recipeToEdit ?? Recipe(context: viewContext)
            
            if !isEditing {
                recipe.id = UUID()
                recipe.createdAt = Date()
            }
            
            recipe.name = name
            recipe.category = category
            recipe.ingredients = ingredients
            recipe.instructions = instructions
            recipe.cookingTime = cookingTime
            recipe.difficulty = difficulty
            recipe.imageData = imageData

            do {
                try viewContext.save()
                WidgetCenter.shared.reloadTimelines(ofKind: "RecipeWidget")
                dismiss()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}
