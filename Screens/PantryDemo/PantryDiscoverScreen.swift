import SwiftUI

struct PantryDiscoverScreen: StudioScreen {
    static let info = ScreenInfo("Discover", project: Pantry.project, flow: "Browse", order: 100,
                                 notes: "Home of the recipe app: featured recipe, categories, quick ideas.")

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 22) {
                    header
                    Slot("Featured") {
                        Variant("Hero card") { hero }
                        Variant("Carousel") { carousel }
                    }
                    Slot("Categories") {
                        Variant("Chips") { chips }
                        Variant("Grid") { categoryGrid }
                        Variant.hidden
                    }
                    quickIdeas
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            PantryTabBar(selected: 0)
        }
        .background(Pantry.cream)
    }

    private var header: some View {
        HStack {
            VStack(alignment: .leading, spacing: 2) {
                Text("Good evening, Sam").font(.subheadline).foregroundStyle(.secondary)
                Text("What's for dinner?").font(.system(.title, design: .serif, weight: .bold))
            }
            Spacer()
            Image(systemName: "magnifyingglass")
                .font(.headline)
                .frame(width: 40, height: 40)
                .background(.white, in: Circle())
        }
        .padding(.top, 8)
        .studioComponent("Header")
    }

    private var hero: some View {
        let recipe = Pantry.recipes[0]
        return VStack(alignment: .leading, spacing: 0) {
            PantryPhoto(recipe: recipe, symbolSize: 70).frame(height: 190)
            VStack(alignment: .leading, spacing: 6) {
                Text("RECIPE OF THE DAY").font(.caption2.weight(.bold)).foregroundStyle(Pantry.green)
                Text(recipe.title).font(.system(.title3, design: .serif, weight: .bold))
                PantryMeta(recipe: recipe)
            }
            .padding(16)
        }
        .background(.white)
        .clipShape(RoundedRectangle(cornerRadius: 22, style: .continuous))
        .shadow(color: .black.opacity(0.06), radius: 12, y: 6)
        .studioComponent("Hero card")
    }

    private var carousel: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                ForEach(Pantry.recipes) { recipe in
                    VStack(alignment: .leading, spacing: 8) {
                        PantryPhoto(recipe: recipe, symbolSize: 40)
                            .frame(width: 200, height: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        Text(recipe.title).font(.headline).lineLimit(1)
                        PantryMeta(recipe: recipe)
                    }
                    .frame(width: 200)
                }
            }
        }
        .studioComponent("Carousel")
    }

    private let categories = [("Quick", "bolt.fill"), ("Veggie", "leaf.fill"), ("Baking", "birthday.cake.fill"), ("Soups", "cup.and.saucer.fill")]

    private var chips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(Array(categories.enumerated()), id: \.offset) { index, item in
                    Label(item.0, systemImage: item.1)
                        .font(.subheadline.weight(.semibold))
                        .padding(.horizontal, 14)
                        .padding(.vertical, 9)
                        .foregroundStyle(index == 0 ? .white : .primary)
                        .background(index == 0 ? Pantry.green : .white, in: Capsule())
                }
            }
        }
        .studioComponent("Category chips")
    }

    private var categoryGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(Array(categories.enumerated()), id: \.offset) { _, item in
                HStack {
                    Image(systemName: item.1).foregroundStyle(Pantry.green)
                    Text(item.0).font(.subheadline.weight(.semibold))
                    Spacer()
                }
                .padding(14)
                .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .studioComponent("Category grid")
    }

    private var quickIdeas: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Under 30 minutes").font(.headline)
                Spacer()
                Text("See all").font(.subheadline).foregroundStyle(Pantry.green)
            }
            ForEach(Pantry.recipes.filter { $0.minutes <= 30 }) { recipe in
                HStack(spacing: 12) {
                    PantryPhoto(recipe: recipe, symbolSize: 22)
                        .frame(width: 58, height: 58)
                        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                    VStack(alignment: .leading, spacing: 4) {
                        Text(recipe.title).font(.subheadline.weight(.semibold))
                        PantryMeta(recipe: recipe)
                    }
                    Spacer()
                    Image(systemName: "bookmark").foregroundStyle(.secondary)
                }
                .padding(10)
                .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
            }
        }
        .studioComponent("Quick ideas")
    }
}
