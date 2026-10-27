import SwiftUI

// MARK: - Logo artwork (pure shapes, any size)

enum StudioLogoConcept: String, CaseIterable {
    case calques = "Calques", curseur = "Curseur", monogramme = "Monogramme UI", pin = "Épingle", grille = "Grille 2×2"
    case canvas = "Canvas", variants = "Variantes", selection = "Sélection", accolades = "Accolades"
}

enum StudioLogoPalette: String, CaseIterable {
    case indigo = "Indigo", graphite = "Graphite", clair = "Clair", corail = "Corail"

    var gradient: Gradient {
        switch self {
        case .indigo: Gradient(colors: [Color(red: 0.42, green: 0.36, blue: 1.0), Color(red: 0.20, green: 0.16, blue: 0.62)])
        case .graphite: Gradient(colors: [Color(red: 0.20, green: 0.21, blue: 0.25), Color(red: 0.08, green: 0.08, blue: 0.10)])
        case .clair: Gradient(colors: [Color(red: 0.99, green: 0.99, blue: 1.0), Color(red: 0.90, green: 0.91, blue: 0.96)])
        case .corail: Gradient(colors: [Color(red: 1.0, green: 0.52, blue: 0.42), Color(red: 0.86, green: 0.26, blue: 0.36)])
        }
    }

    /// Main strokes/fills of the mark.
    var ink: Color { self == .clair ? Color(red: 0.24, green: 0.20, blue: 0.70) : .white }
    var inkSoft: Color { ink.opacity(self == .clair ? 0.35 : 0.42) }
    /// Selection blue, like a design tool's selection outline.
    var accent: Color {
        switch self {
        case .indigo: Color(red: 1.0, green: 0.78, blue: 0.30)
        case .corail: Color(red: 0.17, green: 0.13, blue: 0.38)
        default: Color(red: 0.25, green: 0.56, blue: 1.0)
        }
    }
}

/// The mark on its tile. Draws the full square; the caller clips to the icon shape.
struct StudioLogoArt: View {
    var concept: StudioLogoConcept = .canvas
    var palette: StudioLogoPalette = .indigo
    /// Dot grid behind the mark (the canvas).
    var grid = true

    var body: some View {
        Canvas { context, size in
            let s = size.width
            context.fill(Path(CGRect(origin: .zero, size: size)), with: .linearGradient(
                palette.gradient, startPoint: .zero, endPoint: CGPoint(x: s, y: s)))

            if grid {
                let step = s / 9
                let dot = max(s * 0.012, 0.6)
                for i in 1..<9 { for j in 1..<9 {
                    let rect = CGRect(x: CGFloat(i) * step - dot, y: CGFloat(j) * step - dot, width: dot * 2, height: dot * 2)
                    context.fill(Path(ellipseIn: rect), with: .color(palette.ink.opacity(0.14)))
                } }
            }

            let line = s * 0.045
            func phone(_ rect: CGRect) -> Path { Path(roundedRect: rect, cornerRadius: rect.width * 0.24, style: .continuous) }

            switch concept {
            case .calques:
                // Three stacked layers (design layers), the top one solid.
                func layer(_ cy: CGFloat) -> Path {
                    let a = s * 0.3, b = s * 0.15, cx = s / 2
                    var p = Path()
                    p.move(to: CGPoint(x: cx, y: cy - b)); p.addLine(to: CGPoint(x: cx + a, y: cy))
                    p.addLine(to: CGPoint(x: cx, y: cy + b)); p.addLine(to: CGPoint(x: cx - a, y: cy)); p.closeSubpath()
                    return p
                }
                let round = StrokeStyle(lineWidth: line, lineJoin: .round)
                context.stroke(layer(s * 0.66), with: .color(palette.accent), style: round)
                context.fill(layer(s * 0.53), with: .color(palette.inkSoft))
                context.stroke(layer(s * 0.53), with: .color(palette.inkSoft), style: round)
                context.fill(layer(s * 0.40), with: .color(palette.ink))
                context.stroke(layer(s * 0.40), with: .color(palette.ink), style: round)

            case .curseur:
                // A phone and a pointer clicking on it.
                let w = s * 0.32, h = s * 0.54
                let r = CGRect(x: s * 0.2, y: s * 0.18, width: w, height: h)
                context.fill(phone(r), with: .color(palette.ink))
                let k = s * 0.36, o = CGPoint(x: s * 0.46, y: s * 0.44)
                let pts: [(CGFloat, CGFloat)] = [(0, 0), (0, 0.74), (0.2, 0.57), (0.33, 0.86), (0.46, 0.8), (0.33, 0.52), (0.58, 0.5)]
                var arrow = Path()
                arrow.addLines(pts.map { CGPoint(x: o.x + $0.0 * k, y: o.y + $0.1 * k) }); arrow.closeSubpath()
                context.stroke(arrow, with: .color(palette.ink), style: StrokeStyle(lineWidth: line * 1.6, lineJoin: .round))
                context.fill(arrow, with: .color(palette.accent))

            case .monogramme:
                // "UI": a rounded U, the I is a phone.
                var u = Path()
                let top = s * 0.27, bottom = s * 0.71, x0 = s * 0.2, x1 = s * 0.5
                let rr = (x1 - x0) / 2
                u.move(to: CGPoint(x: x0, y: top))
                u.addLine(to: CGPoint(x: x0, y: bottom - rr))
                u.addArc(center: CGPoint(x: x0 + rr, y: bottom - rr), radius: rr, startAngle: .degrees(180), endAngle: .degrees(0), clockwise: true)
                u.addLine(to: CGPoint(x: x1, y: top))
                context.stroke(u, with: .color(palette.ink), style: StrokeStyle(lineWidth: s * 0.1, lineCap: .round))
                let i = CGRect(x: s * 0.6, y: top - s * 0.05, width: s * 0.2, height: bottom - top + s * 0.1)
                context.fill(phone(i), with: .color(palette.accent))

            case .pin:
                // A comment pin holding a phone.
                let c = CGPoint(x: s / 2, y: s * 0.43), rad = s * 0.27
                var drop = Path()
                drop.addArc(center: c, radius: rad, startAngle: .degrees(140), endAngle: .degrees(40), clockwise: false)
                drop.addLine(to: CGPoint(x: s / 2, y: s * 0.86))
                drop.closeSubpath()
                context.fill(drop, with: .color(palette.ink))
                let w = s * 0.17, h = s * 0.29
                context.fill(phone(CGRect(x: c.x - w / 2, y: c.y - h / 2, width: w, height: h)), with: .color(palette.accent))

            case .grille:
                // 2×2 grid of screens, one selected: the variants view.
                let t = s * 0.25, gap = s * 0.07
                let x0 = (s - 2 * t - gap) / 2
                for (i, j) in [(0, 0), (1, 0), (0, 1), (1, 1)] {
                    let r = CGRect(x: x0 + CGFloat(i) * (t + gap), y: x0 + CGFloat(j) * (t + gap), width: t, height: t)
                    let tile = Path(roundedRect: r, cornerRadius: t * 0.24, style: .continuous)
                    let selected = i == 1 && j == 0
                    context.fill(tile, with: .color(selected ? palette.ink : palette.inkSoft))
                    if selected {
                        context.stroke(Path(roundedRect: r.insetBy(dx: -line * 1.2, dy: -line * 1.2), cornerRadius: t * 0.3, style: .continuous),
                                       with: .color(palette.accent), lineWidth: line * 0.6)
                    }
                }

            case .canvas:
                // Three phones side by side, the middle one selected and forward.
                let w = s * 0.24, h = s * 0.46
                let left = CGRect(x: s * 0.13, y: s * 0.30, width: w, height: h)
                let right = CGRect(x: s * 0.63, y: s * 0.30, width: w, height: h)
                let mid = CGRect(x: s * 0.36, y: s * 0.22, width: w * 1.17, height: h * 1.17)
                context.stroke(phone(left), with: .color(palette.inkSoft), lineWidth: line * 0.8)
                context.stroke(phone(right), with: .color(palette.inkSoft), lineWidth: line * 0.8)
                context.fill(phone(mid), with: .color(palette.ink))
                context.stroke(phone(mid.insetBy(dx: -line * 1.3, dy: -line * 1.3)), with: .color(palette.accent), lineWidth: line * 0.55)

            case .variants:
                // A phone with two variants fanned behind it.
                let w = s * 0.34, h = s * 0.58
                let base = CGRect(x: (s - w) / 2, y: (s - h) / 2 + s * 0.03, width: w, height: h)
                for (k, angle) in [(2, -16.0), (1, -8.0)] {
                    var c = context
                    c.translateBy(x: base.midX, y: base.maxY)
                    c.rotate(by: .degrees(angle))
                    c.translateBy(x: -base.midX, y: -base.maxY)
                    c.fill(phone(base), with: .color(palette.ink.opacity(k == 2 ? 0.25 : 0.5)))
                }
                context.fill(phone(base), with: .color(palette.ink))
                // Notch-free screen content: two bars, the slot highlighted.
                let bar = CGRect(x: base.minX + w * 0.18, y: base.minY + h * 0.22, width: w * 0.64, height: h * 0.12)
                context.fill(Path(roundedRect: bar, cornerRadius: bar.height * 0.35), with: .color(palette.accent))
                let bar2 = bar.offsetBy(dx: 0, dy: h * 0.2)
                context.fill(Path(roundedRect: bar2, cornerRadius: bar2.height * 0.35), with: .linearGradient(
                    palette.gradient, startPoint: bar2.origin, endPoint: CGPoint(x: bar2.maxX, y: bar2.maxY)))

            case .selection:
                // A phone outline inside a design-tool selection box with handles.
                let w = s * 0.36, h = s * 0.6
                let r = CGRect(x: (s - w) / 2, y: (s - h) / 2, width: w, height: h)
                context.stroke(phone(r), with: .color(palette.ink), lineWidth: line)
                let pill = CGRect(x: r.midX - w * 0.16, y: r.minY + h * 0.07, width: w * 0.32, height: line * 1.1)
                context.fill(Path(roundedRect: pill, cornerRadius: pill.height / 2), with: .color(palette.ink))
                let box = r.insetBy(dx: -s * 0.08, dy: -s * 0.06)
                context.stroke(Path(box), with: .color(palette.accent), lineWidth: line * 0.4)
                let k = s * 0.07
                for p in [CGPoint(x: box.minX, y: box.minY), CGPoint(x: box.maxX, y: box.minY),
                          CGPoint(x: box.minX, y: box.maxY), CGPoint(x: box.maxX, y: box.maxY)] {
                    let handle = CGRect(x: p.x - k / 2, y: p.y - k / 2, width: k, height: k)
                    context.fill(Path(handle), with: .color(.white))
                    context.stroke(Path(handle), with: .color(palette.accent), lineWidth: line * 0.4)
                }

            case .accolades:
                // { phone } — design written as code.
                let w = s * 0.26, h = s * 0.46
                let r = CGRect(x: (s - w) / 2, y: (s - h) / 2, width: w, height: h)
                context.fill(phone(r), with: .color(palette.ink))
                let fs = s * 0.62
                let brace = { (t: String) in
                    Text(t).font(.system(size: fs, weight: .light, design: .rounded)).foregroundColor(palette.accent)
                }
                context.draw(brace("{"), at: CGPoint(x: s * 0.2, y: s * 0.47))
                context.draw(brace("}"), at: CGPoint(x: s * 0.8, y: s * 0.47))
            }
        }
    }
}

/// macOS app icons sit on a rounded square smaller than the canvas, with a soft shadow.
private struct MacIconTile: View {
    let art: StudioLogoArt
    let size: CGFloat

    var body: some View {
        art
            .frame(width: size * 0.8, height: size * 0.8)
            .clipShape(RoundedRectangle(cornerRadius: size * 0.18, style: .continuous))
            .shadow(color: .black.opacity(0.25), radius: size * 0.04, y: size * 0.02)
            .frame(width: size, height: size)
    }
}

/// Mark + name, as on a website header or the About window.
private struct StudioWordmark: View {
    let art: StudioLogoArt
    var dark = false

    var body: some View {
        HStack(spacing: 10) {
            art.frame(width: 40, height: 40).clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
            HStack(spacing: 0) {
                Text("UI").fontWeight(.heavy)
                Text("Studio").fontWeight(.medium)
            }
            .font(.system(size: 26, design: .rounded))
            .foregroundStyle(dark ? .white : Color(red: 0.10, green: 0.10, blue: 0.14))
        }
    }
}

// MARK: - Screen

struct StudioLogoScreen: StudioScreen {
    static let info = ScreenInfo(
        "Logo",
        project: "UI Studio",
        flow: "Marque",
        order: 100,
        notes: "Logo de UI Studio : icône macOS, Dock, wordmark clair/sombre, petites tailles."
    )

    var body: some View {
        Slot("Concept") {
            Variant("Calques") { StudioLogoPalettes(concept: .calques) }
            Variant("Curseur") { StudioLogoPalettes(concept: .curseur) }
            Variant("Monogramme UI") { StudioLogoPalettes(concept: .monogramme) }
            Variant("Épingle") { StudioLogoPalettes(concept: .pin) }
            Variant("Grille 2×2") { StudioLogoPalettes(concept: .grille) }
            Variant("Canvas") { StudioLogoPalettes(concept: .canvas) }
            Variant("Variantes") { StudioLogoPalettes(concept: .variants) }
            Variant("Sélection") { StudioLogoPalettes(concept: .selection) }
            Variant("Accolades") { StudioLogoPalettes(concept: .accolades) }
        }
    }
}

private struct StudioLogoPalettes: View {
    let concept: StudioLogoConcept

    var body: some View {
        Slot("Couleurs") {
            Variant("Indigo") { StudioLogoGridSlot(concept: concept, palette: .indigo) }
            Variant("Graphite") { StudioLogoGridSlot(concept: concept, palette: .graphite) }
            Variant("Clair") { StudioLogoGridSlot(concept: concept, palette: .clair) }
            Variant("Corail") { StudioLogoGridSlot(concept: concept, palette: .corail) }
        }
    }
}

private struct StudioLogoGridSlot: View {
    let concept: StudioLogoConcept
    let palette: StudioLogoPalette

    var body: some View {
        Slot("Grille") {
            Variant("Avec") { StudioLogoShowcase(art: StudioLogoArt(concept: concept, palette: palette, grid: true)) }
            Variant("Sans") { StudioLogoShowcase(art: StudioLogoArt(concept: concept, palette: palette, grid: false)) }
        }
    }
}

private struct StudioLogoShowcase: View {
    let art: StudioLogoArt

    private let dockApps: [(Color, String)] = [
        (.blue, "safari.fill"), (Color(red: 0.2, green: 0.5, blue: 1.0), "hammer.fill"), (Color(red: 0.85, green: 0.47, blue: 0.34), "sparkles"), (.gray, "terminal.fill"),
    ]

    var body: some View {
        ScrollView {
            VStack(spacing: 26) {
                MacIconTile(art: art, size: 210)
                    .padding(.top, 18)
                    .studioComponent("Logo · grand format")

                // Dock
                HStack(spacing: 8) {
                    ForEach(Array(dockApps.prefix(2).enumerated()), id: \.offset) { _, app in dockApp(app) }
                    MacIconTile(art: art, size: 56)
                        .overlay(alignment: .bottom) { Circle().fill(.white.opacity(0.8)).frame(width: 4, height: 4).offset(y: 6) }
                        .studioComponent("Logo · Dock")
                    ForEach(Array(dockApps.suffix(2).enumerated()), id: \.offset) { _, app in dockApp(app) }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.white.opacity(0.18), in: RoundedRectangle(cornerRadius: 20, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 20, style: .continuous).stroke(.white.opacity(0.25)))

                // Wordmarks
                VStack(spacing: 0) {
                    StudioWordmark(art: art)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)
                        .background(.white)
                    StudioWordmark(art: art, dark: true)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 22)
                        .background(Color(red: 0.09, green: 0.09, blue: 0.11))
                }
                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                .padding(.horizontal, 20)
                .studioComponent("Wordmark")

                // Small sizes
                HStack(alignment: .bottom, spacing: 22) {
                    ForEach([(16.0, "Menu"), (32.0, "Finder"), (64.0, "Launchpad")], id: \.0) { size, label in
                        VStack(spacing: 6) {
                            MacIconTile(art: art, size: size)
                            Text(label).font(.system(size: 10)).foregroundStyle(.white.opacity(0.8))
                        }
                    }
                }
                .padding(14)
                .background(.white.opacity(0.12), in: RoundedRectangle(cornerRadius: 18, style: .continuous))
                .studioComponent("Logo · petites tailles")
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 30)
        }
        .background(
            LinearGradient(colors: [Color(red: 0.30, green: 0.42, blue: 0.62), Color(red: 0.55, green: 0.45, blue: 0.62)], startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()
        )
    }

    private func dockApp(_ app: (Color, String)) -> some View {
        Image(systemName: app.1)
            .font(.system(size: 20, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 45, height: 45)
            .background(app.0.gradient, in: RoundedRectangle(cornerRadius: 10, style: .continuous))
            .frame(width: 56, height: 56)
    }
}
