import SwiftUI

// Mockups of UI Studio's top bar, drawn in a macOS window at 1:1 (static: nothing here drives the real app).

// MARK: - Screen

struct StudioTopBarScreen: StudioScreen {
    static let info = ScreenInfo(
        "Barre d'outils",
        project: "UI Studio",
        flow: "Interface",
        order: 200,
        notes: "Propositions pour la barre du haut, dans une fenêtre macOS à l'échelle 1:1.",
        frame: .mac(width: 1200, height: 760)
    )

    var body: some View {
        Slot("Barre") {
            Variant("Îlot + mode") { MacWindowMock(layout: .floating) { BarFloatingMode() } }
            Variant("Trois îlots") { MacWindowMock(layout: .floating) { BarThreeIslands() } }
            Variant("Îlot en bas") { MacWindowMock(layout: .floatingBottom) { BarFloatingBottom() } }
            Variant("Îlot sombre") { MacWindowMock(layout: .floating) { BarFloatingDark() } }
            Variant("macOS natif") { MacWindowMock(layout: .sidebarFullHeight) { BarNative(showsTitle: false) } }
            Variant("Trois zones") { MacWindowMock(layout: .toolbarOnTop) { BarThreeZones(prominentMode: true) } }
            Variant("Îlot flottant") { MacWindowMock(layout: .floating) { BarFloating() } }
            Variant("macOS natif (v1)") { MacWindowMock(layout: .sidebarFullHeight) { BarNative() } }
            Variant("Trois zones (v1)") { MacWindowMock(layout: .toolbarOnTop) { BarThreeZones() } }
            Variant("Fil d'Ariane") { MacWindowMock(layout: .toolbarOnTop) { BarBreadcrumb() } }
            Variant("Icônes") { MacWindowMock(layout: .toolbarOnTop) { BarIcons() } }
            Variant("Actuelle (v1)") { MacWindowMock(layout: .toolbarOnTop) { BarCurrent() } }
        }
    }
}

// MARK: - Window

private enum WindowLayout {
    /// Unified toolbar across the whole window, traffic lights inside it.
    case toolbarOnTop
    /// Sidebar runs full height with the traffic lights; the toolbar starts after it (Finder, Xcode, Notes).
    case sidebarFullHeight
    /// No toolbar: traffic lights in the sidebar, controls float over the canvas.
    case floating
    /// Same, controls float at the bottom of the canvas (Freeform, Figma UI3).
    case floatingBottom
}

private struct MacWindowMock<Bar: View>: View {
    let layout: WindowLayout
    @ViewBuilder let bar: () -> Bar

    var body: some View {
        VStack(spacing: 0) {
            if layout == .toolbarOnTop {
                HStack(spacing: 0) {
                    TrafficLights().padding(.leading, 20).padding(.trailing, 16)
                    bar()
                }
                .frame(height: 52)
                .background(MacColors.toolbar)
                .overlay(alignment: .bottom) { Rectangle().fill(MacColors.separator).frame(height: 1) }
                .studioComponent("Barre d'outils")
            }
            HStack(spacing: 0) {
                MockSidebar(showsTrafficLights: layout != .toolbarOnTop)
                VStack(spacing: 0) {
                    if layout == .sidebarFullHeight {
                        bar()
                            .frame(height: 52)
                            .background(MacColors.canvas)
                            .studioComponent("Barre d'outils")
                    }
                    ZStack(alignment: layout == .floatingBottom ? .bottom : .top) {
                        MockCanvas()
                        if layout == .floating {
                            bar().padding(.top, 14).studioComponent("Barre d'outils")
                        } else if layout == .floatingBottom {
                            bar().padding(.bottom, 18).studioComponent("Barre d'outils")
                        }
                    }
                }
                MockInspector()
            }
        }
        .font(.system(size: 13))
        .background(MacColors.canvas)
        .ignoresSafeArea()
    }
}

private enum MacColors {
    static let toolbar = Color(red: 0.965, green: 0.965, blue: 0.97)
    static let sidebar = Color(red: 0.94, green: 0.94, blue: 0.95)
    static let canvas = Color(red: 0.91, green: 0.91, blue: 0.92)
    static let separator = Color.black.opacity(0.1)
    static let blue = Color(red: 0.0, green: 0.48, blue: 1.0)
}

private struct TrafficLights: View {
    var body: some View {
        HStack(spacing: 8) {
            ForEach([Color(red: 1.0, green: 0.37, blue: 0.34), Color(red: 1.0, green: 0.74, blue: 0.18), Color(red: 0.16, green: 0.79, blue: 0.25)], id: \.self) { c in
                Circle().fill(c).overlay(Circle().stroke(.black.opacity(0.12), lineWidth: 0.5)).frame(width: 12, height: 12)
            }
        }
    }
}

private struct MockSidebar: View {
    let showsTrafficLights: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if showsTrafficLights {
                TrafficLights().frame(height: 52).padding(.leading, 8)
            } else {
                Spacer().frame(height: 10)
            }
            section("MARQUE")
            row("Logo", selected: false)
            section("INTERFACE")
            row("Barre d'outils", selected: true)
            Spacer()
            Text("Built 14:02").font(.system(size: 11)).foregroundStyle(.secondary).padding(8)
        }
        .padding(.horizontal, 12)
        .frame(width: 210)
        .frame(maxHeight: .infinity)
        .background(MacColors.sidebar)
        .overlay(alignment: .trailing) { Rectangle().fill(MacColors.separator).frame(width: 1) }
        .studioComponent("Barre latérale")
    }

    private func section(_ t: String) -> some View {
        Text(t).font(.system(size: 11, weight: .semibold)).foregroundStyle(.secondary).padding(.top, 14).padding(.bottom, 4).padding(.horizontal, 8)
    }

    private func row(_ t: String, selected: Bool) -> some View {
        HStack(spacing: 7) {
            Image(systemName: "iphone")
            Text(t)
            Spacer()
        }
        .foregroundStyle(selected ? .white : .primary)
        .padding(.horizontal, 8).frame(height: 26)
        .background(selected ? MacColors.blue : .clear, in: RoundedRectangle(cornerRadius: 6))
    }
}

private struct MockCanvas: View {
    var body: some View {
        HStack(alignment: .top, spacing: 36) {
            ForEach(0..<3) { i in
                VStack(alignment: .leading, spacing: 8) {
                    Text(["Logo", "Aujourd'hui", "Programme"][i]).font(.system(size: 12, weight: .medium)).foregroundStyle(i == 1 ? MacColors.blue : .secondary)
                    RoundedRectangle(cornerRadius: 30, style: .continuous)
                        .fill(.white)
                        .overlay(RoundedRectangle(cornerRadius: 30, style: .continuous).stroke(Color(white: 0.1), lineWidth: 7))
                        .frame(width: 180, height: 390)
                        .padding(4)
                        .overlay(RoundedRectangle(cornerRadius: 34, style: .continuous).stroke(i == 1 ? MacColors.blue : .clear, lineWidth: 3))
                }
            }
        }
        .padding(.top, 90)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .background(MacColors.canvas)
    }
}

private struct MockInspector: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text("Aujourd'hui").font(.system(size: 15, weight: .semibold))
                Text("Quotidien").foregroundStyle(.secondary)
            }
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(.white, in: RoundedRectangle(cornerRadius: 10))
            VStack(alignment: .leading, spacing: 8) {
                Text("Slots").font(.system(size: 13, weight: .semibold))
                ForEach(["En-tête", "Séance du jour", "Récupération"], id: \.self) { s in
                    HStack { Image(systemName: "square.dashed"); Text(s); Spacer() }.foregroundStyle(.primary.opacity(0.8))
                }
            }
            .padding(12).frame(maxWidth: .infinity, alignment: .leading)
            .background(.white, in: RoundedRectangle(cornerRadius: 10))
            Spacer()
        }
        .padding(12)
        .padding(.top, 8)
        .frame(width: 250)
        .frame(maxHeight: .infinity)
        .background(MacColors.sidebar)
        .overlay(alignment: .leading) { Rectangle().fill(MacColors.separator).frame(width: 1) }
        .studioComponent("Inspecteur")
    }
}

// MARK: - Mac controls (regular size)

/// AppKit-style segmented control: 24 pt high, rounded, selected segment raised.
private struct MacSegmented: View {
    let items: [String]
    var selected = 0
    var icons = false

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.offset) { i, item in
                Group {
                    if icons { Image(systemName: item) } else { Text(item) }
                }
                .font(.system(size: 13, weight: i == selected ? .medium : .regular))
                .padding(.horizontal, icons ? 9 : 12)
                .frame(height: 20)
                .background(i == selected ? .white : .clear, in: RoundedRectangle(cornerRadius: 5, style: .continuous))
                .shadow(color: .black.opacity(i == selected ? 0.15 : 0), radius: 1, y: 0.5)
            }
        }
        .padding(2)
        .background(.black.opacity(0.07), in: RoundedRectangle(cornerRadius: 7, style: .continuous))
    }
}

/// Toolbar icon button: 30×28 hit area, tinted background when active.
private struct MacToolbarIcon: View {
    let symbol: String
    var active = false

    var body: some View {
        Image(systemName: symbol)
            .font(.system(size: 15, weight: .regular))
            .foregroundStyle(active ? MacColors.blue : .primary.opacity(0.7))
            .frame(width: 30, height: 28)
            .background(active ? MacColors.blue.opacity(0.12) : .clear, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
    }
}

/// Pop-up button (menu with up/down chevrons), as in a Mac toolbar.
private struct MacPopUp: View {
    var symbol: String?
    let text: String
    var bold = false
    var bordered = true

    var body: some View {
        HStack(spacing: 5) {
            if let symbol { Image(systemName: symbol).foregroundStyle(.primary.opacity(0.7)) }
            Text(text).fontWeight(bold ? .semibold : .regular)
            Image(systemName: "chevron.up.chevron.down").font(.system(size: 9, weight: .semibold)).foregroundStyle(.secondary)
        }
        .font(.system(size: 13))
        .padding(.horizontal, bordered ? 8 : 2)
        .frame(height: 24)
        .background(bordered ? .white : .clear, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
        .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(.black.opacity(bordered ? 0.12 : 0), lineWidth: 0.5))
    }
}

private struct MacZoom: View {
    var body: some View {
        HStack(spacing: 0) {
            MacToolbarIcon(symbol: "minus.magnifyingglass")
            Text("49 %").font(.system(size: 12).monospacedDigit()).foregroundStyle(.secondary).frame(width: 40)
            MacToolbarIcon(symbol: "plus.magnifyingglass")
        }
    }
}

private struct MacCommentButton: View {
    var body: some View {
        Label("Commenter", systemImage: "bubble.left")
            .font(.system(size: 13))
            .padding(.horizontal, 10)
            .frame(height: 24)
            .background(.white, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(.black.opacity(0.12), lineWidth: 0.5))
    }
}

/// Small UI Studio mark for bars that show the app identity.
private struct MiniMark: View {
    var body: some View {
        StudioLogoArt(concept: .canvas, palette: .indigo, grid: false)
            .frame(width: 20, height: 20)
            .clipShape(RoundedRectangle(cornerRadius: 5, style: .continuous))
    }
}

// MARK: - Bars

/// Finder/Xcode style: title + subtitle, grouped capsules on the right.
private struct BarNative: View {
    /// v1 showed the screen title + project; dropped after feedback (the sidebar already says it).
    var showsTitle = true

    var body: some View {
        HStack(spacing: 10) {
            MacToolbarIcon(symbol: "sidebar.leading")
            if showsTitle {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Barre d'outils").font(.system(size: 14, weight: .semibold))
                    Text("UI Studio · Interface").font(.system(size: 11)).foregroundStyle(.secondary)
                }
                .studioComponent("Titre")
            } else {
                MacPopUp(text: "UI Studio", bold: true, bordered: false).studioComponent("Projet")
            }
            Spacer()
            MacSegmented(items: ["Canvas", "Variantes"])
            Spacer()
            capsule {
                MacToolbarIcon(symbol: "iphone")
                MacToolbarIcon(symbol: "circle.lefthalf.filled")
            }
            .studioComponent("Aperçu")
            capsule { MacZoom() }
            capsule {
                MacToolbarIcon(symbol: "bubble.left")
                MacToolbarIcon(symbol: "sidebar.trailing")
            }
        }
        .padding(.horizontal, 14)
        .studioComponent("Barre · macOS natif")
    }

    private func capsule<C: View>(@ViewBuilder _ content: () -> C) -> some View {
        HStack(spacing: 0, content: content)
            .padding(.horizontal, 4)
            .background(.white.opacity(0.9), in: Capsule())
            .overlay(Capsule().stroke(.black.opacity(0.08)))
    }
}

/// Today's bar, reproduced.
private struct BarCurrent: View {
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "sidebar.leading").foregroundStyle(MacColors.blue)
            HStack(spacing: 4) {
                Image(systemName: "folder"); Text("UI Studio").fontWeight(.semibold)
                Image(systemName: "chevron.down").font(.system(size: 9, weight: .bold))
            }
            .foregroundStyle(MacColors.blue)
            MacSegmented(items: ["Canvas", "Variants"], selected: 1)
            Label("iPhone 17 Pro Max", systemImage: "iphone").foregroundStyle(MacColors.blue)
            MacSegmented(items: ["Light", "Dark"])
            Spacer()
            HStack(spacing: 8) { Image(systemName: "minus"); Text("49%"); Image(systemName: "plus") }.foregroundStyle(MacColors.blue)
            Label("Commenter", systemImage: "bubble.left").foregroundStyle(MacColors.blue)
            Image(systemName: "sidebar.trailing").foregroundStyle(MacColors.blue)
        }
        .padding(.trailing, 14)
        .studioComponent("Barre · actuelle")
    }
}

/// Left: identity + where you are. Center: mode. Right: preview settings + actions.
private struct BarThreeZones: View {
    /// Bigger, accent-filled mode switch (feedback: the mode must stand out more).
    var prominentMode = false

    var body: some View {
        ZStack {
            Group {
                if prominentMode { ModeSwitch() } else { MacSegmented(items: ["Canvas", "Variantes"]) }
            }
            .studioComponent("Mode")
            HStack(spacing: 10) {
                MacToolbarIcon(symbol: "sidebar.leading")
                MiniMark()
                MacPopUp(text: "UI Studio", bold: true, bordered: false)
                Image(systemName: "chevron.right").font(.system(size: 10, weight: .semibold)).foregroundStyle(.tertiary)
                Text("Barre d'outils").foregroundStyle(.secondary)
                Spacer()
                HStack(spacing: 6) {
                    Image(systemName: "iphone")
                    Text("17 Pro Max")
                    Rectangle().fill(.black.opacity(0.15)).frame(width: 1, height: 14)
                    Image(systemName: "sun.max")
                    Image(systemName: "chevron.up.chevron.down").font(.system(size: 9, weight: .semibold)).foregroundStyle(.secondary)
                }
                .padding(.horizontal, 9).frame(height: 24)
                .background(.white, in: RoundedRectangle(cornerRadius: 6, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 6, style: .continuous).stroke(.black.opacity(0.12), lineWidth: 0.5))
                .studioComponent("Aperçu (appareil + thème)")
                MacZoom()
                MacCommentButton()
                MacToolbarIcon(symbol: "sidebar.trailing")
            }
        }
        .padding(.trailing, 14)
        .studioComponent("Barre · trois zones")
    }
}

/// A centered capsule floating over the canvas.
private struct BarFloating: View {
    var body: some View {
        HStack(spacing: 4) {
            MacToolbarIcon(symbol: "sidebar.leading")
            divider
            MacPopUp(text: "UI Studio", bold: true, bordered: false)
            divider
            MacToolbarIcon(symbol: "rectangle.3.group", active: true)
            MacToolbarIcon(symbol: "square.grid.3x3")
            divider
            MacToolbarIcon(symbol: "iphone")
            MacToolbarIcon(symbol: "circle.lefthalf.filled")
            divider
            MacZoom()
            divider
            MacToolbarIcon(symbol: "bubble.left")
            MacToolbarIcon(symbol: "sidebar.trailing")
        }
        .padding(.horizontal, 8)
        .frame(height: 40)
        .background(.white, in: Capsule())
        .overlay(Capsule().stroke(.black.opacity(0.08)))
        .shadow(color: .black.opacity(0.14), radius: 12, y: 4)
        .studioComponent("Barre · îlot flottant")
    }

    private var divider: some View { Rectangle().fill(.black.opacity(0.12)).frame(width: 1, height: 18).padding(.horizontal, 2) }
}

/// Breadcrumb title with underline tabs.
private struct BarBreadcrumb: View {
    var body: some View {
        HStack(spacing: 14) {
            MacToolbarIcon(symbol: "sidebar.leading")
            HStack(spacing: 6) {
                MiniMark()
                Text("UI Studio").fontWeight(.semibold)
                Text("/").foregroundStyle(.tertiary)
                Text("Interface").foregroundStyle(.secondary)
                Text("/").foregroundStyle(.tertiary)
                Text("Barre d'outils").fontWeight(.semibold)
                Image(systemName: "chevron.up.chevron.down").font(.system(size: 9)).foregroundStyle(.secondary)
            }
            .studioComponent("Fil d'Ariane")
            HStack(spacing: 18) {
                tab("Canvas", selected: true)
                tab("Variantes", selected: false)
            }
            .padding(.leading, 10)
            .studioComponent("Onglets")
            Spacer()
            MacPopUp(symbol: "iphone", text: "iPhone 17 Pro Max")
            MacSegmented(items: ["sun.max", "moon"], icons: true)
            MacZoom()
            MacCommentButton()
            MacToolbarIcon(symbol: "sidebar.trailing")
        }
        .padding(.trailing, 14)
        .studioComponent("Barre · fil d'Ariane")
    }

    private func tab(_ title: String, selected: Bool) -> some View {
        Text(title)
            .fontWeight(selected ? .semibold : .regular)
            .foregroundStyle(selected ? .primary : .secondary)
            .frame(height: 52)
            .overlay(alignment: .bottom) {
                if selected { Rectangle().fill(MacColors.blue).frame(height: 2) }
            }
    }
}

/// Icon-only, one group; accent only on active state.
private struct BarIcons: View {
    var body: some View {
        HStack(spacing: 4) {
            MacToolbarIcon(symbol: "sidebar.leading", active: true)
            MacPopUp(symbol: "folder", text: "UI Studio", bold: true, bordered: false).padding(.horizontal, 6)
            Spacer()
            HStack(spacing: 2) {
                MacToolbarIcon(symbol: "rectangle.3.group", active: true)
                MacToolbarIcon(symbol: "square.grid.3x3")
                separator
                MacToolbarIcon(symbol: "iphone")
                MacToolbarIcon(symbol: "sun.max")
                separator
                MacZoom()
                separator
                MacToolbarIcon(symbol: "bubble.left")
            }
            .padding(2)
            .background(.black.opacity(0.04), in: RoundedRectangle(cornerRadius: 8, style: .continuous))
            .studioComponent("Groupe d'outils")
            Spacer()
            MacToolbarIcon(symbol: "sidebar.trailing", active: true)
        }
        .padding(.trailing, 14)
        .studioComponent("Barre · icônes")
    }

    private var separator: some View { Rectangle().fill(.black.opacity(0.12)).frame(width: 1, height: 16).padding(.horizontal, 4) }
}

// MARK: - Prominent mode switch

/// Canvas / Variantes as the main control: 32 pt, icon + label, selected segment filled with the accent.
private struct ModeSwitch: View {
    var dark = false
    var compact = false

    var body: some View {
        HStack(spacing: 2) {
            segment("Canvas", symbol: "rectangle.3.group", selected: true)
            segment("Variantes", symbol: "square.grid.3x3", selected: false)
        }
        .padding(3)
        .background(dark ? .white.opacity(0.1) : .black.opacity(0.06), in: Capsule())
    }

    private func segment(_ title: String, symbol: String, selected: Bool) -> some View {
        HStack(spacing: 6) {
            Image(systemName: symbol).font(.system(size: 13, weight: .semibold))
            Text(title).font(.system(size: 13, weight: .semibold))
            if !compact {
                Text(selected ? "⌘1" : "⌘2").font(.system(size: 10, weight: .medium)).opacity(0.6)
            }
        }
        .foregroundStyle(selected ? .white : (dark ? .white.opacity(0.75) : .primary.opacity(0.75)))
        .padding(.horizontal, 14)
        .frame(height: 28)
        .background(selected ? MacColors.blue : .clear, in: Capsule())
        .shadow(color: MacColors.blue.opacity(selected ? 0.35 : 0), radius: 4, y: 1)
    }
}

// MARK: - Floating family (feedback: "I like this style")

private struct Island<C: View>: View {
    var dark = false
    @ViewBuilder let content: () -> C

    var body: some View {
        HStack(spacing: 4, content: content)
            .padding(.horizontal, 6)
            .frame(height: 40)
            .background(dark ? Color(red: 0.13, green: 0.13, blue: 0.15).opacity(0.94) : .white, in: Capsule())
            .overlay(Capsule().stroke(dark ? .white.opacity(0.1) : .black.opacity(0.08)))
            .shadow(color: .black.opacity(dark ? 0.3 : 0.14), radius: 12, y: 4)
    }
}

private struct IslandDivider: View {
    var dark = false
    var body: some View { Rectangle().fill(dark ? .white.opacity(0.15) : .black.opacity(0.12)).frame(width: 1, height: 18).padding(.horizontal, 2) }
}

/// The liked floating island, with the mode switch as its centerpiece.
private struct BarFloatingMode: View {
    var body: some View {
        Island {
            MacToolbarIcon(symbol: "sidebar.leading")
            MacPopUp(text: "UI Studio", bold: true, bordered: false)
            IslandDivider()
            ModeSwitch(compact: true).padding(.horizontal, 4).studioComponent("Mode")
            IslandDivider()
            MacToolbarIcon(symbol: "iphone")
            MacToolbarIcon(symbol: "circle.lefthalf.filled")
            IslandDivider()
            MacZoom()
            IslandDivider()
            MacToolbarIcon(symbol: "bubble.left")
            MacToolbarIcon(symbol: "sidebar.trailing")
        }
        .studioComponent("Barre · îlot + mode")
    }
}

/// Three islands: navigation left, mode centered, preview + actions right.
private struct BarThreeIslands: View {
    var body: some View {
        HStack(spacing: 10) {
                Island {
                    MacToolbarIcon(symbol: "sidebar.leading")
                    MacPopUp(text: "UI Studio", bold: true, bordered: false).padding(.trailing, 4)
                }
                .studioComponent("Îlot · projet")
                Spacer(minLength: 0)
                Island { ModeSwitch(compact: true) }.studioComponent("Mode")
                Spacer(minLength: 0)
                Island {
                    MacToolbarIcon(symbol: "iphone")
                    MacToolbarIcon(symbol: "circle.lefthalf.filled")
                    IslandDivider()
                    MacToolbarIcon(symbol: "plus.magnifyingglass")
                    IslandDivider()
                    MacToolbarIcon(symbol: "bubble.left")
                    MacToolbarIcon(symbol: "sidebar.trailing")
                }
                .studioComponent("Îlot · aperçu")
        }
        .padding(.horizontal, 14)
        .studioComponent("Barre · trois îlots")
    }
}

/// The island at the bottom of the canvas, closer to the phones; project stays top-left.
private struct BarFloatingBottom: View {
    var body: some View {
        Island {
            ModeSwitch(compact: true).studioComponent("Mode")
            IslandDivider()
            MacToolbarIcon(symbol: "iphone")
            MacToolbarIcon(symbol: "circle.lefthalf.filled")
            IslandDivider()
            MacZoom()
            IslandDivider()
            HStack(spacing: 5) {
                Image(systemName: "bubble.left.fill")
                Text("Commenter").font(.system(size: 13, weight: .medium))
            }
            .padding(.horizontal, 10)
            .frame(height: 28)
            .background(Color.orange.opacity(0.15), in: Capsule())
            .foregroundStyle(Color.orange)
        }
        .studioComponent("Barre · îlot en bas")
    }
}

/// Dark glass island, reads well over both light and dark canvases.
private struct BarFloatingDark: View {
    var body: some View {
        Island(dark: true) {
            Image(systemName: "sidebar.leading").font(.system(size: 15)).foregroundStyle(.white.opacity(0.8)).frame(width: 30, height: 28)
            Text("UI Studio").font(.system(size: 13, weight: .semibold)).foregroundStyle(.white)
            Image(systemName: "chevron.up.chevron.down").font(.system(size: 9, weight: .semibold)).foregroundStyle(.white.opacity(0.5))
            IslandDivider(dark: true)
            ModeSwitch(dark: true, compact: true).padding(.horizontal, 4).studioComponent("Mode")
            IslandDivider(dark: true)
            ForEach(["iphone", "circle.lefthalf.filled", "minus.magnifyingglass"], id: \.self) { sym in
                Image(systemName: sym).font(.system(size: 15)).foregroundStyle(.white.opacity(0.8)).frame(width: 30, height: 28)
            }
            Text("49 %").font(.system(size: 12).monospacedDigit()).foregroundStyle(.white.opacity(0.6))
            Image(systemName: "plus.magnifyingglass").font(.system(size: 15)).foregroundStyle(.white.opacity(0.8)).frame(width: 30, height: 28)
            IslandDivider(dark: true)
            Image(systemName: "bubble.left").font(.system(size: 15)).foregroundStyle(.white.opacity(0.8)).frame(width: 30, height: 28)
        }
        .studioComponent("Barre · îlot sombre")
    }
}
