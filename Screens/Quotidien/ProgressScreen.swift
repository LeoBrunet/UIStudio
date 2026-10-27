import SwiftUI
import Charts

struct ProgressScreen: StudioScreen {
    static let info = ScreenInfo(
        "Progrès",
        flow: "Quotidien",
        order: 500,
        notes: "Évolution sur 12 semaines : projection vers l'objectif, volume par sport, forme, records (Apple Santé)."
    )

    @State private var period = 1

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.l) {
                    Picker("Période", selection: $period) {
                        Text("4 sem.").tag(0)
                        Text("12 sem.").tag(1)
                        Text("Année").tag(2)
                    }
                    .pickerStyle(.segmented)
                    .studioComponent("Période")

                    Slot("Objectif") {
                        Variant("Projection") { goalProjection }
                        Variant("Compte à rebours") { goalCountdown }
                        Variant.hidden
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        DSSectionHeader(title: "Volume d'entraînement", action: "11 h 20 / sem.")
                        Slot("Volume") {
                            Variant("Barres empilées") { volumeChart }
                            Variant("Par sport") { volumeBySport }
                        }
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        DSSectionHeader(title: "Forme")
                        Slot("Forme") {
                            Variant("VO2max") { vo2Chart }
                            Variant("Allure à 150 bpm") { paceChart }
                        }
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        DSSectionHeader(title: "Records", action: "Tout voir")
                        Slot("Records") {
                            Variant("Liste") { recordsList }
                            Variant("Cartes") { recordsCards }
                        }
                    }

                    CoachButton(title: "Analyser mes progrès avec le coach", kind: .secondary, showsHint: true)
                }
                .padding(.horizontal, DS.Spacing.m)
                .padding(.bottom, DS.Spacing.l)
            }
            .navigationTitle("Progrès")
        }
        .tint(.dsAccent)
    }

    // MARK: Objectif

    private var goalProjection: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            HStack {
                Label("Semi-marathon · 8 mars", systemImage: "flag.checkered").font(.dsHeadline)
                Spacer()
                DSTag(text: "En bonne voie", color: .green)
            }
            HStack(alignment: .firstTextBaseline, spacing: DS.Spacing.xs) {
                Text("1 h 47").font(.system(size: 34, weight: .heavy, design: .rounded))
                Text("estimé · objectif 1 h 45").font(.dsCallout).foregroundStyle(.dsTextSecondary)
            }
            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    Capsule().fill(Color.dsSurface)
                    Capsule().fill(Color.dsAccent.gradient).frame(width: geo.size.width * 0.75)
                    Circle().fill(.white).frame(width: 14, height: 14)
                        .overlay(Circle().stroke(Color.dsAccent, lineWidth: 3))
                        .offset(x: geo.size.width * 0.75 - 7)
                }
            }
            .frame(height: 10)
            HStack {
                Text("Début : 1 h 53").font(.dsCaption).foregroundStyle(.dsTextSecondary)
                Spacer()
                Text("Encore ~2 min à gagner").font(.dsCaption).foregroundStyle(.dsTextSecondary)
            }
        }
        .dsCard()
        .studioComponent("Projection objectif")
    }

    private var goalCountdown: some View {
        HStack(spacing: DS.Spacing.m) {
            VStack(spacing: 0) {
                Text("139").font(.system(size: 34, weight: .heavy, design: .rounded)).foregroundStyle(.dsAccent)
                Text("jours").font(.dsCaption).foregroundStyle(.dsTextSecondary)
            }
            VStack(alignment: .leading, spacing: 4) {
                Text("Semi-marathon de Paris").font(.dsHeadline)
                Text("Estimé 1 h 47 · objectif 1 h 45").font(.dsCallout).foregroundStyle(.dsTextSecondary)
                ProgressView(value: 0.75).tint(.dsAccent)
            }
        }
        .dsCard()
        .studioComponent("Compte à rebours")
    }

    // MARK: Volume

    private var volumeChart: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            Chart(Mock.volumes) { item in
                BarMark(
                    x: .value("Semaine", "S\(item.week)"),
                    y: .value("Heures", item.hours),
                    width: .ratio(0.6)
                )
                .foregroundStyle(by: .value("Sport", item.sport.label))
                .clipShape(RoundedRectangle(cornerRadius: 2))
            }
            .chartForegroundStyleScale(
                domain: [Sport.course, .velo, .natation, .muscu].map(\.label),
                range: [Sport.course, .velo, .natation, .muscu].map(\.color)
            )
            .chartXAxis {
                AxisMarks(values: ["S1", "S4", "S8", "S12"]) { _ in AxisValueLabel() }
            }
            .chartYAxis {
                AxisMarks(position: .leading, values: [0, 2, 4, 6, 8]) { value in
                    AxisGridLine()
                    AxisValueLabel { Text("\(value.as(Int.self) ?? 0) h") }
                }
            }
            .chartLegend(position: .bottom, spacing: DS.Spacing.s)
            .frame(height: 200)
        }
        .dsCard()
        .studioComponent("Graphique volume")
    }

    private var volumeBySport: some View {
        let thisWeek = Mock.volumes.filter { $0.week == 12 }
        let average: (Sport) -> Double = { sport in
            let values = Mock.volumes.filter { $0.sport == sport }.map(\.hours)
            return values.reduce(0, +) / Double(values.count)
        }
        return VStack(spacing: DS.Spacing.xs) {
            ForEach(thisWeek) { item in
                HStack(spacing: DS.Spacing.s) {
                    Image(systemName: item.sport.icon)
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(item.sport.color, in: RoundedRectangle(cornerRadius: DS.Radius.s, style: .continuous))
                    VStack(alignment: .leading, spacing: 4) {
                        HStack {
                            Text(item.sport.label).font(.dsHeadline)
                            Spacer()
                            Text(Fmt.duration(Int(item.hours * 60))).font(.dsCallout.weight(.semibold))
                        }
                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                Capsule().fill(item.sport.color.opacity(0.15))
                                Capsule().fill(item.sport.color).frame(width: geo.size.width * min(item.hours / 4, 1))
                            }
                        }
                        .frame(height: 6)
                        Text("Moyenne \(Fmt.duration(Int(average(item.sport) * 60))) / sem.")
                            .font(.dsCaption)
                            .foregroundStyle(.dsTextSecondary)
                    }
                }
                .padding(DS.Spacing.s)
                .background(Color.dsSurface, in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
                .studioComponent("Volume · \(item.sport.label)")
            }
        }
    }

    // MARK: Forme

    private var vo2Chart: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            HStack(alignment: .firstTextBaseline) {
                Text("48,6").font(.system(size: 30, weight: .heavy, design: .rounded))
                Text("VO2max · ml/kg/min").font(.dsCallout).foregroundStyle(.dsTextSecondary)
                Spacer()
                DSTag(text: "+2,5 en 12 sem.", color: .green)
            }
            Chart(Mock.vo2max, id: \.week) { point in
                AreaMark(x: .value("Semaine", point.week), yStart: .value("Base", 45), yEnd: .value("VO2max", point.value))
                    .foregroundStyle(LinearGradient(colors: [.green.opacity(0.3), .green.opacity(0)], startPoint: .top, endPoint: .bottom))
                    .interpolationMethod(.catmullRom)
                LineMark(x: .value("Semaine", point.week), y: .value("VO2max", point.value))
                    .foregroundStyle(.green)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .interpolationMethod(.catmullRom)
            }
            .chartYScale(domain: 45...49.5)
            .chartXAxis(.hidden)
            .frame(height: 120)
        }
        .dsCard()
        .studioComponent("Graphique VO2max")
    }

    private var paceChart: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.s) {
            HStack(alignment: .firstTextBaseline) {
                Text(Fmt.pace(320)).font(.system(size: 30, weight: .heavy, design: .rounded))
                Text("/km à 150 bpm").font(.dsCallout).foregroundStyle(.dsTextSecondary)
                Spacer()
                DSTag(text: "−25 s/km", color: .green)
            }
            Chart(Mock.paceAt150, id: \.week) { point in
                LineMark(x: .value("Semaine", point.week), y: .value("Allure", point.seconds))
                    .foregroundStyle(Sport.course.color)
                    .lineStyle(StrokeStyle(lineWidth: 3))
                    .interpolationMethod(.catmullRom)
                PointMark(x: .value("Semaine", point.week), y: .value("Allure", point.seconds))
                    .foregroundStyle(Sport.course.color)
                    .symbolSize(20)
            }
            .chartYScale(domain: .automatic(includesZero: false, reversed: true))
            .chartYAxis {
                AxisMarks(position: .leading, values: [320, 330, 340]) { value in
                    AxisGridLine()
                    AxisValueLabel { Text(Fmt.pace(value.as(Int.self) ?? 0)) }
                }
            }
            .chartXAxis(.hidden)
            .frame(height: 120)
            Text("Tu cours plus vite pour le même effort cardiaque : ton endurance progresse.")
                .font(.dsCaption)
                .foregroundStyle(.dsTextSecondary)
        }
        .dsCard()
        .studioComponent("Graphique allure")
    }

    // MARK: Records

    private var recordsList: some View {
        VStack(spacing: 0) {
            ForEach(Mock.records) { record in
                HStack(spacing: DS.Spacing.s) {
                    Image(systemName: record.sport.icon).foregroundStyle(record.sport.color).frame(width: 28)
                    VStack(alignment: .leading, spacing: 2) {
                        Text(record.title).font(.dsBody)
                        Text(record.date).font(.dsCaption).foregroundStyle(.dsTextSecondary)
                    }
                    Spacer()
                    if record.isNew { DSTag(text: "Nouveau") }
                    Text(record.value).font(.system(.headline, design: .rounded))
                }
                .padding(.vertical, DS.Spacing.s)
                .studioComponent("Record · \(record.title)")
                if record.id != Mock.records.last?.id { Divider() }
            }
        }
        .dsCard(padding: DS.Spacing.s)
    }

    private var recordsCards: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: DS.Spacing.xs) {
            ForEach(Mock.records) { record in
                VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                    HStack {
                        Image(systemName: record.sport.icon).foregroundStyle(record.sport.color)
                        Spacer()
                        if record.isNew {
                            Image(systemName: "sparkles").foregroundStyle(.dsAccent)
                        }
                    }
                    Text(record.value).font(.system(.title2, design: .rounded, weight: .heavy))
                    Text(record.title).font(.dsCallout)
                    Text(record.date).font(.dsCaption).foregroundStyle(.dsTextSecondary)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(DS.Spacing.s)
                .background(record.sport.color.opacity(0.1), in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
                .studioComponent("Record · \(record.title)")
            }
        }
    }
}
