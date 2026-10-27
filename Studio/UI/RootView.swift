import SwiftUI

/// App chrome is built by hand (no NavigationSplitView / NavigationStack) on purpose:
/// any UIKit navigation container here would swallow the navigation bars of the
/// screens rendered inside the phones.
///
/// Responsive: sidebar and inspector are docked when the window is wide enough,
/// otherwise they open as floating panels over the canvas.
struct RootView: View {
    @Environment(StudioStore.self) private var store
    @State private var floatingSidebar = false
    @State private var floatingInspector = false

    static let sidebarWidth: CGFloat = 230
    static let inspectorWidth: CGFloat = 300
    static let minCanvasWidth: CGFloat = 680
    /// Height kept free at the top of the canvas for the floating toolbar.
    static let toolbarClearance: CGFloat = 76

    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width
            let dockSidebar = store.showSidebar && width >= Self.sidebarWidth + Self.minCanvasWidth
            let dockInspector = store.showInspector
                && width >= (dockSidebar ? Self.sidebarWidth : 0) + Self.inspectorWidth + Self.minCanvasWidth

            HStack(spacing: 0) {
                if dockSidebar {
                    SidebarView().frame(width: Self.sidebarWidth)
                    Divider()
                }
                VStack(spacing: 0) {
                    CanvasView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .overlay(alignment: .bottom) {
                            if store.draft != nil {
                                CommentComposer()
                                    .padding(.bottom, 20)
                                    .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .overlay(alignment: .top) {
                            if store.commentMode && store.draft == nil {
                                Label("Clique n'importe où sur un écran pour laisser un retour · Échap pour quitter", systemImage: "bubble.left.and.text.bubble.right")
                                    .font(.callout)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(.thinMaterial, in: Capsule())
                                    .padding(.top, Self.toolbarClearance + 4)
                            }
                        }
                        .animation(.snappy(duration: 0.2), value: store.draft != nil)
                        .overlay(alignment: .topLeading) {
                            if floatingSidebar && !dockSidebar {
                                SidebarView()
                                    .frame(width: Self.sidebarWidth)
                                    .frame(maxHeight: .infinity)
                                    .floatingPanel()
                                    .padding(.top, Self.toolbarClearance)
                                    .transition(.move(edge: .leading).combined(with: .opacity))
                            }
                        }
                        .overlay(alignment: .topTrailing) {
                            if floatingInspector && store.showInspector && !dockInspector {
                                InspectorView()
                                    .frame(width: Self.inspectorWidth)
                                    .frame(maxHeight: .infinity)
                                    .floatingPanel()
                                    .padding(.top, Self.toolbarClearance)
                                    .transition(.move(edge: .trailing).combined(with: .opacity))
                            }
                        }
                        .animation(.snappy(duration: 0.2), value: floatingSidebar)
                        .animation(.snappy(duration: 0.2), value: floatingInspector)
                        // « Îlot + mode » (picked in UI Studio › Interface › Barre d'outils): floating over the canvas.
                        .overlay(alignment: .top) {
                        FloatingToolbar(
                            leadingInset: dockSidebar ? 0 : 72,
                            toggleSidebar: {
                                if dockSidebar || (width >= Self.sidebarWidth + Self.minCanvasWidth) {
                                    store.showSidebar.toggle()
                                    floatingSidebar = false
                                } else {
                                    floatingSidebar.toggle()
                                }
                            },
                            toggleInspector: {
                                if dockInspector || !store.showInspector {
                                    store.showInspector.toggle()
                                    floatingInspector = !store.showInspector ? false : floatingInspector
                                } else {
                                    floatingInspector.toggle()
                                }
                            }
                        )
                            .padding(.top, 16)
                        }
                }
                .frame(maxWidth: .infinity)
                if dockInspector {
                    Divider()
                    InspectorView().frame(width: Self.inspectorWidth)
                }
            }
            .onChange(of: store.selectedScreenID) { floatingSidebar = false }
        }
        .onAppear(perform: hideTitlebar)
        .task {
            while !Task.isCancelled {
                store.reloadCommentsIfChanged()
                try? await Task.sleep(for: .seconds(2))
            }
        }
    }

    private func hideTitlebar() {
        #if targetEnvironment(macCatalyst)
        for case let scene as UIWindowScene in UIApplication.shared.connectedScenes {
            scene.titlebar?.titleVisibility = .hidden
            scene.titlebar?.toolbar = nil
        }
        #endif
    }
}

private extension View {
    func floatingPanel() -> some View {
        self
            .background(Color(uiColor: .secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous).stroke(Color(uiColor: .separator)))
            .shadow(color: .black.opacity(0.3), radius: 20, y: 6)
            .padding(8)
    }
}

/// Project switcher; ⌃⌘1…9 jump straight to a project.
private struct ProjectMenu: View {
    @Environment(StudioStore.self) private var store

    var body: some View {
        let projects = store.projects
        Menu {
            ForEach(Array(projects.enumerated()), id: \.element) { index, name in
                Button {
                    store.switchProject(to: name)
                } label: {
                    if name == store.project {
                        Label(name, systemImage: "checkmark")
                    } else {
                        Text(name)
                    }
                }
            }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "folder")
                Text(store.project).fontWeight(.semibold)
                Image(systemName: "chevron.down").font(.caption2.weight(.bold))
            }
        }
        .menuIndicator(.hidden)
        .fixedSize()
        .background {
            ForEach(Array(projects.prefix(9).enumerated()), id: \.element) { index, name in
                Button("Project \(name)") { store.switchProject(to: name) }
                    .keyboardShortcut(KeyEquivalent(Character("\(index + 1)")), modifiers: [.command, .control])
                    .opacity(0)
            }
        }
    }
}

/// Floating toolbar (« Îlot + mode »): one capsule centered over the canvas, Canvas/Variantes as its main control.
private struct FloatingToolbar: View {
    let leadingInset: CGFloat
    let toggleSidebar: () -> Void
    let toggleInspector: () -> Void

    @Environment(StudioStore.self) private var store

    var body: some View {
        ViewThatFits(in: .horizontal) {
            island(compact: false)
            island(compact: true)
        }
        .padding(.leading, leadingInset)
        .padding(.horizontal, 24)
        .background {
            Button("Toggle variants") { store.compareMode.toggle() }
                .keyboardShortcut("v", modifiers: [.command, .shift])
                .opacity(0)
        }
    }

    private func island(compact: Bool) -> some View {
        @Bindable var store = store
        return HStack(spacing: 8) {
            iconButton("Screens", "sidebar.leading", action: toggleSidebar)
                .keyboardShortcut("s", modifiers: [.command, .option])
                .help("Écrans (⌥⌘S)")
            ProjectMenu().padding(.horizontal, 4)
            divider
            ModeSwitch(compareMode: $store.compareMode, compact: compact)
            divider
            Menu {
                Picker("Device", selection: $store.deviceID) {
                    ForEach(Device.all) { Text($0.name).tag($0.id) }
                }
            } label: {
                if compact {
                    Image(systemName: "iphone").frame(width: 30, height: 28)
                } else {
                    Label(store.device.name, systemImage: "iphone").padding(.horizontal, 6).frame(height: 28)
                }
            }
            .menuIndicator(.hidden)
            .fixedSize()
            iconButton("Appearance", store.appearance == .dark ? "moon.fill" : "sun.max") {
                store.appearance = store.appearance == .dark ? .light : .dark
            }
            .help(store.appearance == .dark ? "Sombre — passer en clair" : "Clair — passer en sombre")
            divider
            iconButton("Zoom out", "minus.magnifyingglass") { store.zoom = CanvasView.clampZoom(store.zoom / 1.25) }
                .keyboardShortcut("-", modifiers: .command)
            Button("\(Int((store.zoom * 100).rounded()))%") { store.zoom = 1 }
                .keyboardShortcut("0", modifiers: .command)
                .font(.callout.monospacedDigit())
                .foregroundStyle(.secondary)
                .frame(minWidth: 42)
            iconButton("Zoom in", "plus.magnifyingglass") { store.zoom = CanvasView.clampZoom(store.zoom * 1.25) }
                .keyboardShortcut("=", modifiers: .command)
            divider
            CommentControls()
            iconButton("Inspector", "sidebar.trailing", action: toggleInspector)
                .keyboardShortcut("i", modifiers: [.command, .option])
                .help("Inspecteur (⌥⌘I)")
        }
        .buttonStyle(.borderless)
        .padding(.horizontal, 14)
        .frame(height: 50)
        .background(Color(uiColor: UIColor { $0.userInterfaceStyle == .dark ? .secondarySystemBackground : .systemBackground }), in: Capsule())
        .overlay(Capsule().stroke(Color(uiColor: .separator).opacity(0.6), lineWidth: 0.5))
        .shadow(color: .black.opacity(0.16), radius: 12, y: 4)
        .fixedSize()
    }

    private func iconButton(_ title: String, _ symbol: String, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Image(systemName: symbol).frame(width: 30, height: 28).contentShape(Rectangle())
        }
        .accessibilityLabel(title)
    }

    private var divider: some View {
        Rectangle().fill(Color(uiColor: .separator)).frame(width: 1, height: 20).padding(.horizontal, 4)
    }
}

/// Canvas / Variantes as the toolbar's main control: icon + label, selected segment filled with the accent.
private struct ModeSwitch: View {
    @Binding var compareMode: Bool
    var compact = false

    var body: some View {
        HStack(spacing: 2) {
            segment("Canvas", symbol: "rectangle.3.group", value: false)
            segment("Variantes", symbol: "square.grid.3x3", value: true)
        }
        .padding(3)
        .background(Color.primary.opacity(0.07), in: Capsule())
    }

    private func segment(_ title: String, symbol: String, value: Bool) -> some View {
        let selected = compareMode == value
        return Button { compareMode = value } label: {
            HStack(spacing: 6) {
                Image(systemName: symbol)
                if !compact { Text(title) }
            }
            .font(.callout.weight(.semibold))
            .foregroundStyle(selected ? Color.white : Color.primary.opacity(0.75))
            .padding(.horizontal, compact ? 10 : 14)
            .frame(height: 28)
            .background(selected ? Color.accentColor : .clear, in: Capsule())
            .contentShape(Capsule())
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
        .accessibilityAddTraits(selected ? .isSelected : [])
    }
}

/// Previous toolbar (v1): full-width bar above the canvas. Kept for reference; not used.
private struct TopBar: View {
    let leadingInset: CGFloat
    let toggleSidebar: () -> Void
    let toggleInspector: () -> Void

    @Environment(StudioStore.self) private var store

    var body: some View {
        HStack(spacing: 10) {
            Button("Screens", systemImage: "sidebar.leading", action: toggleSidebar)
                .labelStyle(.iconOnly)
                .keyboardShortcut("s", modifiers: [.command, .option])

            ProjectMenu()

            // Full controls when there's room, compact icon-only controls otherwise.
            ViewThatFits(in: .horizontal) {
                controls(compact: false)
                controls(compact: true)
            }

            CommentControls()

            Button("Inspector", systemImage: "sidebar.trailing", action: toggleInspector)
                .labelStyle(.iconOnly)
                .keyboardShortcut("i", modifiers: [.command, .option])
        }
        .buttonStyle(.borderless)
        .padding(.leading, 12 + leadingInset)
        .padding(.trailing, 12)
        .frame(height: 48)
        .background(.bar)
        .background {
            Button("Toggle variants") { store.compareMode.toggle() }
                .keyboardShortcut("v", modifiers: [.command, .shift])
                .opacity(0)
        }
    }

    @ViewBuilder
    private func controls(compact: Bool) -> some View {
        @Bindable var store = store
        HStack(spacing: compact ? 8 : 12) {
            Picker("Mode", selection: $store.compareMode) {
                if compact {
                    Image(systemName: "rectangle.3.group").tag(false)
                    Image(systemName: "square.grid.3x3").tag(true)
                } else {
                    Text("Canvas").tag(false)
                    Text("Variants").tag(true)
                }
            }
            .pickerStyle(.segmented)
            .fixedSize()

            Menu {
                Picker("Device", selection: $store.deviceID) {
                    ForEach(Device.all) { Text($0.name).tag($0.id) }
                }
            } label: {
                if compact {
                    Image(systemName: "iphone")
                } else {
                    Label(store.device.name, systemImage: "iphone")
                }
            }
            .fixedSize()

            if compact {
                Menu {
                    Picker("Appearance", selection: $store.appearance) {
                        ForEach(Appearance.allCases) { Text($0.rawValue).tag($0) }
                    }
                } label: {
                    Image(systemName: store.appearance == .dark ? "moon.fill" : "sun.max.fill")
                }
                .fixedSize()
            } else {
                Picker("Appearance", selection: $store.appearance) {
                    ForEach(Appearance.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .fixedSize()
            }

            Spacer(minLength: 8)

            HStack(spacing: 2) {
                Button("Zoom out", systemImage: "minus") { store.zoom = CanvasView.clampZoom(store.zoom / 1.25) }
                    .keyboardShortcut("-", modifiers: .command)
                Button("\(Int((store.zoom * 100).rounded()))%") { store.zoom = 1 }
                    .keyboardShortcut("0", modifiers: .command)
                    .monospacedDigit()
                    .frame(minWidth: 44)
                Button("Zoom in", systemImage: "plus") { store.zoom = CanvasView.clampZoom(store.zoom * 1.25) }
                    .keyboardShortcut("=", modifiers: .command)
            }
            .labelStyle(.iconOnly)
            .fixedSize()
        }
    }
}

private struct CommentControls: View {
    @Environment(StudioStore.self) private var store

    var body: some View {
        @Bindable var store = store
        HStack(spacing: 8) {
            Toggle(isOn: $store.commentMode) {
                Label("Commenter", systemImage: store.commentMode ? "bubble.left.fill" : "bubble.left")
            }
            .toggleStyle(.button)
            .keyboardShortcut("c", modifiers: [.command, .shift])
            .help("Mode commentaire (⇧⌘C)")

            let pending = store.draftComments.count
            if pending > 0 {
                Button {
                    store.sendDrafts()
                    store.commentMode = false
                } label: {
                    Label("Envoyer à Claude (\(pending))", systemImage: "paperplane.fill")
                        .labelStyle(.titleAndIcon)
                        .font(.callout.weight(.semibold))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .foregroundStyle(.white)
                        .background(Color.accentColor, in: Capsule())
                }
                .keyboardShortcut(.return, modifiers: [.command, .shift])
                .fixedSize()
            }
        }
        .background {
            Button("Quitter le mode commentaire") {
                if store.draft != nil { store.draft = nil } else { store.commentMode = false }
            }
            .keyboardShortcut(.escape, modifiers: [])
            .opacity(0)
            .disabled(!store.commentMode && store.draft == nil)
        }
    }
}

private struct CommentComposer: View {
    @Environment(StudioStore.self) private var store
    @State private var text = ""
    @FocusState private var focused: Bool

    var body: some View {
        if let draft = store.draft {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text("\(store.nextPinNumber)")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                        .frame(width: 22, height: 22)
                        .background(Circle().fill(.orange))
                    if let element = draft.element {
                        Text(element.title).font(.headline).lineLimit(1)
                    }
                    Spacer()
                }
                // Layer path, like Figma: click a parent to comment on it instead.
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 4) {
                        ForEach(Array(draft.chain.enumerated()), id: \.offset) { index, element in
                            if index > 0 {
                                Image(systemName: "chevron.right").font(.caption2).foregroundStyle(.tertiary)
                            }
                            Button(element.kind == "Écran" ? element.name : element.shortName) {
                                store.selectDraftElement(index)
                            }
                            .font(.caption.weight(index == draft.selectedIndex ? .bold : .regular))
                            .foregroundStyle(index == draft.selectedIndex ? Color.accentColor : .secondary)
                            .buttonStyle(.plain)
                            .help(element.kind)
                        }
                    }
                }
                TextField("Ton retour sur cet élément…", text: $text)
                    .textFieldStyle(.roundedBorder)
                    .focused($focused)
                    .onSubmit(add)
                HStack {
                    Text("Entrée pour ajouter · Échap pour annuler · clique un parent pour élargir")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Button("Annuler") { store.draft = nil }
                    Button("Ajouter", action: add)
                        .buttonStyle(.borderedProminent)
                        .disabled(text.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .padding(14)
            .frame(width: 440)
            .background(Color(uiColor: .secondarySystemBackground), in: RoundedRectangle(cornerRadius: 14, style: .continuous))
            .overlay(RoundedRectangle(cornerRadius: 14, style: .continuous).stroke(Color(uiColor: .separator)))
            .shadow(color: .black.opacity(0.3), radius: 20, y: 8)
            .onAppear { focused = true }
        }
    }

    private func add() {
        store.addComment(text: text)
        text = ""
    }
}
