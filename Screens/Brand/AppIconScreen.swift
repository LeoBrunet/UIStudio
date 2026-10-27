import SwiftUI

// MARK: - Icon artwork (pure shapes: no SF Symbols, which Apple forbids in app icons)

enum IconConcept: String, CaseIterable {
    case intervalles = "Intervalles", piste = "Piste", monogramme = "Monogramme C", pouls = "Pouls", chevrons = "Chevrons"
}

enum IconPalette: String, CaseIterable {
    case orange = "Orange", nuit = "Nuit", clair = "Clair"

    var background: LinearGradient {
        switch self {
        case .orange:
            LinearGradient(colors: [Color(red: 1.0, green: 0.45, blue: 0.20), Color(red: 0.93, green: 0.25, blue: 0.11)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .nuit:
            LinearGradient(colors: [Color(red: 0.12, green: 0.11, blue: 0.17), Color(red: 0.22, green: 0.18, blue: 0.30)], startPoint: .topLeading, endPoint: .bottomTrailing)
        case .clair:
            LinearGradient(colors: [Color(red: 1.0, green: 0.98, blue: 0.95), Color(red: 0.98, green: 0.93, blue: 0.88)], startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }

    var mark: Color { self == .orange ? .white : Color(red: 1.0, green: 0.36, blue: 0.16) }
    var markSoft: Color { mark.opacity(self == .orange ? 0.6 : 0.45) }
}

/// The app icon, drawn at any size. Uses the full square: iOS applies the rounded mask itself.
struct AppIconArt: View {
    var concept: IconConcept = .intervalles
    var palette: IconPalette = .orange
    var sparkle = true

    var body: some View {
        Canvas { context, size in
            let s = size.width
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .linearGradient(
                palette == .orange
                    ? Gradient(colors: [Color(red: 1.0, green: 0.45, blue: 0.20), Color(red: 0.93, green: 0.25, blue: 0.11)])
                    : palette == .nuit
                        ? Gradient(colors: [Color(red: 0.12, green: 0.11, blue: 0.17), Color(red: 0.22, green: 0.18, blue: 0.30)])
                        : Gradient(colors: [Color(red: 1.0, green: 0.98, blue: 0.95), Color(red: 0.98, green: 0.93, blue: 0.88)]),
                startPoint: .zero, endPoint: CGPoint(x: s, y: s)))
            let mark = GraphicsContext.Shading.color(palette.mark)
            let soft = GraphicsContext.Shading.color(palette.markSoft)
            let stroke = StrokeStyle(lineWidth: s * 0.085, lineCap: .round, lineJoin: .round)

            switch concept {
            case .intervalles:
                let heights: [CGFloat] = [0.16, 0.27, 0.20, 0.37, 0.25, 0.45]
                let barWidth = s * 0.08, gap = s * 0.04
                let total = CGFloat(heights.count) * barWidth + CGFloat(heights.count - 1) * gap
                var x = (s - total) / 2
                let baseline = s * 0.78
                for (i, h) in heights.enumerated() {
                    let rect = CGRect(x: x, y: baseline - s * h, width: barWidth, height: s * h)
                    context.fill(Path(roundedRect: rect, cornerRadius: barWidth / 2), with: i % 2 == 1 ? mark : soft)
                    x += barWidth + gap
                }
            case .piste:
                let rect = CGRect(x: s * 0.2, y: s * 0.3, width: s * 0.6, height: s * 0.42)
                context.stroke(Path(roundedRect: rect, cornerRadius: rect.height / 2), with: soft, style: StrokeStyle(lineWidth: s * 0.05))
                let inner = rect.insetBy(dx: s * 0.09, dy: s * 0.09)
                context.stroke(Path(roundedRect: inner, cornerRadius: inner.height / 2), with: mark, style: StrokeStyle(lineWidth: s * 0.05))
                let dot = CGRect(x: rect.maxX - s * 0.17, y: rect.minY - s * 0.035, width: s * 0.12, height: s * 0.12)
                context.fill(Path(ellipseIn: dot), with: mark)
            case .monogramme:
                var arc = Path()
                arc.addArc(center: CGPoint(x: s * 0.5, y: s * 0.52), radius: s * 0.24, startAngle: .degrees(40), endAngle: .degrees(320), clockwise: false)
                context.stroke(arc, with: mark, style: StrokeStyle(lineWidth: s * 0.11, lineCap: .round))
            case .pouls:
                var line = Path()
                let y = s * 0.56
                line.move(to: CGPoint(x: s * 0.16, y: y))
                line.addLine(to: CGPoint(x: s * 0.36, y: y))
                line.addLine(to: CGPoint(x: s * 0.44, y: s * 0.34))
                line.addLine(to: CGPoint(x: s * 0.53, y: s * 0.74))
                line.addLine(to: CGPoint(x: s * 0.61, y: y))
                line.addLine(to: CGPoint(x: s * 0.84, y: y))
                context.stroke(line, with: mark, style: stroke)
            case .chevrons:
                for (i, x) in [0.26, 0.42, 0.58].enumerated() {
                    var chevron = Path()
                    chevron.move(to: CGPoint(x: s * x, y: s * 0.34))
                    chevron.addLine(to: CGPoint(x: s * (x + 0.13), y: s * 0.52))
                    chevron.addLine(to: CGPoint(x: s * x, y: s * 0.70))
                    context.stroke(chevron, with: i == 2 ? mark : soft, style: stroke)
                }
            }

            if sparkle {
                // Placed in the free top-right corner for every concept.
                let c = CGPoint(x: s * 0.78, y: s * 0.2), r = s * 0.075, w = r * 0.26
                var star = Path()
                star.move(to: CGPoint(x: c.x, y: c.y - r))
                star.addQuadCurve(to: CGPoint(x: c.x + r, y: c.y), control: CGPoint(x: c.x + w, y: c.y - w))
                star.addQuadCurve(to: CGPoint(x: c.x, y: c.y + r), control: CGPoint(x: c.x + w, y: c.y + w))
                star.addQuadCurve(to: CGPoint(x: c.x - r, y: c.y), control: CGPoint(x: c.x - w, y: c.y + w))
                star.addQuadCurve(to: CGPoint(x: c.x, y: c.y - r), control: CGPoint(x: c.x - w, y: c.y - w))
                context.fill(star, with: mark)
            }
        }
        .aspectRatio(1, contentMode: .fit)
    }
}

// MARK: - Screen: the icon as it will look on the iPhone

struct AppIconScreen: StudioScreen {
    static let info = ScreenInfo(
        "Icône de l'app",
        flow: "Marque",
        order: 100,
        notes: "Logo de l'app Coach : grand format, écran d'accueil, petites tailles (Réglages, Spotlight)."
    )

    var body: some View {
        Slot("Concept") {
            Variant("Intervalles") { IconSlots(concept: .intervalles) }
            Variant("Piste") { IconSlots(concept: .piste) }
            Variant("Monogramme C") { IconSlots(concept: .monogramme) }
            Variant("Pouls") { IconSlots(concept: .pouls) }
            Variant("Chevrons") { IconSlots(concept: .chevrons) }
        }
    }
}

/// The color and sparkle choices, nested under the concept.
private struct IconSlots: View {
    let concept: IconConcept

    var body: some View {
        Slot("Couleurs") {
            Variant("Orange") { SparkleSlot(concept: concept, palette: .orange) }
            Variant("Nuit") { SparkleSlot(concept: concept, palette: .nuit) }
            Variant("Clair") { SparkleSlot(concept: concept, palette: .clair) }
        }
    }
}

private struct SparkleSlot: View {
    let concept: IconConcept
    let palette: IconPalette

    var body: some View {
        Slot("Étincelle") {
            Variant("Avec") { IconShowcase(art: AppIconArt(concept: concept, palette: palette, sparkle: true)) }
            Variant("Sans") { IconShowcase(art: AppIconArt(concept: concept, palette: palette, sparkle: false)) }
        }
    }
}

private struct IconShowcase: View {
    let art: AppIconArt

    private let neighbors: [(String, Color, String)] = [
        ("Santé", .pink, "heart.fill"), ("Forme", .green, "figure.run.circle"), ("Claude", Color(red: 0.85, green: 0.47, blue: 0.34), "sparkles"),
        ("Météo", .blue, "cloud.sun.fill"), ("Plans", .teal, "map.fill"), ("Musique", .red, "music.note"), ("Photos", .orange, "photo.fill"),
    ]

    var body: some View {
        VStack(spacing: 28) {
            // Large
            VStack(spacing: 10) {
                art
                    .frame(width: 170, height: 170)
                    .clipShape(RoundedRectangle(cornerRadius: 38, style: .continuous))
                    .shadow(color: .black.opacity(0.3), radius: 18, y: 10)
                    .studioComponent("Icône · grand format")
                Text("Coach").font(.headline).foregroundStyle(.white)
            }
            .padding(.top, 30)

            // Home screen
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 18), count: 4), spacing: 20) {
                ForEach(Array(neighbors.prefix(5).enumerated()), id: \.offset) { _, app in homeApp(app) }
                VStack(spacing: 6) {
                    art.frame(width: 62, height: 62).clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                    Text("Coach").font(.system(size: 12)).foregroundStyle(.white)
                }
                .studioComponent("Icône · écran d'accueil")
                ForEach(Array(neighbors.suffix(2).enumerated()), id: \.offset) { _, app in homeApp(app) }
            }
            .padding(.horizontal, 24)

            // Small sizes
            HStack(spacing: 22) {
                ForEach([(29.0, "Réglages"), (40.0, "Spotlight"), (60.0, "Notification")], id: \.0) { size, label in
                    VStack(spacing: 6) {
                        art.frame(width: size, height: size).clipShape(RoundedRectangle(cornerRadius: size * 0.225, style: .continuous))
                        Text(label).font(.system(size: 10)).foregroundStyle(.white.opacity(0.8))
                    }
                }
            }
            .padding(14)
            .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
            .studioComponent("Icône · petites tailles")
            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(colors: [Color(red: 0.16, green: 0.20, blue: 0.36), Color(red: 0.42, green: 0.30, blue: 0.48)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }

    private func homeApp(_ app: (String, Color, String)) -> some View {
        VStack(spacing: 6) {
            Image(systemName: app.2)
                .font(.system(size: 26, weight: .semibold))
                .foregroundStyle(.white)
                .frame(width: 62, height: 62)
                .background(app.1.gradient, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            Text(app.0).font(.system(size: 12)).foregroundStyle(.white)
        }
    }
}
