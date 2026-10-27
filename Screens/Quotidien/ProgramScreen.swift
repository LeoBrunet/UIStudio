import SwiftUI

struct ProgramScreen: StudioScreen {
    static let info = ScreenInfo(
        "Programme",
        flow: "Quotidien",
        order: 400,
        notes: "Semaine en cours du programme créé et ajusté par Claude via le connecteur."
    )

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.l) {
                    Slot("Objectif") {
                        Variant("Bannière") { goalBanner }
                        Variant("Compte à rebours") { goalCountdown }
                    }

                    HStack {
                        Button {} label: { Image(systemName: "chevron.left") }
                        Spacer()
                        VStack(spacing: 2) {
                            Text("Semaine du 19 oct.").font(.dsHeadline)
                            Text("Bloc de développement").font(.dsCaption).foregroundStyle(.dsTextSecondary)
                        }
                        Spacer()
                        Button {} label: { Image(systemName: "chevron.right") }
                    }

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: DS.Spacing.xs) {
                            volumeChip(.course, "3 h 10")
                            volumeChip(.velo, "1 h 30")
                            volumeChip(.natation, "45 min")
                            volumeChip(.muscu, "45 min")
                        }
                    }
                    .scrollClipDisabled()

                    Slot("Vue semaine") {
                        Variant("Liste") { weekList }
                        Variant("Grille") { weekGrid }
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        Label("Programme créé par Claude · mis à jour hier à 21:14", systemImage: "sparkles")
                            .font(.dsCaption)
                            .foregroundStyle(.dsTextSecondary)
                        CoachButton(title: "Modifier avec le coach", kind: .secondary)
                    }
                }
                .padding(.horizontal, DS.Spacing.m)
                .padding(.bottom, DS.Spacing.l)
            }
            .navigationTitle("Programme")
        }
        .tint(.dsAccent)
    }

    private var goalBanner: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            HStack {
                Image(systemName: "flag.checkered")
                Text("Semi-marathon de Paris").font(.dsHeadline)
                Spacer()
                Text("8 mars").font(.dsCallout).opacity(0.85)
            }
            Text("Objectif : 1 h 45").font(.dsTitle)
            ProgressView(value: 3, total: 12)
                .tint(.white)
            Text("Semaine 3 sur 12").font(.dsCaption).opacity(0.85)
        }
        .foregroundStyle(.white)
        .padding(DS.Spacing.m)
        .background(
            LinearGradient(colors: [Color(red: 0.1, green: 0.1, blue: 0.14), Color(red: 0.24, green: 0.2, blue: 0.3)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: DS.Radius.l, style: .continuous)
        )
    }

    private var goalCountdown: some View {
        HStack(spacing: DS.Spacing.m) {
            VStack(spacing: 0) {
                Text("139").font(.system(size: 34, weight: .heavy, design: .rounded)).foregroundStyle(.dsAccent)
                Text("jours").font(.dsCaption).foregroundStyle(.dsTextSecondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Semi-marathon de Paris").font(.dsHeadline)
                Text("Objectif 1 h 45 · 8 mars").font(.dsCallout).foregroundStyle(.dsTextSecondary)
                ProgressView(value: 3, total: 12).tint(.dsAccent)
            }
        }
        .dsCard()
    }

    private func volumeChip(_ sport: Sport, _ value: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: sport.icon).foregroundStyle(sport.color)
            Text(value).font(.dsCallout.weight(.semibold))
        }
        .padding(.horizontal, DS.Spacing.s)
        .padding(.vertical, DS.Spacing.xs)
        .background(sport.color.opacity(0.12), in: Capsule())
    }

    private var weekList: some View {
        VStack(spacing: DS.Spacing.xs) {
            ForEach(Mock.week) { day in
                HStack(spacing: DS.Spacing.s) {
                    VStack(spacing: 0) {
                        Text(day.weekday).font(.dsCaption).foregroundStyle(.dsTextSecondary)
                        Text("\(day.date)").font(.system(.title3, design: .rounded, weight: .bold))
                    }
                    .frame(width: 40)
                    Image(systemName: day.sport.icon)
                        .foregroundStyle(day.sport == .repos ? Color.dsTextSecondary : .white)
                        .frame(width: 36, height: 36)
                        .background(day.sport == .repos ? Color.dsSurface : day.sport.color, in: RoundedRectangle(cornerRadius: DS.Radius.s, style: .continuous))
                    VStack(alignment: .leading, spacing: 2) {
                        Text(day.title).font(.dsHeadline)
                        if day.minutes > 0 {
                            Text("\(day.sport.label) · \(Fmt.duration(day.minutes))").font(.dsCallout).foregroundStyle(.dsTextSecondary)
                        }
                    }
                    Spacer()
                    if day.done {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                    } else if day.isToday {
                        DSTag(text: "Aujourd'hui")
                    }
                }
                .padding(DS.Spacing.s)
                .background(day.isToday ? Color.dsAccentSoft : Color.dsSurface, in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
            }
        }
    }

    private var weekGrid: some View {
        HStack(alignment: .top, spacing: 4) {
            ForEach(Mock.week) { day in
                VStack(spacing: DS.Spacing.xs) {
                    Text(day.weekday).font(.dsCaption).foregroundStyle(day.isToday ? .dsAccent : .dsTextSecondary)
                    Text("\(day.date)").font(.system(.callout, design: .rounded, weight: .bold))
                    VStack(spacing: 6) {
                        Image(systemName: day.sport.icon).font(.title3)
                        if day.minutes > 0 {
                            Text("\(day.minutes)'").font(.system(.caption, design: .rounded, weight: .semibold))
                        }
                        if day.done {
                            Image(systemName: "checkmark").font(.caption.weight(.bold))
                        }
                    }
                    .foregroundStyle(day.sport == .repos ? Color.dsTextSecondary : .white)
                    .frame(maxWidth: .infinity)
                    .frame(height: CGFloat(max(day.minutes, 30)) * 1.3)
                    .background(day.sport == .repos ? Color.dsSurface : day.sport.color, in: RoundedRectangle(cornerRadius: DS.Radius.s, style: .continuous))
                    .overlay {
                        if day.isToday {
                            RoundedRectangle(cornerRadius: DS.Radius.s, style: .continuous).stroke(Color.dsTextPrimary, lineWidth: 2)
                        }
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}
