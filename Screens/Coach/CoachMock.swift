import SwiftUI

// Shared models + realistic placeholder data for the coach app screens.

enum Sport: String {
    case course, velo, natation, muscu, repos

    var label: String {
        switch self {
        case .course: "Course"
        case .velo: "Vélo"
        case .natation: "Natation"
        case .muscu: "Renfo"
        case .repos: "Repos"
        }
    }

    var icon: String {
        switch self {
        case .course: "figure.run"
        case .velo: "figure.outdoor.cycle"
        case .natation: "figure.pool.swim"
        case .muscu: "figure.strengthtraining.traditional"
        case .repos: "bed.double.fill"
        }
    }

    var color: Color {
        switch self {
        case .course: Color(red: 1.0, green: 0.36, blue: 0.16)
        case .velo: Color(red: 0.16, green: 0.52, blue: 1.0)
        case .natation: Color(red: 0.0, green: 0.72, blue: 0.80)
        case .muscu: Color(red: 0.55, green: 0.36, blue: 0.96)
        case .repos: Color(red: 0.55, green: 0.60, blue: 0.66)
        }
    }
}

struct SessionStep: Identifiable {
    let id = UUID()
    let name: String
    let detail: String
    let minutes: Double
    let zone: Int
}

struct DayPlan: Identifiable {
    let id = UUID()
    let weekday: String
    let date: Int
    let sport: Sport
    let title: String
    let minutes: Int
    let done: Bool
    let isToday: Bool
}

struct Rep: Identifiable {
    let id = UUID()
    let index: Int
    let paceSeconds: Int
}

enum Mock {
    static let todaySport = Sport.course
    static let todayTitle = "Fractionné 6 × 800 m"
    static let todaySubtitle = "Travail de VMA pour ton semi"
    static let todayMinutes = 55
    static let targetPaceSeconds = 245

    static let steps: [SessionStep] = [
        SessionStep(name: "Échauffement", detail: "15 min footing · 5:40 /km", minutes: 15, zone: 2),
        SessionStep(name: "6 × 800 m", detail: "4:05 /km · récup 2 min trottinée", minutes: 30, zone: 4),
        SessionStep(name: "Retour au calme", detail: "10 min très facile", minutes: 10, zone: 1),
    ]

    /// Detailed profile for charts: warm-up, 6 × (800 m + recovery), cool-down.
    static let segments: [(minutes: Double, zone: Int)] = {
        var result: [(minutes: Double, zone: Int)] = [(15, 2)]
        for rep in 0..<6 {
            result.append((3.2, 4))
            if rep < 5 { result.append((2, 1)) }
        }
        result.append((10, 1))
        return result
    }()

    static let week: [DayPlan] = [
        DayPlan(weekday: "Lun", date: 19, sport: .velo, title: "Endurance", minutes: 90, done: true, isToday: false),
        DayPlan(weekday: "Mar", date: 20, sport: .course, title: "Fractionné 6 × 800 m", minutes: 55, done: false, isToday: true),
        DayPlan(weekday: "Mer", date: 21, sport: .muscu, title: "Renfo bas du corps", minutes: 45, done: false, isToday: false),
        DayPlan(weekday: "Jeu", date: 22, sport: .course, title: "Footing Z2", minutes: 40, done: false, isToday: false),
        DayPlan(weekday: "Ven", date: 23, sport: .repos, title: "Repos", minutes: 0, done: false, isToday: false),
        DayPlan(weekday: "Sam", date: 24, sport: .natation, title: "Technique crawl", minutes: 45, done: false, isToday: false),
        DayPlan(weekday: "Dim", date: 25, sport: .course, title: "Sortie longue", minutes: 95, done: false, isToday: false),
    ]

    static let reps: [Rep] = [
        Rep(index: 1, paceSeconds: 243),
        Rep(index: 2, paceSeconds: 244),
        Rep(index: 3, paceSeconds: 246),
        Rep(index: 4, paceSeconds: 245),
        Rep(index: 5, paceSeconds: 247),
        Rep(index: 6, paceSeconds: 254),
    ]

    static let coachNote = "Belle nuit (7 h 42) et VFC au-dessus de ta moyenne : on garde le fractionné prévu. Pars prudemment sur les 2 premières répétitions, la dernière doit être aussi rapide que la première."

    static let coachDebrief = "Très bonne séance. Tu as tenu l'allure sur 5 répétitions sur 6 et ta FC est redescendue sous 130 bpm à chaque récup : ton aérobie progresse. La 6e répétition (4:14) montre un peu de fatigue, normal en semaine de charge. Jeudi, on reste en footing Z2 strict."
}

enum Fmt {
    static func pace(_ seconds: Int) -> String {
        String(format: "%d:%02d", seconds / 60, seconds % 60)
    }

    static func duration(_ minutes: Int) -> String {
        minutes >= 60 ? String(format: "%d h %02d", minutes / 60, minutes % 60) : "\(minutes) min"
    }
}
