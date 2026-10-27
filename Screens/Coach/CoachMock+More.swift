import SwiftUI
import CoreLocation

// Placeholder data for the Progrès, Profil, natation and vélo screens.

struct WeekVolume: Identifiable {
    let id = UUID()
    let week: Int
    let sport: Sport
    let hours: Double
}

struct Record: Identifiable {
    let id = UUID()
    let sport: Sport
    let title: String
    let value: String
    let date: String
    let isNew: Bool
}

struct SwimSet: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    let meters: Int
    let zone: Int
}

struct ZoneShare: Identifiable {
    let id = UUID()
    let zone: Int
    let minutes: Int
    let range: String
}

extension Mock {
    // MARK: Progrès

    static let volumes: [WeekVolume] = {
        let course: [Double] = [2.5, 2.8, 3.0, 2.2, 3.1, 3.3, 3.6, 2.6, 3.4, 3.7, 3.9, 3.2]
        let velo: [Double] = [1.5, 1.5, 2.0, 1.0, 1.5, 2.0, 1.5, 1.0, 2.0, 1.5, 2.0, 1.5]
        let natation: [Double] = [0.5, 0.75, 0.5, 0.5, 0.75, 0.75, 1.0, 0.5, 0.75, 0.75, 1.0, 0.75]
        let muscu: [Double] = [0.75, 0.75, 0.75, 0.5, 0.75, 0.75, 0.75, 0.5, 0.75, 0.75, 0.75, 0.75]
        return (0..<12).flatMap { week in
            [
                WeekVolume(week: week + 1, sport: .course, hours: course[week]),
                WeekVolume(week: week + 1, sport: .velo, hours: velo[week]),
                WeekVolume(week: week + 1, sport: .natation, hours: natation[week]),
                WeekVolume(week: week + 1, sport: .muscu, hours: muscu[week]),
            ]
        }
    }()

    static let vo2max: [(week: Int, value: Double)] = [
        (1, 46.1), (2, 46.3), (3, 46.2), (4, 46.6), (5, 46.9), (6, 47.0),
        (7, 47.4), (8, 47.3), (9, 47.8), (10, 48.1), (11, 48.3), (12, 48.6),
    ]

    /// Running pace at 150 bpm (seconds per km): lower = fitter.
    static let paceAt150: [(week: Int, seconds: Int)] = [
        (1, 345), (2, 343), (3, 340), (4, 341), (5, 336), (6, 334),
        (7, 331), (8, 332), (9, 327), (10, 325), (11, 322), (12, 320),
    ]

    static let records: [Record] = [
        Record(sport: .course, title: "10 km", value: "48:12", date: "12 oct.", isNew: true),
        Record(sport: .course, title: "Plus longue sortie", value: "21,4 km", date: "28 sept.", isNew: false),
        Record(sport: .velo, title: "Plus longue sortie", value: "82 km", date: "5 oct.", isNew: false),
        Record(sport: .natation, title: "1 000 m", value: "19:40", date: "18 oct.", isNew: true),
    ]

    // MARK: Natation

    static let swimSets: [SwimSet] = [
        SwimSet(name: "Échauffement", detail: "Crawl souple, respiration 3 temps", meters: 200, zone: 1),
        SwimSet(name: "Éducatifs · 4 × 50 m", detail: "Rattrapé · récup 20 s", meters: 200, zone: 2),
        SwimSet(name: "Corps · 8 × 100 m", detail: "Allure 1:55 /100 m · récup 15 s", meters: 800, zone: 3),
        SwimSet(name: "Jambes · 4 × 50 m", detail: "Avec planche · récup 20 s", meters: 200, zone: 2),
        SwimSet(name: "Pull · 2 × 100 m", detail: "Avec pull-buoy, focus traction", meters: 200, zone: 2),
        SwimSet(name: "Retour au calme", detail: "Dos ou brasse, très souple", meters: 200, zone: 1),
    ]

    // MARK: Vélo

    static let bikeZones: [ZoneShare] = [
        ZoneShare(zone: 1, minutes: 9, range: "< 118 bpm"),
        ZoneShare(zone: 2, minutes: 75, range: "118–138"),
        ZoneShare(zone: 3, minutes: 6, range: "139–152"),
        ZoneShare(zone: 4, minutes: 1, range: "153–166"),
        ZoneShare(zone: 5, minutes: 0, range: "> 166"),
    ]

    static let bikeElevation: [(km: Double, meters: Double)] = (0...42).map { km in
        let x = Double(km)
        return (x, 60 + 25 * sin(x / 4) + 40 * sin(x / 11) + (x > 18 && x < 26 ? (x - 18) * 9 : x >= 26 ? 72 - (x - 26) * 3 : 0))
    }

    /// A loop around the Bois de Vincennes.
    static let bikeRoute: [CLLocationCoordinate2D] = [
        (48.8399, 2.4127), (48.8365, 2.4230), (48.8330, 2.4345), (48.8290, 2.4420), (48.8250, 2.4470),
        (48.8205, 2.4420), (48.8190, 2.4320), (48.8215, 2.4210), (48.8260, 2.4130), (48.8310, 2.4090),
        (48.8360, 2.4080), (48.8399, 2.4127),
    ].map { CLLocationCoordinate2D(latitude: $0.0, longitude: $0.1) }
}
