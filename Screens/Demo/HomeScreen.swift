import SwiftUI

struct HomeScreen: StudioScreen {
    static let info = ScreenInfo("Home", flow: "Démo", order: 1200, notes: "Daily overview with highlights and a feed.")

    private struct Item: Identifiable {
        let id = UUID()
        let title: String
        let subtitle: String
        let icon: String
        let color: Color
    }

    private let highlights = [
        Item(title: "Morning focus", subtitle: "25 min · Deep work", icon: "sun.max.fill", color: .orange),
        Item(title: "Read later", subtitle: "4 articles", icon: "book.fill", color: .teal),
        Item(title: "Workout", subtitle: "Legs · 45 min", icon: "figure.run", color: .pink),
    ]

    private let feed = [
        Item(title: "Design review", subtitle: "Today, 10:00 · Studio B", icon: "paintpalette.fill", color: .purple),
        Item(title: "Lunch with Sam", subtitle: "Today, 12:30 · Café Lune", icon: "fork.knife", color: .orange),
        Item(title: "Ship v1.2", subtitle: "Tomorrow · 3 tasks left", icon: "shippingbox.fill", color: .blue),
        Item(title: "Call Mom", subtitle: "Thursday", icon: "phone.fill", color: .green),
    ]

    var body: some View {
        TabView {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: DS.Spacing.l) {
                        Slot("Highlights") {
                            Variant("Carousel") { carousel }
                            Variant("Grid") { grid }
                            Variant.hidden
                        }
                        Slot("Feed") {
                            Variant("Cards") { feedCards }
                            Variant("Compact list") { feedList }
                        }
                    }
                    .padding(.horizontal, DS.Spacing.m)
                }
                .navigationTitle("Today")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        DSAvatar(initials: "LB", size: 32)
                    }
                }
            }
            .tabItem { Label("Today", systemImage: "sun.max") }

            Text("Search").tabItem { Label("Search", systemImage: "magnifyingglass") }
            Text("Profile").tabItem { Label("Profile", systemImage: "person.crop.circle") }
        }
        .tint(.dsAccent)
    }

    private var carousel: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            DSSectionHeader(title: "Highlights", action: "See all")
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.s) {
                    ForEach(highlights) { item in
                        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                            Image(systemName: item.icon).font(.title2)
                            Spacer()
                            Text(item.title).font(.dsHeadline)
                            Text(item.subtitle).font(.dsCaption).opacity(0.85)
                        }
                        .foregroundStyle(.white)
                        .padding(DS.Spacing.m)
                        .frame(width: 180, height: 150, alignment: .leading)
                        .background(item.color.gradient, in: RoundedRectangle(cornerRadius: DS.Radius.l, style: .continuous))
                    }
                }
            }
            .scrollClipDisabled()
        }
    }

    private var grid: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            DSSectionHeader(title: "Highlights")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DS.Spacing.s) {
                ForEach(highlights) { item in
                    HStack(spacing: DS.Spacing.s) {
                        Image(systemName: item.icon)
                            .foregroundStyle(item.color)
                            .frame(width: 32, height: 32)
                            .background(item.color.opacity(0.15), in: RoundedRectangle(cornerRadius: DS.Radius.s))
                        VStack(alignment: .leading) {
                            Text(item.title).font(.dsCallout.weight(.semibold)).lineLimit(1)
                            Text(item.subtitle).font(.dsCaption).foregroundStyle(.dsTextSecondary).lineLimit(1)
                        }
                        Spacer(minLength: 0)
                    }
                    .dsCard(padding: DS.Spacing.s)
                }
            }
        }
    }

    private var feedCards: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            DSSectionHeader(title: "Up next")
            ForEach(feed) { item in
                HStack(spacing: DS.Spacing.s) {
                    Image(systemName: item.icon)
                        .foregroundStyle(.white)
                        .frame(width: 44, height: 44)
                        .background(item.color.gradient, in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(item.title).font(.dsHeadline)
                        Text(item.subtitle).font(.dsCallout).foregroundStyle(.dsTextSecondary)
                    }
                    Spacer()
                    Image(systemName: "chevron.right").foregroundStyle(.dsTextSecondary)
                }
                .dsCard(padding: DS.Spacing.s)
            }
        }
    }

    private var feedList: some View {
        VStack(alignment: .leading, spacing: 0) {
            DSSectionHeader(title: "Up next").padding(.bottom, DS.Spacing.xs)
            ForEach(feed) { item in
                HStack(spacing: DS.Spacing.s) {
                    Circle().fill(item.color).frame(width: 8, height: 8)
                    Text(item.title).font(.dsBody)
                    Spacer()
                    Text(item.subtitle.components(separatedBy: " · ").first ?? "")
                        .font(.dsCallout)
                        .foregroundStyle(.dsTextSecondary)
                }
                .padding(.vertical, DS.Spacing.s)
                Divider()
            }
        }
    }
}
