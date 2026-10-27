import SwiftUI

// MARK: - Intensity zones (Z1–Z5)

extension Color {
    static func dsZone(_ zone: Int) -> Color {
        switch zone {
        case ...1: Color(red: 0.55, green: 0.62, blue: 0.70)
        case 2: Color(red: 0.20, green: 0.60, blue: 1.00)
        case 3: Color(red: 0.20, green: 0.78, blue: 0.45)
        case 4: Color(red: 1.00, green: 0.62, blue: 0.10)
        default: Color(red: 1.00, green: 0.27, blue: 0.23)
        }
    }
}

/// Session profile: block width = duration, block height = zone.
struct IntensityBar: View {
    let segments: [(minutes: Double, zone: Int)]
    var monochrome = false
    var spacing: CGFloat = 2

    var body: some View {
        GeometryReader { geo in
            let total = max(segments.reduce(0) { $0 + $1.minutes }, 1)
            let available = geo.size.width - spacing * CGFloat(max(segments.count - 1, 0))
            HStack(alignment: .bottom, spacing: spacing) {
                ForEach(Array(segments.enumerated()), id: \.offset) { _, segment in
                    RoundedRectangle(cornerRadius: 3, style: .continuous)
                        .fill(monochrome ? Color.white.opacity(0.3 + 0.14 * Double(segment.zone)) : Color.dsZone(segment.zone))
                        .frame(
                            width: max(available * segment.minutes / total, 2),
                            height: geo.size.height * (0.2 + 0.16 * Double(segment.zone))
                        )
                }
            }
            .frame(maxHeight: .infinity, alignment: .bottom)
        }
        .studioComponent("Barre d'intensité")
    }
}

// MARK: - Ring

struct DSRing: View {
    let progress: Double
    let color: Color
    var lineWidth: CGFloat = 8

    var body: some View {
        ZStack {
            Circle().stroke(color.opacity(0.18), lineWidth: lineWidth)
            Circle()
                .trim(from: 0, to: progress)
                .stroke(color, style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                .rotationEffect(.degrees(-90))
        }
        .studioComponent("Anneau")
    }
}

// MARK: - Metric tile

struct DSMetricTile: View {
    let label: String
    let value: String
    var unit: String?

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.xxs) {
            Text(label)
                .font(.dsCaption)
                .foregroundStyle(.dsTextSecondary)
            HStack(alignment: .firstTextBaseline, spacing: 3) {
                Text(value)
                    .font(.system(.title3, design: .rounded, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.6)
                if let unit {
                    Text(unit).font(.dsCaption).foregroundStyle(.dsTextSecondary)
                }
            }
        }
        // Fills the row height so tiles side by side are the same size.
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .padding(DS.Spacing.s)
        .background(Color.dsSurface, in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
        .studioComponent("Tuile · \(label)")
    }
}

// MARK: - Coach (opens the Claude app)

/// The coach lives in the Claude app (via the MCP connector); this button hands off to it.
struct CoachButton: View {
    let title: String
    var kind: DSButtonStyle.Kind = .primary
    var showsHint = false
    var action: () -> Void = {}

    var body: some View {
        VStack(spacing: DS.Spacing.xxs) {
            Button(action: action) {
                Label(title, systemImage: "sparkles")
            }
            .buttonStyle(DSButtonStyle(kind: kind))
            if showsHint {
                Text("S'ouvre dans l'app Claude")
                    .font(.dsCaption)
                    .foregroundStyle(.dsTextSecondary)
            }
        }
        .studioComponent("Bouton coach")
    }
}

struct DSChip: View {
    let text: String
    var icon: String?

    var body: some View {
        HStack(spacing: DS.Spacing.xxs) {
            if let icon { Image(systemName: icon) }
            Text(text)
        }
        .font(.dsCallout)
        .padding(.horizontal, DS.Spacing.s)
        .padding(.vertical, DS.Spacing.xs)
        .background(Color.dsSurface, in: Capsule())
        .overlay(Capsule().stroke(Color.dsBorder.opacity(0.5)))
        .studioComponent("Chip · \(text)")
    }
}
