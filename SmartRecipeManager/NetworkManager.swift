import Foundation

class NetworkManager {
    static let shared = NetworkManager()
    private init() {}
    
    func fetchRandomRecipe() async throws -> APIRecipe {
        guard let url = URL(string: "https://www.themealdb.com/api/json/v1/1/random.php") else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        
        let decodedResponse = try JSONDecoder().decode(MealDBResponse.self, from: data)
        
        guard let recipe = decodedResponse.meals.first else {
            throw URLError(.cannotParseResponse)
        }
        
        return recipe
    }
}
