import SwiftUI

struct PantryListScreen: StudioScreen {
    static let info = ScreenInfo("Shopping list", project: Pantry.project, flow: "Plan", order: 400,
                                 notes: "Ingredients of the week's recipes, merged into one list.")

    private let aisles: [(String, String, [(String, String, Bool)])] = [
        ("Produce", "leaf.fill", [("Avocado", "2", true), ("Cucumber", "1", false), ("Spring onions", "1 bunch", false), ("Lemons", "3", false)]),
        ("Fish & meat", "fish.fill", [("Salmon fillets", "4", false)]),
        ("Pantry", "takeoutbag.and.cup.and.straw.fill", [("White miso", "1 jar", true), ("Sushi rice", "500 g", false), ("Olive oil", "1 bottle", false)]),
    ]

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 18) {
                    HStack(alignment: .firstTextBaseline) {
                        Text("Shopping list").font(.system(.largeTitle, design: .serif, weight: .bold))
                        Spacer()
                        Image(systemName: "square.and.arrow.up").font(.headline).foregroundStyle(Pantry.green)
                    }
                    .padding(.top, 8)
                    summary
                    Slot("Grouping") {
                        Variant("By aisle") { byAisle }
                        Variant("Flat list") { flat }
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 20)
            }
            PantryTabBar(selected: 2)
        }
        .background(Pantry.cream)
    }

    private var summary: some View {
        HStack(spacing: 12) {
            Image(systemName: "cart.fill")
                .foregroundStyle(.white)
                .frame(width: 40, height: 40)
                .background(Pantry.green, in: RoundedRectangle(cornerRadius: 12, style: .continuous))
            VStack(alignment: .leading, spacing: 2) {
                Text("8 items for 3 recipes").font(.subheadline.weight(.semibold))
                Text("2 already in your kitchen").font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(12)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .studioComponent("Summary")
    }

    private var byAisle: some View {
        VStack(alignment: .leading, spacing: 16) {
            ForEach(aisles, id: \.0) { aisle in
                VStack(alignment: .leading, spacing: 8) {
                    Label(aisle.0, systemImage: aisle.1).font(.subheadline.weight(.bold)).foregroundStyle(Pantry.green)
                    VStack(spacing: 0) {
                        ForEach(Array(aisle.2.enumerated()), id: \.offset) { index, item in
                            row(item)
                            if index < aisle.2.count - 1 { Divider() }
                        }
                    }
                    .padding(.horizontal, 14)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
                }
            }
        }
        .studioComponent("Aisles")
    }

    private var flat: some View {
        VStack(spacing: 0) {
            let items = aisles.flatMap(\.2)
            ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                row(item)
                if index < items.count - 1 { Divider() }
            }
        }
        .padding(.horizontal, 14)
        .background(.white, in: RoundedRectangle(cornerRadius: 16, style: .continuous))
        .studioComponent("Flat list")
    }

    private func row(_ item: (String, String, Bool)) -> some View {
        HStack {
            Image(systemName: item.2 ? "checkmark.circle.fill" : "circle")
                .foregroundStyle(item.2 ? Pantry.green : .secondary)
            Text(item.0).strikethrough(item.2).foregroundStyle(item.2 ? .secondary : .primary)
            Spacer()
            Text(item.1).foregroundStyle(.secondary)
        }
        .font(.subheadline)
        .padding(.vertical, 11)
    }
}
