import SwiftUI
import Charts
import MapKit

struct BikeDebriefScreen: StudioScreen {
    static let info = ScreenInfo(
        "Séance vélo · bilan",
        flow: "Séance",
        order: 1000,
        notes: "Sortie endurance Z2 : données Apple Watch, temps en zones, parcours, analyse du coach."
    )

    private var totalMinutes: Int { Mock.bikeZones.reduce(0) { $0 + $1.minutes } }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: DS.Spacing.l) {
                    header

                    Slot("Parcours") {
                        Variant("Carte") { routeMap }
                        Variant("Profil d'altitude") { elevationChart }
                        Variant.hidden
                    }

                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: DS.Spacing.xs), count: 3), spacing: DS.Spacing.xs) {
                        DSMetricTile(label: "Distance", value: "42,6", unit: "km")
                        DSMetricTile(label: "Durée", value: "1:31")
                        DSMetricTile(label: "Vitesse moy.", value: "28,1", unit: "km/h")
                        DSMetricTile(label: "FC moy.", value: "132", unit: "bpm")
                        DSMetricTile(label: "Dénivelé", value: "380", unit: "m")
                        DSMetricTile(label: "Calories", value: "980", unit: "kcal")
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        DSSectionHeader(title: "Temps en zones", action: "Objectif : Z2")
                        Slot("Temps en zones") {
                            Variant("Barres") { zoneBars }
                            Variant("Anneau") { zoneDonut }
                        }
                    }

                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        Label("Analyse du coach", systemImage: "sparkles")
                            .font(.dsHeadline)
                            .foregroundStyle(.dsAccent)
                        Text("Sortie endurance parfaitement tenue : 82 % du temps en Z2, et la FC n'a pas dérivé sur la fin (+3 bpm). C'est exactement ce qu'on cherche. Mardi, place au fractionné : arrive reposé.")
                            .font(.dsBody)
                        Text("Rédigé par Claude · lun. 19 oct. 12:10")
                            .font(.dsCaption)
                            .foregroundStyle(.dsTextSecondary)
                    }
                    .dsCard()
                    .studioComponent("Analyse du coach")

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
            Text("Endurance Z2").font(.dsDisplay)
            Label("Lundi 19 oct. · 10:30 · Apple Watch", systemImage: Sport.velo.icon)
                .font(.dsCallout)
                .foregroundStyle(.dsTextSecondary)
        }
        .padding(.top, DS.Spacing.s)
        .studioComponent("En-tête séance")
    }

    // MARK: Parcours

    private var routeMap: some View {
        Map(initialPosition: .region(MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 48.8300, longitude: 2.4270),
            span: MKCoordinateSpan(latitudeDelta: 0.03, longitudeDelta: 0.05)
        ))) {
            MapPolyline(coordinates: Mock.bikeRoute)
                .stroke(Sport.velo.color, style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round))
            Annotation("Départ", coordinate: Mock.bikeRoute[0]) {
                Circle().fill(.green).frame(width: 14, height: 14).overlay(Circle().stroke(.white, lineWidth: 3))
            }
        }
        .mapStyle(.standard(elevation: .flat, pointsOfInterest: .excludingAll))
        .allowsHitTesting(false)
        .frame(height: 200)
        .clipShape(RoundedRectangle(cornerRadius: DS.Radius.l, style: .continuous))
        .studioComponent("Carte du parcours")
    }

    private var elevationChart: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xs) {
            HStack {
                Label("380 m de dénivelé", systemImage: "mountain.2.fill").font(.dsHeadline)
                Spacer()
                Text("max 142 m").font(.dsCaption).foregroundStyle(.dsTextSecondary)
            }
            Chart(Mock.bikeElevation, id: \.km) { point in
                AreaMark(x: .value("km", point.km), y: .value("Altitude", point.meters))
                    .foregroundStyle(LinearGradient(colors: [Sport.velo.color.opacity(0.5), Sport.velo.color.opacity(0.05)], startPoint: .top, endPoint: .bottom))
                    .interpolationMethod(.catmullRom)
                LineMark(x: .value("km", point.km), y: .value("Altitude", point.meters))
                    .foregroundStyle(Sport.velo.color)
                    .interpolationMethod(.catmullRom)
            }
            .chartXAxis {
                AxisMarks(values: [0, 10, 20, 30, 40]) { value in
                    AxisValueLabel { Text("\(value.as(Int.self) ?? 0) km") }
                }
            }
            .chartYAxis(.hidden)
            .frame(height: 130)
        }
        .dsCard()
        .studioComponent("Profil d'altitude")
    }

    // MARK: Zones

    private var zoneBars: some View {
        VStack(spacing: DS.Spacing.xs) {
            ForEach(Mock.bikeZones) { zone in
                HStack(spacing: DS.Spacing.s) {
                    Text("Z\(zone.zone)")
                        .font(.system(.caption, design: .rounded, weight: .bold))
                        .foregroundStyle(.white)
                        .frame(width: 30, height: 24)
                        .background(Color.dsZone(zone.zone), in: RoundedRectangle(cornerRadius: 6))
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            Capsule().fill(Color.dsSurface)
                            Capsule().fill(Color.dsZone(zone.zone))
                                .frame(width: max(geo.size.width * Double(zone.minutes) / Double(totalMinutes), zone.minutes > 0 ? 6 : 0))
                        }
                    }
                    .frame(height: 10)
                    Text("\(zone.minutes) min")
                        .font(.dsCallout.monospacedDigit().weight(zone.zone == 2 ? .bold : .regular))
                        .frame(width: 60, alignment: .trailing)
                }
                .studioComponent("Zone \(zone.zone)")
            }
        }
        .dsCard(padding: DS.Spacing.s)
    }

    private var zoneDonut: some View {
        HStack(spacing: DS.Spacing.m) {
            Chart(Mock.bikeZones.filter { $0.minutes > 0 }) { zone in
                SectorMark(
                    angle: .value("Minutes", zone.minutes),
                    innerRadius: .ratio(0.62),
                    angularInset: 2
                )
                .foregroundStyle(Color.dsZone(zone.zone))
                .cornerRadius(3)
            }
            .chartBackground { _ in
                VStack(spacing: 0) {
                    Text("82 %").font(.system(.title3, design: .rounded, weight: .heavy))
                    Text("en Z2").font(.dsCaption).foregroundStyle(.dsTextSecondary)
                }
            }
            .frame(width: 130, height: 130)
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Mock.bikeZones) { zone in
                    HStack(spacing: 6) {
                        Circle().fill(Color.dsZone(zone.zone)).frame(width: 8, height: 8)
                        Text("Z\(zone.zone)").font(.dsCaption.weight(.bold))
                        Text(zone.range).font(.dsCaption).foregroundStyle(.dsTextSecondary)
                        Spacer()
                        Text("\(zone.minutes)'").font(.dsCaption.monospacedDigit())
                    }
                }
            }
        }
        .dsCard()
        .studioComponent("Anneau des zones")
    }
}
