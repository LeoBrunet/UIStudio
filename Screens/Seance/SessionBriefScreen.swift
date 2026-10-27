import SwiftUI

struct SessionBriefScreen: StudioScreen {
    static let info = ScreenInfo(
        "Séance · avant",
        flow: "Séance",
        order: 700,
        notes: "Briefing : structure de la séance, consignes à retenir, envoi sur l'Apple Watch."
    )

    @State private var feeling = 4

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.l) {
                    header

                    Slot("Structure") {
                        Variant("Graphique") { structureChart }
                        Variant("Étapes") { structureSteps }
                    }

                    Slot("À retenir") {
                        Variant("Consignes") { keyCues }
                        Variant("Chiffres + consignes") { keyNumbers }
                        Variant("Fiche mémo") { memoCard }
                        Variant("Tuiles + pourquoi (v1)") { tilesAndWhy }
                    }

                    Slot("Avant de partir") {
                        Variant.hidden
                        Variant("Check-in ressenti") { checkIn }
                        Variant("Bouton coach") {
                            CoachButton(title: "Poser une question au coach", kind: .secondary, showsHint: true)
                        }
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
            Label(Mock.todaySport.label, systemImage: Mock.todaySport.icon)
                .font(.dsCaption.weight(.semibold))
                .foregroundStyle(Mock.todaySport.color)
            Text(Mock.todayTitle).font(.dsDisplay)
            Text("Mardi 20 oct. · \(Fmt.duration(Mock.todayMinutes)) · Charge élevée")
                .font(.dsCallout)
                .foregroundStyle(.dsTextSecondary)
        }
        .padding(.top, DS.Spacing.s)
    }

    private var structureChart: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            HStack(alignment: .bottom, spacing: DS.Spacing.xs) {
                VStack(alignment: .trailing) {
                    ForEach((1...5).reversed(), id: \.self) { zone in
                        Text("Z\(zone)").font(.system(size: 9, weight: .medium)).foregroundStyle(.dsTextSecondary)
                        if zone > 1 { Spacer(minLength: 0) }
                    }
                }
                .frame(height: 110)
                IntensityBar(segments: Mock.segments)
                    .frame(height: 110)
            }
            HStack {
                Text("0'")
                Spacer()
                Text("15'")
                Spacer()
                Text("45'")
                Spacer()
                Text("\(Mock.todayMinutes)'")
            }
            .font(.dsCaption)
            .foregroundStyle(.dsTextSecondary)
            .padding(.leading, 22)
        }
        .dsCard()
    }

    // MARK: - À retenir

    private struct Cue: Identifiable {
        let id = UUID()
        let icon: String
        let color: Color
        let title: String
        let detail: String
    }

    private var cues: [Cue] {
        [
            Cue(icon: "speedometer", color: .dsZone(4), title: "\(Fmt.pace(Mock.targetPaceSeconds)) /km sur chaque 800 m", detail: "Ni plus vite, ni plus lent"),
            Cue(icon: "heart.fill", color: .pink, title: "FC entre 165 et 172 bpm", detail: "Au-dessus de 175 : ralentis"),
            Cue(icon: "figure.run", color: .dsZone(2), title: "Récup : 2 min en trottinant", detail: "Ne t'arrête pas entre les répétitions"),
            Cue(icon: "flag.checkered", color: .dsAccent, title: "Finis aussi vite que tu as commencé", detail: "Garde de la marge sur les 2 premières"),
        ]
    }

    private var keyCues: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            Text("À retenir").font(.dsTitle)
            ForEach(cues) { cue in
                HStack(spacing: DS.Spacing.s) {
                    Image(systemName: cue.icon)
                        .font(.callout.weight(.semibold))
                        .foregroundStyle(cue.color)
                        .frame(width: 40, height: 40)
                        .background(cue.color.opacity(0.14), in: Circle())
                    VStack(alignment: .leading, spacing: 2) {
                        Text(cue.title).font(.dsHeadline)
                        Text(cue.detail).font(.dsCallout).foregroundStyle(.dsTextSecondary)
                    }
                }
            }
        }
    }

    private var keyNumbers: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.m) {
            Text("À retenir").font(.dsTitle)
            HStack(spacing: DS.Spacing.xs) {
                bigNumber(Fmt.pace(Mock.targetPaceSeconds), "/km", "allure", .dsZone(4))
                bigNumber("165–172", "bpm", "FC cible", .pink)
                bigNumber("2'", "trot", "récup", .dsZone(2))
            }
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                bullet("Ne t'arrête pas pendant les récups")
                bullet("Finis aussi vite que tu as commencé")
            }
        }
    }

    private func bigNumber(_ value: String, _ unit: String, _ label: String, _ color: Color) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label.uppercased()).font(.system(size: 10, weight: .semibold)).foregroundStyle(color)
            Text(value).font(.system(.title2, design: .rounded, weight: .heavy)).minimumScaleFactor(0.7).lineLimit(1)
            Text(unit).font(.dsCaption).foregroundStyle(.dsTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Spacing.s)
        .background(color.opacity(0.1), in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
    }

    private func bullet(_ text: String) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: DS.Spacing.xs) {
            Image(systemName: "checkmark").font(.caption.weight(.bold)).foregroundStyle(.dsAccent)
            Text(text).font(.dsBody)
        }
    }

    private var memoCard: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            Text("À RETENIR").font(.dsCaption.weight(.bold)).foregroundStyle(.white.opacity(0.6))
            Text("6 × 800 m\n@ \(Fmt.pace(Mock.targetPaceSeconds)) /km")
                .font(.system(size: 36, weight: .heavy, design: .rounded))
            Divider().overlay(.white.opacity(0.3))
            Label("Récup 2 min en trottinant", systemImage: "arrow.triangle.2.circlepath")
            Label("FC max 175 bpm", systemImage: "heart.fill")
            Label("Pars prudent, finis fort", systemImage: "flag.checkered")
        }
        .font(.dsHeadline)
        .foregroundStyle(.white)
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Spacing.l)
        .background(Color(red: 0.1, green: 0.1, blue: 0.13), in: RoundedRectangle(cornerRadius: DS.Radius.l, style: .continuous))
    }

    // MARK: - Earlier versions (kept as variants)

    private var tilesAndWhy: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.l) {
            HStack(spacing: DS.Spacing.xs) {
                DSMetricTile(label: "Allure cible", value: Fmt.pace(Mock.targetPaceSeconds), unit: "/km")
                DSMetricTile(label: "FC cible", value: "165–172", unit: "bpm")
                DSMetricTile(label: "Distance", value: "~10", unit: "km")
            }
            .fixedSize(horizontal: false, vertical: true)
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Label("Pourquoi cette séance", systemImage: "sparkles")
                    .font(.dsHeadline)
                    .foregroundStyle(.dsAccent)
                Text("Les 800 m à allure VMA développent ta vitesse de base. C'est la séance clé de la semaine pour viser 1 h 45 sur semi.")
                    .font(.dsBody)
            }
            .dsCard()
        }
    }

    private var structureSteps: some View {
        VStack(spacing: 0) {
            ForEach(Array(Mock.steps.enumerated()), id: \.element.id) { index, step in
                HStack(alignment: .top, spacing: DS.Spacing.s) {
                    VStack(spacing: 0) {
                        Text("\(index + 1)")
                            .font(.system(.caption, design: .rounded, weight: .bold))
                            .foregroundStyle(.white)
                            .frame(width: 26, height: 26)
                            .background(Color.dsZone(step.zone), in: Circle())
                        if index < Mock.steps.count - 1 {
                            Rectangle().fill(Color.dsBorder).frame(width: 2).frame(maxHeight: .infinity)
                        }
                    }
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(step.name).font(.dsHeadline)
                            Spacer()
                            Text("\(Int(step.minutes)) min").font(.dsCallout).foregroundStyle(.dsTextSecondary)
                        }
                        Text(step.detail).font(.dsCallout).foregroundStyle(.dsTextSecondary)
                    }
                    .padding(.bottom, DS.Spacing.m)
                }
            }
        }
        .dsCard()
    }

    private var checkIn: some View {
        let labels = ["Épuisé", "Fatigué", "Correct", "Bien", "Au top"]
        return VStack(alignment: .leading, spacing: DS.Spacing.s) {
            Text("Comment tu te sens ?").font(.dsHeadline)
            HStack(spacing: DS.Spacing.xs) {
                ForEach(1...5, id: \.self) { value in
                    let isOn = value == feeling
                    Button { feeling = value } label: {
                        VStack(spacing: 4) {
                            Text("\(value)").font(.system(.title3, design: .rounded, weight: .bold))
                            Text(labels[value - 1]).font(.system(size: 10, weight: .medium)).lineLimit(1)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, DS.Spacing.s)
                        .foregroundStyle(isOn ? .white : .dsTextPrimary)
                        .background(isOn ? Color.dsAccent : Color.dsSurface, in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
                    }
                    .buttonStyle(.plain)
                }
            }
            Text("Ton ressenti est partagé avec le coach, qui peut ajuster la séance.")
                .font(.dsCaption)
                .foregroundStyle(.dsTextSecondary)
            CoachButton(title: "Poser une question au coach", kind: .secondary)
        }
    }
}
