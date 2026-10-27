import SwiftUI

/// Placeholder drawing of the Claude mark (coral starburst).
/// For production, replace with the official asset from Anthropic's brand kit.
struct ClaudeMark: View {
    var color: Color = .claudeCoral

    /// (length relative to the radius, angle jitter in degrees): irregular, hand-drawn feel.
    private static let rays: [(CGFloat, Double)] = [
        (1.0, 0), (0.80, 4), (0.94, -3), (0.78, 2), (0.99, 5), (0.74, -2),
        (0.90, 3), (0.83, -4), (0.97, 1), (0.77, -3), (0.92, 4), (0.85, -1),
    ]

    var body: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = min(size.width, size.height) / 2
            for (index, ray) in Self.rays.enumerated() {
                let angle = (Double(index) / Double(Self.rays.count) * 360 + ray.1 - 90) * .pi / 180
                let length = radius * ray.0
                let base = radius * 0.22, tip = radius * 0.055
                // Tapered ray: wide at the center, narrower and rounded at the tip.
                let direction = CGPoint(x: cos(angle), y: sin(angle))
                let normal = CGPoint(x: -direction.y, y: direction.x)
                let tipCenter = CGPoint(x: center.x + direction.x * (length - tip), y: center.y + direction.y * (length - tip))
                var path = Path()
                path.move(to: CGPoint(x: center.x + normal.x * base / 2, y: center.y + normal.y * base / 2))
                path.addLine(to: CGPoint(x: tipCenter.x + normal.x * tip, y: tipCenter.y + normal.y * tip))
                path.addArc(center: tipCenter, radius: tip, startAngle: .radians(angle + .pi / 2), endAngle: .radians(angle - .pi / 2), clockwise: true)
                path.addLine(to: CGPoint(x: center.x - normal.x * base / 2, y: center.y - normal.y * base / 2))
                path.closeSubpath()
                context.fill(path, with: .color(color))
            }
            let hub = radius * 0.16
            context.fill(Path(ellipseIn: CGRect(x: center.x - hub, y: center.y - hub, width: hub * 2, height: hub * 2)), with: .color(color))
        }
        .aspectRatio(1, contentMode: .fit)
        .accessibilityLabel("Claude")
        .studioComponent("Logo Claude")
    }
}

extension Color {
    static let claudeCoral = Color(red: 0.85, green: 0.47, blue: 0.34)
    static let claudeCream = Color(red: 0.96, green: 0.94, blue: 0.90)
}
