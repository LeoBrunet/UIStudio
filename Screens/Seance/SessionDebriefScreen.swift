import SwiftUI
import Charts

struct SessionDebriefScreen: StudioScreen {
    static let info = ScreenInfo(
        "Séance · bilan",
        flow: "Séance",
        order: 800,
        notes: "Après la séance : données Apple Watch, réalisé vs prévu, analyse écrite par Claude via le connecteur."
    )

    @State private var effort = 7

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.l) {
                    header

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.xs), count: 3), spacing: DS.Spacing.xs) {
                        DSMetricTile(label: "Distance", value: "10,4", unit: "km")
                        DSMetricTile(label: "Durée", value: "54:12")
                        DSMetricTile(label: "Allure moy.", value: "5:12", unit: "/km")
                        DSMetricTile(label: "FC moy.", value: "151", unit: "bpm")
                        DSMetricTile(label: "FC max", value: "178", unit: "bpm")
                        DSMetricTile(label: "Calories", value: "712", unit: "kcal")
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        DSSectionHeader(title: "Réalisé vs prévu")
                        Slot("Réalisé vs prévu") {
                            Variant("Graphique") { repsChart }
                            Variant("Tableau") { repsTable }
                        }
                    }

                    Slot("Analyse du coach") {
                        Variant("Texte") { coachText }
                        Variant("Points clés") { coachKeyPoints }
                    }

                    effortPicker

                    CoachButton(title: "Débriefer avec le coach", showsHint: true)
                }
                .padding(.horizontal, DS.Spacing.m)
                .padding(.bottom, DS.Spacing.l)
            }
            .navigationTitle("Bilan")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {} label: { Image(systemName: "square.and.arrow.up") }
                }
            }
        }
        .tint(.dsAccent)
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            Label("Séance terminée", systemImage: "checkmark.seal.fill")
                .font(.dsCaption.weight(.semibold))
                .foregroundStyle(.green)
            Text(Mock.todayTitle).font(.dsDisplay)
            Label("Mardi 20 oct. · 18:05 · Apple Watch", systemImage: "applewatch")
                .font(.dsCallout)
                .foregroundStyle(.dsTextSecondary)
        }
        .padding(.top, DS.Spacing.s)
    }

    private func isOnTarget(_ rep: Rep) -> Bool { abs(rep.paceSeconds - Mock.targetPaceSeconds) <= 3 }

    private var repsChart: some View {
        Chart {
            ForEach(Mock.reps) { rep in
                BarMark(
                    x: .value("Répétition", "R\(rep.index)"),
                    yStart: .value("Base", 236),
                    yEnd: .value("Allure", rep.paceSeconds),
                    width: .ratio(0.55)
                )
                .foregroundStyle(isOnTarget(rep) ? Color.green : Color.orange)
                .clipShape(RoundedRectangle(cornerRadius: 4))
            }
            RuleMark(y: .value("Cible", Mock.targetPaceSeconds))
                .foregroundStyle(Color.dsTextPrimary)
                .lineStyle(StrokeStyle(lineWidth: 1.5, dash: [4, 3]))
                .annotation(position: .top, alignment: .leading) {
                    Text("Cible \(Fmt.pace(Mock.targetPaceSeconds))").font(.dsCaption).foregroundStyle(.dsTextSecondary)
                }
        }
        .chartYScale(domain: 236...258)
        .chartYAxis {
            AxisMarks(position: .leading, values: [240, 245, 250, 255]) { value in
                AxisGridLine()
                AxisValueLabel { Text(Fmt.pace(value.as(Int.self) ?? 0)) }
            }
        }
        .frame(height: 170)
        .dsCard()
    }

    private var repsTable: some View {
        VStack(spacing: 0) {
            ForEach(Mock.reps) { rep in
                HStack {
                    Text("Répétition \(rep.index)").font(.dsBody)
                    Spacer()
                    Text("\(Fmt.pace(rep.paceSeconds)) /km").font(.dsBody.monospacedDigit())
                    Image(systemName: isOnTarget(rep) ? "checkmark.circle.fill" : "exclamationmark.circle.fill")
                        .foregroundStyle(isOnTarget(rep) ? .green : .orange)
                }
                .padding(.vertical, DS.Spacing.xs)
                if rep.index < Mock.reps.count { Divider() }
            }
        }
        .dsCard(padding: DS.Spacing.s)
    }

    private var coachText: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            Label("Analyse du coach", systemImage: "sparkles")
                .font(.dsHeadline)
                .foregroundStyle(.dsAccent)
            Text(Mock.coachDebrief).font(.dsBody)
            Text("Rédigé par Claude · 18:42")
                .font(.dsCaption)
                .foregroundStyle(.dsTextSecondary)
        }
        .dsCard()
    }

    private var coachKeyPoints: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            Label("Analyse du coach", systemImage: "sparkles")
                .font(.dsHeadline)
                .foregroundStyle(.dsAccent)
            keyPoint("checkmark.circle.fill", .green, "Allure tenue sur 5 répétitions sur 6")
            keyPoint("heart.circle.fill", .pink, "FC sous 130 bpm à chaque récup : l'aérobie progresse")
            keyPoint("exclamationmark.circle.fill", .orange, "Dernière répétition à 4:14 : fatigue de fin de séance")
            keyPoint("arrow.right.circle.fill", .dsAccent, "Jeudi : footing 40 min en Z2 strict")
        }
        .dsCard()
    }

    private func keyPoint(_ icon: String, _ color: Color, _ text: String) -> some View {
        HStack(alignment: .top, spacing: DS.Spacing.s) {
            Image(systemName: icon).foregroundStyle(color)
            Text(text).font(.dsBody)
        }
    }

    private var effortPicker: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            HStack {
                Text("Effort ressenti").font(.dsHeadline)
                Spacer()
                Text("\(effort)/10 · Difficile").font(.dsCallout).foregroundStyle(.dsTextSecondary)
            }
            HStack(spacing: 4) {
                ForEach(1...10, id: \.self) { value in
                    Button { effort = value } label: {
                        RoundedRectangle(cornerRadius: 4, style: .continuous)
                            .fill(value <= effort ? Color.dsZone((value + 1) / 2) : Color.dsSurface)
                            .frame(height: 28)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
}
