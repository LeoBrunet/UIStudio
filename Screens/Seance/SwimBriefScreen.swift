import SwiftUI

struct SwimBriefScreen: StudioScreen {
    static let info = ScreenInfo(
        "Séance natation · avant",
        flow: "Séance",
        order: 900,
        notes: "Séance en séries de distances (bassin 25 m) : structure, consignes, envoi sur l'Apple Watch."
    )

    private var totalMeters: Int { Mock.swimSets.reduce(0) { $0 + $1.meters } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.l) {
                    header

                    Slot("Structure") {
                        Variant("Séries") { setsList }
                        Variant("Graphique") { setsChart }
                        Variant("Tableau de bord") { setsBoard }
                    }

                    Slot("À retenir") {
                        Variant("Consignes") { cues }
                        Variant("Fiche mémo") { memo }
                        Variant.hidden
                    }
                }
                .padding(.horizontal, DS.Spacing.m)
                .padding(.bottom, DS.Spacing.l)
            }
            .safeAreaInset(edge: .bottom) {
                Button {} label: {
                    Label("Envoyer sur l'Apple Watch", systemImage: "applewatch")
                }
                .buttonStyle(.dsPrimary)
                .padding(.horizontal, DS.Spacing.m)
                .padding(.vertical, DS.Spacing.s)
                .background(.bar)
                .studioComponent("Envoi Apple Watch")
            }
            .navigationTitle("Séance")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {} label: { Image(systemName: "chevron.left") }
                }
            }
        }
        .tint(.dsAccent)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Label(Sport.natation.label, systemImage: Sport.natation.icon)
                .font(.dsCaption.weight(.semibold))
                .foregroundStyle(Sport.natation.color)
            Text("Technique crawl").font(.dsDisplay)
            Text("Samedi 24 oct. · 45 min · \(totalMeters.formatted()) m · bassin 25 m")
                .font(.dsCallout)
                .foregroundStyle(.dsTextSecondary)
        }
        .padding(.top, DS.Spacing.s)
        .studioComponent("En-tête séance")
    }

    // MARK: Structure

    private var setsList: some View {
        VStack(spacing: 0) {
            ForEach(Array(Mock.swimSets.enumerated()), id: \.element.id) { index, set in
                HStack(spacing: DS.Spacing.s) {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.dsZone(set.zone))
                        .frame(width: 4, height: 40)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(set.name).font(.dsHeadline)
                        Text(set.detail).font(.dsCallout).foregroundStyle(.dsTextSecondary)
                    }
                    Spacer()
                    Text("\(set.meters) m").font(.system(.callout, design: .rounded, weight: .semibold))
                }
                .padding(.vertical, DS.Spacing.xs)
                .studioComponent("Série · \(set.name)")
                if index < Mock.swimSets.count - 1 { Divider().padding(.leading, 16) }
            }
        }
        .dsCard(padding: DS.Spacing.s)
    }

    private var setsChart: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            IntensityBar(segments: Mock.swimSets.map { (Double($0.meters), $0.zone) })
                .frame(height: 90)
            HStack {
                Text("0 m")
                Spacer()
                Text("\(totalMeters / 2) m")
                Spacer()
                Text("\(totalMeters) m")
            }
            .font(.dsCaption)
            .foregroundStyle(.dsTextSecondary)
            Text("Corps de séance : 8 × 100 m à 1:55 /100 m, récup 15 s")
                .font(.dsCallout.weight(.semibold))
        }
        .dsCard()
    }

    private var setsBoard: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DS.Spacing.xs) {
            ForEach(Mock.swimSets) { set in
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(set.meters) m")
                        .font(.system(.title3, design: .rounded, weight: .heavy))
                        .foregroundStyle(Color.dsZone(set.zone))
                    Text(set.name).font(.dsCallout.weight(.semibold)).lineLimit(1)
                    Text(set.detail).font(.dsCaption).foregroundStyle(.dsTextSecondary).lineLimit(2)
                }
                .frame(maxWidth: .infinity, minHeight: 92, alignment: .topLeading)
                .padding(DS.Spacing.s)
                .background(Color.dsZone(set.zone).opacity(0.1), in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
                .studioComponent("Série · \(set.name)")
            }
        }
    }

    // MARK: À retenir

    private var cues: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            Text("À retenir").font(.dsTitle)
            cue("timer", .dsZone(3), "100 m en 1:55", "Départ toutes les 2:10")
            cue("wind", .dsZone(2), "Respire tous les 3 temps", "Alterne les côtés pour rester droit")
            cue("arrow.left.and.right", .dsAccent, "Allonge le bras devant", "Regarde le fond, pas devant toi")
        }
        .studioComponent("Consignes")
    }

    private func cue(_ icon: String, _ color: Color, _ title: String, _ detail: String) -> some View {
        HStack(spacing: DS.Spacing.s) {
            Image(systemName: icon)
                .font(.callout.weight(.semibold))
                .foregroundStyle(color)
                .frame(width: 40, height: 40)
                .background(color.opacity(0.14), in: Circle())
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.dsHeadline)
                Text(detail).font(.dsCallout).foregroundStyle(.dsTextSecondary)
            }
        }
        .studioComponent("Consigne · \(title)")
    }

    private var memo: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            Text("À RETENIR").font(.dsCaption.weight(.bold)).foregroundStyle(.white.opacity(0.6))
            Text("8 × 100 m\n@ 1:55").font(.system(size: 36, weight: .heavy, design: .rounded))
            Divider().overlay(.white.opacity(0.3))
            Label("Départ toutes les 2:10", systemImage: "timer")
            Label("Respiration 3 temps", systemImage: "wind")
            Label("Bras long, regard au fond", systemImage: "arrow.left.and.right")
        }
        .font(.dsHeadline)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Spacing.l)
        .background(Color(red: 0.03, green: 0.2, blue: 0.27), in: RoundedRectangle(cornerRadius: DS.Radius.l, style: .continuous))
        .studioComponent("Fiche mémo")
    }
}
