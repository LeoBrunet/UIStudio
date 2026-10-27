import SwiftUI

struct ProfileScreen: StudioScreen {
    static let info = ScreenInfo(
        "Profil",
        flow: "Quotidien",
        order: 600,
        notes: "Connexions (Santé, Watch, Claude), profil sportif et zones cardiaques utilisés par le coach."
    )

    private let zones: [(zone: Int, name: String, range: String, share: Double)] = [
        (1, "Récupération", "< 128 bpm", 0.64),
        (2, "Endurance", "128–148", 0.74),
        (3, "Tempo", "149–162", 0.82),
        (4, "Seuil", "163–175", 0.9),
        (5, "VMA", "> 175", 1.0),
    ]

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.l) {
                    Slot("En-tête") {
                        Variant("Centré") { headerCentered }
                        Variant("Compact") { headerCompact }
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        DSSectionHeader(title: "Connexions")
                        Slot("Connexions") {
                            Variant("Liste") { connectionsList }
                            Variant("Cartes") { connectionsCards }
                        }
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        DSSectionHeader(title: "Mon profil sportif", action: "Modifier")
                        VStack(spacing: 0) {
                            infoRow("flag.checkered", "Objectif", "Semi-marathon · 1 h 45 · 8 mars")
                            Divider()
                            infoRow("calendar", "Disponibilités", "5 séances / sem. · sortie longue le dimanche")
                            Divider()
                            infoRow("bandage", "Points d'attention", "Mollet gauche fragile")
                        }
                        .dsCard(padding: DS.Spacing.s)
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: DS.Spacing.xs) {
                                ForEach([Sport.course, .velo, .natation, .muscu], id: \.self) { sport in
                                    DSChip(text: sport.label, icon: sport.icon)
                                }
                            }
                        }
                        .scrollClipDisabled()
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        DSSectionHeader(title: "Zones cardiaques", action: "FC max 192")
                        Slot("Zones FC") {
                            Variant("Barres") { zonesBars }
                            Variant("Bande") { zonesBand }
                        }
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        CoachButton(title: "Mettre à jour avec le coach", kind: .secondary)
                        Text("Le coach adapte ton programme à ces informations.")
                            .font(.dsCaption)
                            .foregroundStyle(.dsTextSecondary)
                            .frame(maxWidth: .infinity)
                    }
                }
                .padding(.horizontal, DS.Spacing.m)
                .padding(.bottom, DS.Spacing.l)
            }
            .navigationTitle("Profil")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: { Image(systemName: "gearshape") }
                }
            }
        }
        .tint(.dsAccent)
    }

    // MARK: En-tête

    private var headerCentered: some View {
        VStack(spacing: DS.Spacing.xs) {
            DSAvatar(initials: "LB", size: 84)
            Text("Léo B.").font(.dsTitle)
            Text("Coureur · triathlète en herbe").font(.dsCallout).foregroundStyle(.dsTextSecondary)
            HStack(spacing: DS.Spacing.l) {
                stat("312 km", "ce mois")
                stat("48,6", "VO2max")
                stat("6", "semaines d'affilée")
            }
            .padding(.top, DS.Spacing.xs)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, DS.Spacing.s)
        .studioComponent("En-tête profil")
    }

    private var headerCompact: some View {
        HStack(spacing: DS.Spacing.s) {
            DSAvatar(initials: "LB", size: 56)
            VStack(alignment: .leading, spacing: 2) {
                Text("Léo B.").font(.dsTitle)
                Text("312 km ce mois · VO2max 48,6").font(.dsCallout).foregroundStyle(.dsTextSecondary)
            }
            Spacer()
        }
        .dsCard()
        .studioComponent("En-tête profil")
    }

    private func stat(_ value: String, _ label: String) -> some View {
        VStack(spacing: 2) {
            Text(value).font(.system(.headline, design: .rounded))
            Text(label).font(.dsCaption).foregroundStyle(.dsTextSecondary)
        }
    }

    // MARK: Connexions

    private struct Connection: Identifiable {
        let id = UUID()
        let name: String
        let detail: String
        let symbol: String?
        let color: Color
    }

    private var connections: [Connection] {
        [
            Connection(name: "Apple Santé", detail: "Séances, FC, sommeil, VFC", symbol: "heart.fill", color: .pink),
            Connection(name: "Apple Watch", detail: "Series 11 · synchronisée à 18:42", symbol: "applewatch", color: .black),
            Connection(name: "Claude", detail: "Connecteur actif · dernière lecture 07:02", symbol: nil, color: .claudeCream),
        ]
    }

    @ViewBuilder
    private func connectionIcon(_ connection: Connection, size: CGFloat) -> some View {
        if let symbol = connection.symbol {
            Image(systemName: symbol)
                .font(.system(size: size * 0.45, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: size, height: size)
                .background(connection.color.gradient, in: RoundedRectangle(cornerRadius: size * 0.25, style: .continuous))
        } else {
            ClaudeMark()
                .padding(size * 0.16)
                .frame(width: size, height: size)
                .background(connection.color, in: RoundedRectangle(cornerRadius: size * 0.25, style: .continuous))
        }
    }

    private var connectionsList: some View {
        VStack(spacing: 0) {
            ForEach(connections) { connection in
                HStack(spacing: DS.Spacing.s) {
                    connectionIcon(connection, size: 36)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(connection.name).font(.dsHeadline)
                        Text(connection.detail).font(.dsCaption).foregroundStyle(.dsTextSecondary)
                    }
                    Spacer()
                    Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                }
                .padding(.vertical, DS.Spacing.xs)
                .studioComponent("Connexion · \(connection.name)")
                if connection.id != connections.last?.id { Divider() }
            }
        }
        .dsCard(padding: DS.Spacing.s)
    }

    private var connectionsCards: some View {
        HStack(spacing: DS.Spacing.xs) {
            ForEach(connections) { connection in
                VStack(spacing: DS.Spacing.xs) {
                    connectionIcon(connection, size: 44)
                    Text(connection.name).font(.dsCallout.weight(.semibold))
                    Label("Connecté", systemImage: "checkmark.circle.fill")
                        .font(.dsCaption)
                        .foregroundStyle(.green)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.s)
                .background(Color.dsSurface, in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
                .studioComponent("Connexion · \(connection.name)")
            }
        }
    }

    private func infoRow(_ icon: String, _ title: String, _ value: String) -> some View {
        HStack(alignment: .top, spacing: DS.Spacing.s) {
            Image(systemName: icon).foregroundStyle(.dsAccent).frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.dsCaption).foregroundStyle(.dsTextSecondary)
                Text(value).font(.dsBody)
            }
            Spacer()
        }
        .padding(.vertical, DS.Spacing.xs)
        .studioComponent("Info · \(title)")
    }

    // MARK: Zones

    private var zonesBars: some View {
        VStack(spacing: DS.Spacing.xs) {
            ForEach(zones, id: \.zone) { zone in
                HStack(spacing: DS.Spacing.s) {
                    Text("Z\(zone.zone)")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 24)
                        .background(Color.dsZone(zone.zone), in: RoundedRectangle(cornerRadius: 6))
                    Text(zone.name).font(.dsCallout).frame(width: 96, alignment: .leading)
                    GeometryReader { geo in
                        Capsule().fill(Color.dsZone(zone.zone).opacity(0.25))
                            .overlay(alignment: .leading) {
                                Capsule().fill(Color.dsZone(zone.zone)).frame(width: geo.size.width * zone.share)
                            }
                    }
                    .frame(height: 6)
                    Text(zone.range).font(.dsCaption.monospacedDigit()).foregroundStyle(.dsTextSecondary)
                        .frame(width: 68, alignment: .trailing)
                }
                .studioComponent("Zone \(zone.zone)")
            }
        }
        .dsCard(padding: DS.Spacing.s)
    }

    private var zonesBand: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            HStack(spacing: 2) {
                ForEach(zones, id: \.zone) { zone in
                    VStack(spacing: 4) {
                        Rectangle().fill(Color.dsZone(zone.zone)).frame(height: 28)
                            .overlay(Text("Z\(zone.zone)").font(.caption.weight(.bold)).foregroundStyle(.white))
                        Text(zone.range).font(.system(size: 10, weight: .medium)).foregroundStyle(.dsTextSecondary)
                    }
                }
            }
            .clipShape(RoundedRectangle(cornerRadius: DS.Radius.s, style: .continuous))
            Text("Calculées depuis tes séances Apple Watch · mises à jour par le coach.")
                .font(.dsCaption)
                .foregroundStyle(.dsTextSecondary)
        }
        .studioComponent("Bande des zones")
    }
}
