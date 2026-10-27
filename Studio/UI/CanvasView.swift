import SwiftUI

struct CanvasView: View {
    @Environment(StudioStore.self) private var store
    @State private var pinchStartZoom: Double?

    static func clampZoom(_ zoom: Double) -> Double { min(max(zoom, 0.15), 2.5) }

    var body: some View {
        GeometryReader { viewport in
        ScrollViewReader { proxy in
            ScrollView([.horizontal, .vertical]) {
                Group {
                    if store.compareMode, let screen = store.selectedScreen {
                        VariantsBoard(screen: screen)
                    } else {
                        allScreens
                    }
                }
                .padding(.horizontal, 56)
                .padding(.bottom, 56)
                .padding(.top, 56 + RootView.toolbarClearance)  // room for the floating toolbar
                // At least as big as the viewport and pinned top-left, like a design canvas
                // (otherwise SwiftUI centers smaller content and can clip the leading edge).
                .frame(minWidth: viewport.size.width, minHeight: viewport.size.height, alignment: .topLeading)
            }
            .defaultScrollAnchor(.topLeading)
            .background(Color.canvas)
            .simultaneousGesture(
                MagnifyGesture()
                    .onChanged { value in
                        let start = pinchStartZoom ?? store.zoom
                        pinchStartZoom = start
                        store.zoom = Self.clampZoom(start * value.magnification)
                    }
                    .onEnded { _ in pinchStartZoom = nil }
            )
            .onChange(of: store.scrollTarget) { _, target in
                guard let target, !store.compareMode else { return }
                withAnimation(.snappy) { proxy.scrollTo(target, anchor: .top) }
                store.scrollTarget = nil
            }
            .task {
                if let id = store.selectedScreenID, !store.compareMode { proxy.scrollTo(id, anchor: .top) }
            }
        }
        }
    }

    private var allScreens: some View {
        VStack(alignment: .leading, spacing: 64) {
            ForEach(store.flows, id: \.name) { flow in
                VStack(alignment: .leading, spacing: 20) {
                    Text(flow.name)
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(.secondary)
                    HStack(alignment: .top, spacing: 56 * max(store.zoom, 0.5)) {
                        ForEach(flow.screens) { screen in
                            ScreenCard(screen: screen).id(screen.id)
                        }
                    }
                }
            }
        }
    }
}

/// Screen name + phone, sized for the current zoom.
private struct ScreenCard: View {
    let screen: ScreenEntry
    @Environment(StudioStore.self) private var store

    var body: some View {
        let isSelected = store.selectedScreenID == screen.id
        LabeledPhone(title: screen.info.name, device: store.device(for: screen), isHighlighted: isSelected) {
            store.selectedScreenID = screen.id
        } phone: {
            PhoneView(
                screen: screen,
                device: store.device(for: screen),
                selections: store.selections[screen.id] ?? [:],
                interactive: isSelected,
                highlight: isSelected ? (store.hoveredSlotPath ?? store.selectedSlotPath) : nil,
                focusSlot: isSelected ? store.selectedSlotPath : nil,
                onTap: { store.selectedScreenID = screen.id }
            )
        }
    }
}

/// All variants of one screen, side by side.
private struct VariantsBoard: View {
    let screen: ScreenEntry
    @Environment(StudioStore.self) private var store

    private static let maxCombinations = 24

    var body: some View {
        @Bindable var store = store
        let current = store.selections[screen.id] ?? [:]
        let slots = store.slots[screen.id] ?? []
        let gap = 48 * max(store.zoom, 0.5)

        VStack(alignment: .leading, spacing: 28) {
            HStack(spacing: 16) {
                Text(screen.info.name).font(.title2.weight(.bold))
                Picker("Layout", selection: $store.compareStyle) {
                    ForEach(CompareStyle.allCases) { Text($0.rawValue).tag($0) }
                }
                .pickerStyle(.segmented)
                .fixedSize()
            }

            HStack(alignment: .top, spacing: gap) {
                // The real selection, interactive; it also feeds the inspector.
                LabeledPhone(title: "Current", device: store.device(for: screen), isHighlighted: true) {
                } phone: {
                    PhoneView(
                        screen: screen,
                        device: store.device(for: screen),
                        selections: current,
                        interactive: true,
                        highlight: store.hoveredSlotPath ?? store.selectedSlotPath,
                        focusSlot: store.selectedSlotPath
                    )
                }

                Rectangle().fill(.separator).frame(width: 1).padding(.top, 30)

                if slots.isEmpty {
                    Text("This screen has no slots.")
                        .foregroundStyle(.secondary)
                        .padding(.top, 30)
                } else if store.compareStyle == .perSlot {
                    perSlot(slots: slots, current: current, gap: gap)
                } else {
                    combinations(slots: slots, current: current, gap: gap)
                }
            }
        }
    }

    private func perSlot(slots: [SlotInfo], current: [String: String], gap: CGFloat) -> some View {
        VStack(alignment: .leading, spacing: gap) {
            ForEach(slots) { slot in
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Image(systemName: slot.depth > 0 ? "arrow.turn.down.right" : "square.dashed")
                        Text(slot.path).font(.headline)
                        Text("\(slot.variants.count) variants").foregroundStyle(.secondary)
                    }
                    HStack(alignment: .top, spacing: gap) {
                        ForEach(slot.variants, id: \.self) { variant in
                            let isCurrent = variant == slot.selected
                            LabeledPhone(title: variant, device: store.device(for: screen), isHighlighted: isCurrent) {
                                store.select(variant, slot: slot.path, in: screen.id)
                            } phone: {
                                PhoneView(
                                    screen: screen,
                                    device: store.device(for: screen),
                                    selections: current.merging([slot.path: variant]) { $1 },
                                    interactive: false,
                                    highlight: slot.path,
                                    focusSlot: slot.path,
                                    reportsSlots: false,
                                    onTap: { store.select(variant, slot: slot.path, in: screen.id) }
                                )
                            }
                        }
                    }
                }
            }
        }
    }

    /// Every combination of the top-level slots (nested slots keep their current choice).
    private func combinations(slots: [SlotInfo], current: [String: String], gap: CGFloat) -> some View {
        let topLevel = slots.filter { $0.depth == 0 }
        var combos: [[String: String]] = [current]
        for slot in topLevel {
            combos = combos.flatMap { combo in
                slot.variants.map { combo.merging([slot.path: $0]) { $1 } }
            }
        }
        let total = combos.count
        let shown = Array(combos.prefix(Self.maxCombinations))
        let currentValues = topLevel.map(\.selected)

        return VStack(alignment: .leading, spacing: 16) {
            if total > shown.count {
                Text("Showing \(shown.count) of \(total) combinations.")
                    .foregroundStyle(.secondary)
            }
            FlowLayout(spacing: gap) {
                ForEach(Array(shown.enumerated()), id: \.offset) { _, combo in
                    let values = topLevel.map { combo[$0.path] ?? $0.selected }
                    LabeledPhone(title: values.joined(separator: " · "), device: store.device(for: screen), isHighlighted: values == currentValues) {
                        for slot in topLevel { store.select(combo[slot.path] ?? slot.selected, slot: slot.path, in: screen.id) }
                    } phone: {
                        PhoneView(
                            screen: screen,
                            device: store.device(for: screen),
                            selections: combo,
                            interactive: false,
                            reportsSlots: false,
                            onTap: {
                                for slot in topLevel { store.select(combo[slot.path] ?? slot.selected, slot: slot.path, in: screen.id) }
                            }
                        )
                    }
                }
            }
            .frame(width: CGFloat(4) * (PhoneView.outerSize(store.device(for: screen)).width * store.zoom + gap))
        }
    }
}

/// A title above a phone, scaled to the canvas zoom, with an optional selection ring.
private struct LabeledPhone<Phone: View>: View {
    let title: String
    let device: Device
    let isHighlighted: Bool
    let onSelect: () -> Void
    @ViewBuilder let phone: () -> Phone
    @Environment(StudioStore.self) private var store

    var body: some View {
        let outer = PhoneView.outerSize(device)
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.callout.weight(.medium))
                .foregroundStyle(isHighlighted ? Color.accentColor : .secondary)
                .lineLimit(1)
                .frame(maxWidth: outer.width * store.zoom, alignment: .leading)
                .onTapGesture(perform: onSelect)
            phone()
                .scaleEffect(store.zoom, anchor: .topLeading)
                .frame(width: outer.width * store.zoom, height: outer.height * store.zoom, alignment: .topLeading)
                .overlay {
                    RoundedRectangle(cornerRadius: (device.cornerRadius + PhoneView.bezel(device)) * store.zoom + 4, style: .continuous)
                        .stroke(Color.accentColor, lineWidth: 3)
                        .padding(-5)
                        .opacity(isHighlighted ? 1 : 0)
                        .allowsHitTesting(false)
                }
        }
    }
}

extension Color {
    static let canvas = Color(uiColor: UIColor { traits in
        traits.userInterfaceStyle == .dark ? UIColor(white: 0.12, alpha: 1) : UIColor(white: 0.93, alpha: 1)
    })
}
