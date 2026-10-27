import SwiftUI

// MARK: - Buttons

struct DSButtonStyle: ButtonStyle {
    enum Kind { case primary, secondary, ghost }
    var kind: Kind = .primary

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.dsHeadline)
            .frame(maxWidth: .infinity)
            .padding(.vertical, DS.Spacing.m)
            .foregroundStyle(foreground)
            .background(background, in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
            .overlay {
                if kind == .secondary {
                    RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous).stroke(Color.dsBorder)
                }
            }
            .opacity(configuration.isPressed ? 0.75 : 1)
            .scaleEffect(configuration.isPressed ? 0.98 : 1)
            .animation(.snappy(duration: 0.15), value: configuration.isPressed)
    }

    private var foreground: Color {
        switch kind {
        case .primary: .white
        case .secondary: .dsTextPrimary
        case .ghost: .dsAccent
        }
    }

    private var background: Color {
        switch kind {
        case .primary: .dsAccent
        case .secondary: .dsBackground
        case .ghost: .clear
        }
    }
}

extension ButtonStyle where Self == DSButtonStyle {
    static var dsPrimary: DSButtonStyle { DSButtonStyle(kind: .primary) }
    static var dsSecondary: DSButtonStyle { DSButtonStyle(kind: .secondary) }
    static var dsGhost: DSButtonStyle { DSButtonStyle(kind: .ghost) }
}

// MARK: - Text field

struct DSTextField: View {
    let title: String
    @Binding var text: String
    var icon: String?
    var isSecure = false

    var body: some View {
        HStack(spacing: DS.Spacing.s) {
            if let icon {
                Image(systemName: icon).foregroundStyle(.dsTextSecondary)
            }
            Group {
                if isSecure {
                    SecureField(title, text: $text)
                } else {
                    TextField(title, text: $text)
                }
            }
            .font(.dsBody)
        }
        .padding(.horizontal, DS.Spacing.m)
        .padding(.vertical, DS.Spacing.s + 2)
        .background(Color.dsSurface, in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
        .studioComponent("Champ · \(title)")
    }
}

// MARK: - Card

extension View {
    func dsCard(padding: CGFloat = DS.Spacing.m, elevated: Bool = false) -> some View {
        self
            .padding(padding)
            .background(Color.dsSurfaceRaised, in: RoundedRectangle(cornerRadius: DS.Radius.l, style: .continuous))
            .overlay {
                RoundedRectangle(cornerRadius: DS.Radius.l, style: .continuous)
                    .stroke(Color.dsBorder.opacity(elevated ? 0 : 0.6))
            }
            .shadow(color: .black.opacity(elevated ? 0.12 : 0), radius: 18, y: 8)
            .studioComponent("Carte")
    }
}

// MARK: - Small pieces

struct DSAvatar: View {
    let initials: String
    var size: CGFloat = 40
    var color: Color = .dsAccent

    var body: some View {
        Text(initials)
            .font(.system(size: size * 0.38, weight: .semibold, design: .rounded))
            .foregroundStyle(.white)
            .frame(width: size, height: size)
            .background(color.gradient, in: Circle())
            .studioComponent("Avatar")
    }
}

struct DSTag: View {
    let text: String
    var color: Color = .dsAccent

    var body: some View {
        Text(text)
            .font(.dsCaption)
            .padding(.horizontal, DS.Spacing.xs)
            .padding(.vertical, DS.Spacing.xxs)
            .foregroundStyle(color)
            .background(color.opacity(0.12), in: Capsule())
            .studioComponent("Tag · \(text)")
    }
}

struct DSSectionHeader: View {
    let title: String
    var action: String?

    var body: some View {
        HStack {
            Text(title).font(.dsHeadline)
            Spacer()
            if let action {
                Text(action).font(.dsCallout).foregroundStyle(.dsAccent)
            }
        }
        .studioComponent("En-tête · \(title)")
    }
}
