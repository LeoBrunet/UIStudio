import SwiftUI

struct LoginScreen: StudioScreen {
    static let info = ScreenInfo("Login", flow: "Démo", order: 1100, notes: "Email + password, with Apple sign-in.")

    @State private var email = ""
    @State private var password = ""

    var body: some View {
        VStack(spacing: DS.Spacing.l) {
            Slot("Header") {
                Variant("Minimal") {
                    VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                        Text("Welcome back").font(.dsTitle)
                        Text("Sign in to continue").foregroundStyle(.dsTextSecondary)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, DS.Spacing.xl)
                }
                Variant("Big title") {
                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        DSTag(text: "Lumen")
                        Text("Good to\nsee you again.")
                            .font(.system(size: 44, weight: .heavy, design: .rounded))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.top, DS.Spacing.xxl)
                }
                Variant("Illustration") {
                    VStack(spacing: DS.Spacing.m) {
                        ZStack {
                            Circle().fill(.dsAccentSoft).frame(width: 160, height: 160)
                            Image(systemName: "sparkles")
                                .font(.system(size: 64, weight: .semibold))
                                .foregroundStyle(.dsAccent)
                        }
                        Text("Welcome back").font(.dsTitle)
                    }
                    .padding(.top, DS.Spacing.l)
                }
            }

            Slot("Form") {
                Variant("Stacked") {
                    fields
                }
                Variant("Card") {
                    Slot("Card style") {
                        Variant("Outlined") { fields.dsCard() }
                        Variant("Elevated") { fields.dsCard(elevated: true) }
                    }
                }
            }

            Spacer(minLength: 0)

            VStack(spacing: DS.Spacing.s) {
                Button("Sign in") {}
                    .buttonStyle(.dsPrimary)
                Slot("Alternative sign-in") {
                    Variant("Apple") {
                        Button {} label: {
                            Label("Continue with Apple", systemImage: "apple.logo")
                        }
                        .buttonStyle(.dsSecondary)
                    }
                    Variant("Apple + Google") {
                        HStack(spacing: DS.Spacing.s) {
                            Button {} label: { Label("Apple", systemImage: "apple.logo") }
                            Button {} label: { Label("Google", systemImage: "g.circle.fill") }
                        }
                        .buttonStyle(.dsSecondary)
                    }
                    Variant.hidden
                }
                Button("Create an account") {}
                    .buttonStyle(.dsGhost)
            }
        }
        .padding(.horizontal, DS.Spacing.l)
        .padding(.bottom, DS.Spacing.s)
    }

    private var fields: some View {
        VStack(spacing: DS.Spacing.s) {
            DSTextField(title: "Email", text: $email, icon: "envelope")
            DSTextField(title: "Password", text: $password, icon: "lock", isSecure: true)
            Text("Forgot password?")
                .font(.dsCallout)
                .foregroundStyle(.dsAccent)
                .frame(maxWidth: .infinity, alignment: .trailing)
        }
    }
}
