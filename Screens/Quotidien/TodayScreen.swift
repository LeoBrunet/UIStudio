import SwiftUI

struct TodayScreen: StudioScreen {
    static let info = ScreenInfo(
        "Aujourd'hui",
        flow: "Quotidien",
        order: 300,
        notes: "Accueil : séance du jour, récupération (Apple Santé), accès au coach dans l'app Claude."
    )

    var body: some View {
        TabView {
            NavigationStack {
                ScrollView {
                    VStack(alignment: .leading, spacing: DS.Spacing.l) {
                        WeekStrip().studioComponent("Semaine")

                        Slot("Séance du jour") {
                            Variant("Carte héro") { HeroSessionCard().studioComponent("Carte séance (héro)") }
                            Variant("Profil d'intensité") { ProfileSessionCard().studioComponent("Carte séance (profil)") }
                            Variant("Compacte") { CompactSessionCard().studioComponent("Carte séance (compacte)") }
                        }

                        Slot("Récupération") {
                            Variant("Anneaux") { RecoveryRings().studioComponent("Récupération (anneaux)") }
                            Variant("Score unique") { RecoveryScore().studioComponent("Récupération (score)") }
                            Variant.hidden
                        }

                        Slot("Coach") {
                            Variant("Le mot du coach") { CoachNoteCard().studioComponent("Mot du coach") }
                            Variant("Questions rapides") { QuickQuestions().studioComponent("Questions rapides") }
                        }
                    }
                    .padding(.horizontal, DS.Spacing.m)
                    .padding(.bottom, DS.Spacing.l)
                }
                .navigationTitle("Aujourd'hui")
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        DSAvatar(initials: "LB", size: 32)
                    }
                }
            }
            .tabItem { Label("Aujourd'hui", systemImage: "sun.max") }

            Text("Programme").tabItem { Label("Programme", systemImage: "calendar") }
            Text("Progrès").tabItem { Label("Progrès", systemImage: "chart.line.uptrend.xyaxis") }
            Text("Profil").tabItem { Label("Profil", systemImage: "person.crop.circle") }
        }
        .tint(.dsAccent)
    }
}

// MARK: - Week strip

private struct WeekStrip: View {
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Mock.week) { day in
                VStack(spacing: 6) {
                    Text(day.weekday.prefix(1))
                        .font(.dsCaption)
                        .foregroundStyle(.dsTextSecondary)
                    Text("\(day.date)")
                        .font(.system(.callout, design: .rounded, weight: .semibold))
                        .foregroundStyle(day.isToday ? .white : .dsTextPrimary)
                        .frame(width: 34, height: 34)
                        .background(day.isToday ? Color.dsAccent : .clear, in: Circle())
                    Group {
                        if day.done {
                            Image(systemName: "checkmark.circle.fill").foregroundStyle(.green)
                        } else {
                            Image(systemName: day.sport.icon).foregroundStyle(day.sport.color)
                        }
                    }
                    .font(.caption)
                    .frame(height: 14)
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Today's session variants

private struct HeroSessionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            HStack {
                Label(Mock.todaySport.label, systemImage: Mock.todaySport.icon)
                    .font(.dsCaption.weight(.semibold))
                    .padding(.horizontal, DS.Spacing.xs)
                    .padding(.vertical, DS.Spacing.xxs)
                    .background(.white.opacity(0.2), in: Capsule())
                Spacer()
                Text(Fmt.duration(Mock.todayMinutes)).font(.dsCallout.weight(.semibold))
            }
            Text(Mock.todayTitle).font(.dsTitle)
            Text(Mock.todaySubtitle).font(.dsCallout).opacity(0.85)
            IntensityBar(segments: Mock.segments, monochrome: true)
                .frame(height: 40)
                .padding(.vertical, DS.Spacing.xs)
            HStack {
                heroMetric("Allure", "\(Fmt.pace(Mock.targetPaceSeconds)) /km")
                heroMetric("Zone", "Z4")
                heroMetric("Charge", "Élevée")
            }
            Button("Voir la séance") {}
                .font(.dsHeadline)
                .frame(maxWidth: .infinity)
                .padding(.vertical, DS.Spacing.s)
                .foregroundStyle(Mock.todaySport.color)
                .background(.white, in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
                .padding(.top, DS.Spacing.xs)
        }
        .foregroundStyle(.white)
        .padding(DS.Spacing.m)
        .background(
            LinearGradient(colors: [Mock.todaySport.color, Mock.todaySport.color.opacity(0.75)], startPoint: .topLeading, endPoint: .bottomTrailing),
            in: RoundedRectangle(cornerRadius: DS.Radius.l, style: .continuous)
        )
    }

    private func heroMetric(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(label).font(.dsCaption).opacity(0.8)
            Text(value).font(.dsHeadline)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct ProfileSessionCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            HStack(spacing: DS.Spacing.s) {
                Image(systemName: Mock.todaySport.icon)
                    .font(.title3)
                    .foregroundStyle(.white)
                    .frame(width: 44, height: 44)
                    .background(Mock.todaySport.color.gradient, in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
                VStack(alignment: .leading, spacing: 2) {
                    Text("Séance du jour").font(.dsCaption).foregroundStyle(.dsTextSecondary)
                    Text(Mock.todayTitle).font(.dsHeadline)
                }
                Spacer()
                Text(Fmt.duration(Mock.todayMinutes)).font(.dsCallout).foregroundStyle(.dsTextSecondary)
            }
            IntensityBar(segments: Mock.segments)
                .frame(height: 56)
            HStack {
                ForEach(Mock.steps) { step in
                    HStack(spacing: 4) {
                        Circle().fill(Color.dsZone(step.zone)).frame(width: 7, height: 7)
                        Text(step.name).font(.dsCaption).foregroundStyle(.dsTextSecondary).lineLimit(1)
                    }
                    if step.id != Mock.steps.last?.id { Spacer(minLength: 4) }
                }
            }
            Button("Voir la séance") {}.buttonStyle(.dsPrimary)
        }
        .dsCard()
    }
}

private struct CompactSessionCard: View {
    var body: some View {
        HStack(spacing: DS.Spacing.s) {
            RoundedRectangle(cornerRadius: 3).fill(Mock.todaySport.color).frame(width: 5)
            VStack(alignment: .leading, spacing: 4) {
                Text("AUJOURD'HUI · \(Mock.todaySport.label.uppercased())")
                    .font(.dsCaption)
                    .foregroundStyle(Mock.todaySport.color)
                Text(Mock.todayTitle).font(.dsHeadline)
                Text("\(Fmt.duration(Mock.todayMinutes)) · \(Fmt.pace(Mock.targetPaceSeconds)) /km · Z4")
                    .font(.dsCallout)
                    .foregroundStyle(.dsTextSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right").foregroundStyle(.dsTextSecondary)
        }
        .frame(height: 76)
        .dsCard(padding: DS.Spacing.s)
    }
}

// MARK: - Recovery variants

private struct RecoveryRings: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            DSSectionHeader(title: "Récupération", action: "Détails")
            HStack(spacing: DS.Spacing.s) {
                ring("Sommeil", "7 h 42", 0.86, .indigo)
                ring("VFC", "68 ms", 0.78, .green)
                ring("FC repos", "48 bpm", 0.9, .pink)
            }
        }
    }

    private func ring(_ label: String, _ value: String, _ progress: Double, _ color: Color) -> some View {
        VStack(spacing: DS.Spacing.xs) {
            ZStack {
                DSRing(progress: progress, color: color, lineWidth: 7)
                Text(value)
                    .font(.system(.caption, design: .rounded, weight: .bold))
                    .multilineTextAlignment(.center)
            }
            .frame(width: 72, height: 72)
            Text(label).font(.dsCaption).foregroundStyle(.dsTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, DS.Spacing.s)
        .background(Color.dsSurface, in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
    }
}

private struct RecoveryScore: View {
    var body: some View {
        HStack(spacing: DS.Spacing.m) {
            ZStack {
                DSRing(progress: 0.78, color: .green, lineWidth: 9)
                VStack(spacing: 0) {
                    Text("78").font(.system(size: 26, weight: .bold, design: .rounded))
                    Text("/100").font(.dsCaption).foregroundStyle(.dsTextSecondary)
                }
            }
            .frame(width: 84, height: 84)
            VStack(alignment: .leading, spacing: 4) {
                Text("Forme : bonne").font(.dsHeadline)
                Text("VFC +8 % vs ta moyenne, sommeil 7 h 42. Tu peux pousser aujourd'hui.")
                    .font(.dsCallout)
                    .foregroundStyle(.dsTextSecondary)
            }
        }
        .dsCard()
    }
}

// MARK: - Coach variants

private struct CoachNoteCard: View {
    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            HStack {
                Label("Le mot du coach", systemImage: "sparkles")
                    .font(.dsHeadline)
                    .foregroundStyle(.dsAccent)
                Spacer()
                Text("07:02").font(.dsCaption).foregroundStyle(.dsTextSecondary)
            }
            Text(Mock.coachNote).font(.dsBody)
            CoachButton(title: "Une question avant de partir ?", kind: .secondary, showsHint: true)
        }
        .dsCard()
    }
}

private struct QuickQuestions: View {
    private let questions: [(String, String)] = [
        ("Je suis fatigué", "battery.25"),
        ("Douleur au mollet", "bandage"),
        ("Je n'ai que 30 min", "clock"),
        ("Décaler à demain", "calendar.badge.clock"),
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            Text("Une question avant de partir ?").font(.dsHeadline)
            Text("Le coach répond dans Claude et ajuste ta séance si besoin.")
                .font(.dsCallout)
                .foregroundStyle(.dsTextSecondary)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: DS.Spacing.xs) {
                    ForEach(questions, id: \.0) { DSChip(text: $0.0, icon: $0.1) }
                }
            }
            .scrollClipDisabled()
            CoachButton(title: "Parler au coach")
        }
    }
}
