import SwiftUI

// Shared bits for the "Pantry" demo project (a recipe app used for screenshots and examples).

enum Pantry {
    static let project = "Pantry"
    static let green = Color(red: 0.16, green: 0.52, blue: 0.36)
    static let cream = Color(red: 0.98, green: 0.96, blue: 0.92)

    struct Recipe: Identifiable {
        let id = UUID()
        let title: String
        let minutes: Int
        let kcal: Int
        let symbol: String
        let colors: [Color]
        let tag: String
    }

    static let recipes: [Recipe] = [
        Recipe(title: "Miso salmon bowl", minutes: 25, kcal: 540, symbol: "fish.fill",
               colors: [Color(red: 0.98, green: 0.62, blue: 0.42), Color(red: 0.91, green: 0.36, blue: 0.29)], tag: "Quick"),
        Recipe(title: "Roasted carrot soup", minutes: 40, kcal: 310, symbol: "carrot.fill",
               colors: [Color(red: 1.0, green: 0.74, blue: 0.35), Color(red: 0.95, green: 0.5, blue: 0.2)], tag: "Veggie"),
        Recipe(title: "Lemon olive oil cake", minutes: 55, kcal: 420, symbol: "birthday.cake.fill",
               colors: [Color(red: 0.98, green: 0.88, blue: 0.45), Color(red: 0.93, green: 0.7, blue: 0.25)], tag: "Baking"),
        Recipe(title: "Green shakshuka", minutes: 30, kcal: 380, symbol: "frying.pan.fill",
               colors: [Color(red: 0.55, green: 0.78, blue: 0.45), Color(red: 0.25, green: 0.58, blue: 0.38)], tag: "Brunch"),
    ]

    static let ingredients: [(String, String)] = [
        ("Salmon fillets", "2"), ("White miso", "2 tbsp"), ("Sushi rice", "180 g"),
        ("Cucumber", "½"), ("Avocado", "1"), ("Sesame seeds", "1 tsp"), ("Spring onions", "2"),
    ]
}

/// Food "photo": a gradient with a large symbol, standing in for real images.
struct PantryPhoto: View {
    let recipe: Pantry.Recipe
    var symbolSize: CGFloat = 54

    var body: some View {
        LinearGradient(colors: recipe.colors, startPoint: .topLeading, endPoint: .bottomTrailing)
            .overlay {
                Image(systemName: recipe.symbol)
                    .font(.system(size: symbolSize, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .shadow(color: .black.opacity(0.15), radius: 8, y: 4)
            }
    }
}

struct PantryMeta: View {
    let recipe: Pantry.Recipe

    var body: some View {
        HStack(spacing: 10) {
            Label("\(recipe.minutes) min", systemImage: "clock")
            Label("\(recipe.kcal) kcal", systemImage: "flame")
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }
}

struct PantryTabBar: View {
    var selected = 0
    private let tabs = [("Discover", "sparkles"), ("Saved", "bookmark"), ("List", "cart"), ("Profile", "person")]

    var body: some View {
        HStack {
            ForEach(Array(tabs.enumerated()), id: \.offset) { index, tab in
                VStack(spacing: 3) {
                    Image(systemName: tab.1 + (index == selected ? ".fill" : "")).font(.system(size: 18))
                    Text(tab.0).font(.system(size: 10, weight: .medium))
                }
                .foregroundStyle(index == selected ? Pantry.green : .secondary)
                .frame(maxWidth: .infinity)
            }
        }
        .padding(.vertical, 10)
        .background(.bar)
        .studioComponent("Tab bar")
    }
}
