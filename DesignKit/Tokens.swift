import SwiftUI

/// Design tokens. Screens should use these instead of raw values,
/// so the whole app can be restyled from one place.
enum DS {
    enum Spacing {
        static let xxs: CGFloat = 4
        static let xs: CGFloat = 8
        static let s: CGFloat = 12
        static let m: CGFloat = 16
        static let l: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }

    enum Radius {
        static let s: CGFloat = 8
        static let m: CGFloat = 14
        static let l: CGFloat = 22
    }
}

// MARK: - Colors

extension Color {
    static let dsAccent = Color(red: 1.0, green: 0.36, blue: 0.16)
    static let dsAccentSoft = Color.dsAccent.opacity(0.12)
    static let dsBackground = Color(uiColor: .systemBackground)
    static let dsSurface = Color(uiColor: .secondarySystemBackground)
    static let dsSurfaceRaised = Color(uiColor: .tertiarySystemBackground)
    static let dsTextPrimary = Color(uiColor: .label)
    static let dsTextSecondary = Color(uiColor: .secondaryLabel)
    static let dsBorder = Color(uiColor: .separator)
    static let dsSuccess = Color.green
    static let dsDanger = Color.red
}

extension ShapeStyle where Self == Color {
    static var dsAccent: Color { Color.dsAccent }
    static var dsAccentSoft: Color { Color.dsAccentSoft }
    static var dsBackground: Color { Color.dsBackground }
    static var dsSurface: Color { Color.dsSurface }
    static var dsSurfaceRaised: Color { Color.dsSurfaceRaised }
    static var dsTextPrimary: Color { Color.dsTextPrimary }
    static var dsTextSecondary: Color { Color.dsTextSecondary }
    static var dsBorder: Color { Color.dsBorder }
}

// MARK: - Typography

extension Font {
    static let dsDisplay = Font.system(.largeTitle, design: .rounded, weight: .bold)
    static let dsTitle = Font.system(.title2, design: .rounded, weight: .bold)
    static let dsHeadline = Font.system(.headline, design: .rounded)
    static let dsBody = Font.system(.body)
    static let dsCallout = Font.system(.callout)
    static let dsCaption = Font.system(.caption, weight: .medium)
}
