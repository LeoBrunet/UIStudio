import SwiftUI

struct PantryRecipeScreen: StudioScreen {
    static let info = ScreenInfo("Recipe", project: Pantry.project, flow: "Browse", order: 200,
                                 notes: "Recipe detail: photo, servings, ingredients and the start button.")

    @State private var servings = 2

    var body: some View {
        ZStack(alignment: .bottom) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    Slot("Header") {
                        Variant("Full-bleed photo") { photoHeader }
                        Variant("Compact") { compactHeader }
                    }
                    stats
                    servingsStepper
                    Slot("Ingredients") {
                        Variant("Checklist") { checklist }
                        Variant("Two columns") { twoColumns }
                    }
                }
                .padding(.bottom, 100)
            }
            startButton
        }
        .background(Pantry.cream)
    }

    private let recipe = Pantry.recipes[0]

    private var photoHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            PantryPhoto(recipe: recipe, symbolSize: 90)
                .frame(height: 280)
                .overlay(alignment: .topTrailing) {
                    Image(systemName: "bookmark.fill")
                        .foregroundStyle(Pantry.green)
                        .frame(width: 40, height: 40)
                        .background(.white, in: Circle())
                        .padding(16)
                        .padding(.top, 40)
                }
            Text(recipe.title).font(.system(.largeTitle, design: .serif, weight: .bold)).padding(.horizontal, 20)
        }
        .studioComponent("Photo header")
    }

    private var compactHeader: some View {
        HStack(spacing: 14) {
            PantryPhoto(recipe: recipe, symbolSize: 34)
                .frame(width: 96, height: 96)
                .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            VStack(alignment: .leading, spacing: 6) {
                Text(recipe.tag.uppercased()).font(.caption2.weight(.bold)).foregroundStyle(Pantry.green)
                Text(recipe.title).font(.system(.title2, design: .serif, weight: .bold))
            }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
        .studioComponent("Compact header")
    }

    private var stats: some View {
        HStack(spacing: 0) {
            stat("\(recipe.minutes) min", "Total")
            Divider().frame(height: 30)
            stat("\(recipe.kcal)", "kcal")
            Divider().frame(height: 30)
            stat("Easy", "Level")
        }
        .padding(.vertical, 12)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 20)
        .studioComponent("Stats")
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.headline)
            Text(label).font(.caption).foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    private var servingsStepper: some View {
        HStack {
            Text("Ingredients").font(.title3.weight(.bold))
            Spacer()
            HStack(spacing: 14) {
                Image(systemName: "minus")
                Text("\(servings) servings").font(.subheadline.weight(.semibold))
                Image(systemName: "plus")
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(.white, in: Capsule())
        }
        .padding(.horizontal, 20)
        .studioComponent("Servings")
    }

    private var checklist: some View {
        VStack(spacing: 0) {
            ForEach(Array(Pantry.ingredients.enumerated()), id: \.offset) { index, item in
                HStack {
                    Image(systemName: index < 2 ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(index < 2 ? Pantry.green : .secondary)
                    Text(item.0).strikethrough(index < 2).foregroundStyle(index < 2 ? .secondary : .primary)
                    Spacer()
                    Text(item.1).foregroundStyle(.secondary)
                }
                .font(.subheadline)
                .padding(.vertical, 11)
                if index < Pantry.ingredients.count - 1 { Divider() }
            }
        }
        .padding(.horizontal, 16)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .padding(.horizontal, 20)
        .studioComponent("Ingredient checklist")
    }

    private var twoColumns: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 10) {
            ForEach(Array(Pantry.ingredients.enumerated()), id: \.offset) { _, item in
                VStack(alignment: .leading, spacing: 2) {
                    Text(item.1).font(.headline).foregroundStyle(Pantry.green)
                    Text(item.0).font(.caption).foregroundStyle(.secondary).lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(12)
                .background(.white, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            }
        }
        .padding(.horizontal, 20)
        .studioComponent("Ingredient grid")
    }

    private var startButton: some View {
        Label("Start cooking", systemImage: "play.fill")
            .font(.headline)
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(Pantry.green, in: Capsule())
            .padding(.horizontal, 20)
            .padding(.bottom, 12)
            .studioComponent("Start button")
    }
}
