import SwiftUI

struct ConnectClaudeScreen: StudioScreen {
    static let info = ScreenInfo(
        "Connecter Claude",
        flow: "Onboarding",
        order: 200,
        notes: "Option B : le coach vit dans l'app Claude (plan Pro). L'utilisateur ajoute notre connecteur MCP dans Claude."
    )

    var body: some View {
        VStack(alignment: .leading, spacing: DS.Spacing.l) {
            Slot("En-tête") {
                Variant("Icônes reliées") {
                    VStack(alignment: .leading, spacing: DS.Spacing.m) {
                        HStack(spacing: DS.Spacing.s) {
                            appIcon("figure.run", Color.dsAccent)
                            Image(systemName: "arrow.left.arrow.right")
                                .font(.title3.weight(.semibold))
                                .foregroundStyle(.dsTextSecondary)
                            Slot("Icône Claude") {
                                Variant("Logo Claude") {
                                    ClaudeMark()
                                        .padding(9)
                                        .frame(width: 60, height: 60)
                                        .background(Color.claudeCream, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                                        .overlay(RoundedRectangle(cornerRadius: 15, style: .continuous).stroke(Color.claudeCoral.opacity(0.25)))
                                }
                                Variant("Logo Claude (tuile corail)") {
                                    ClaudeMark(color: .white)
                                        .padding(9)
                                        .frame(width: 60, height: 60)
                                        .background(Color.claudeCoral.gradient, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
                                }
                                Variant("Sparkle (v1)") {
                                    appIcon("sparkles", .claudeCoral)
                                }
                            }
                        }
                        Text("Connecte ton coach").font(.dsDisplay)
                        Text("Ton coach, c'est Claude. Il lit tes données Santé et ton programme, et tu lui parles directement dans l'app Claude.")
                            .font(.dsBody)
                            .foregroundStyle(.dsTextSecondary)
                    }
                }
                Variant("Titre seul") {
                    VStack(alignment: .leading, spacing: DS.Spacing.s) {
                        Text("Dernière étape").font(.dsCallout.weight(.semibold)).foregroundStyle(.dsAccent)
                        Text("Relie Claude\nà ton entraînement").font(.system(size: 34, weight: .heavy, design: .rounded))
                    }
                }
            }
            .padding(.top, DS.Spacing.l)

            VStack(spacing: DS.Spacing.s) {
                step(1, done: true, title: "Apple Santé autorisé", detail: "Séances, fréquence cardiaque, sommeil, VFC") { EmptyView() }
                step(2, done: false, title: "Ajoute le connecteur dans Claude", detail: "Paramètres › Connecteurs › Ajouter un connecteur personnalisé") {
                    HStack {
                        Text("https://coach.example.app/mcp")
                            .font(.system(.callout, design: .monospaced))
                            .lineLimit(1)
                            .truncationMode(.middle)
                        Spacer()
                        Button {} label: { Image(systemName: "doc.on.doc") }
                            .foregroundStyle(.dsAccent)
                    }
                    .padding(DS.Spacing.s)
                    .background(Color.dsBackground, in: RoundedRectangle(cornerRadius: DS.Radius.s, style: .continuous))
                }
                step(3, done: false, title: "Dis bonjour à ton coach", detail: "Il te posera quelques questions pour bâtir ton programme.") { EmptyView() }
            }

            Spacer(minLength: 0)

            Slot("Statut") {
                Variant("En attente") {
                    HStack(spacing: DS.Spacing.s) {
                        ProgressView()
                        Text("En attente de la première connexion de Claude…")
                            .font(.dsCallout)
                            .foregroundStyle(.dsTextSecondary)
                    }
                    .frame(maxWidth: .infinity)
                }
                Variant("Connecté") {
                    HStack(spacing: DS.Spacing.s) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).font(.title3)
                        VStack(alignment: .leading) {
                            Text("Claude est connecté").font(.dsHeadline)
                            Text("Il a lu 6 mois de séances").font(.dsCallout).foregroundStyle(.dsTextSecondary)
                        }
                        Spacer()
                    }
                    .padding(DS.Spacing.s)
                    .background(Color.green.opacity(0.12), in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
                }
            }

            CoachButton(title: "Ouvrir Claude")
        }
        .padding(.horizontal, DS.Spacing.l)
        .padding(.bottom, DS.Spacing.s)
    }

    private func appIcon(_ symbol: String, _ color: Color) -> some View {
        Image(systemName: symbol)
            .font(.system(size: 26, weight: .semibold))
            .foregroundStyle(.white)
            .frame(width: 60, height: 60)
            .background(color.gradient, in: RoundedRectangle(cornerRadius: 15, style: .continuous))
    }

    private func step<Extra: View>(_ number: Int, done: Bool, title: String, detail: String, @ViewBuilder extra: () -> Extra) -> some View {
        HStack(alignment: .top, spacing: DS.Spacing.s) {
            Group {
                if done {
                    Image(systemName: "checkmark").font(.caption.weight(.bold))
                } else {
                    Text("\(number)").font(.system(.callout, design: .rounded, weight: .bold))
                }
            }
            .foregroundStyle(done ? .white : .dsTextPrimary)
            .frame(width: 28, height: 28)
            .background(done ? Color.green : Color.dsBackground, in: Circle())
            VStack(alignment: .leading, spacing: DS.Spacing.xs) {
                Text(title).font(.dsHeadline).strikethrough(done, color: .dsTextSecondary)
                Text(detail).font(.dsCallout).foregroundStyle(.dsTextSecondary)
                extra()
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(DS.Spacing.s)
        .background(Color.dsSurface, in: RoundedRectangle(cornerRadius: DS.Radius.m, style: .continuous))
    }
}
