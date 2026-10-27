import SwiftUI

/// Renders a screen inside an iPhone frame at 1:1 points (zoom is applied by the canvas).
struct PhoneView: View {
    let screen: ScreenEntry
    let device: Device
    /// Variant choices to render with (slot path -> variant name).
    let selections: [String: String]
    /// Interactive phones receive touches; others just call `onTap` when clicked.
    let interactive: Bool
    var highlight: String?
    /// Slot to scroll into view (e.g. the slot being compared in Variants mode).
    var focusSlot: String?
    /// Only the phone showing the real selection reports its slots to the inspector.
    var reportsSlots = true
    var onTap: () -> Void = {}

    @Environment(StudioStore.self) private var store
    @State private var capture = PhoneCapture()

    static func bezel(_ device: Device) -> CGFloat { device.isMac ? 0 : 12 }

    /// Pins (and the outline of the commented element) on the phone that shows the real selection.
    private var pins: [Pin] {
        var result: [Pin] = []
        if reportsSlots {
            result = store.openComments(for: screen.id).map {
                Pin(number: store.pinNumber(of: $0), point: CGPoint(x: $0.x, y: $0.y), frame: $0.elementRect,
                    isDraft: false, isFocused: store.focusedCommentID == $0.id)
            }
        }
        if let draft = store.draft, draft.screenID == screen.id, draft.selections == selections {
            result.append(Pin(number: store.nextPinNumber, point: draft.point, frame: draft.element?.frame,
                              label: draft.element?.title, isDraft: true, isFocused: true))
        }
        return result
    }

    static func outerSize(_ device: Device) -> CGSize {
        let bezel = bezel(device)
        return CGSize(width: device.size.width + bezel * 2, height: device.size.height + bezel * 2)
    }

    var body: some View {
        let highlighted = highlight
        let focusKey = focusSlot.map { "\($0)|\(self.selections.sorted { $0.key < $1.key }.map { "\($0.key)=\($0.value)" }.joined(separator: ","))" }
        let screenID = screen.id
        let store = store
        let reportsSlots = reportsSlots
        let ink: Color = store.appearance == .dark ? .white : .black
        let commentMode = store.commentMode
        let capture = capture
        let selections = selections
        let screenName = screen.info.name
        let pins = pins

        // Everything inside `root` lives in the phone's own hosting controller.
        let root = screen.make()
            .environment(\.slotSelections, selections)
            .environment(\.colorScheme, store.appearance.colorScheme)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .onPreferenceChange(SlotListKey.self) { slots in
                if reportsSlots { store.slots[screenID] = slots }
            }
            .overlayPreferenceValue(SlotBoundsKey.self) { anchors in
                ZStack {
                    SlotHighlight(path: highlighted, anchors: anchors)
                    if let focusKey, let path = focusKey.split(separator: "|").first.map(String.init) {
                        FocusScroller(anchor: anchors[path], key: focusKey, capture: capture)
                    }
                }
                .ignoresSafeArea()
                .accessibilityHidden(true)
            }
            .overlayPreferenceValue(DesignNodesKey.self) { nodes in
                ZStack(alignment: .topLeading) {
                    if commentMode {
                        ElementPicker(nodes: nodes, capture: capture, screenName: screenName) { point, chain in
                            let slot = chain.last { $0.kind == "Slot" }?.name
                            store.beginComment(CommentDraft(
                                screenID: screenID,
                                screenName: screenName,
                                point: point,
                                slotPath: slot,
                                selections: selections,
                                snapshot: capture.snapshot(),
                                chain: chain,
                                selectedIndex: chain.count - 1
                            ))
                        }
                    }
                    ForEach(pins) { pin in
                        CommentPinView(pin: pin)
                    }
                }
                .ignoresSafeArea()
                .accessibilityHidden(true)
            }

        PhoneHost(root: AnyView(root), device: device, appearance: store.appearance, capture: capture)
            .frame(width: device.size.width, height: device.size.height)
            .overlay(alignment: .top) { if !device.isMac { StatusBar(device: device, ink: ink) } }
            .overlay(alignment: .bottom) { if !device.isMac { HomeIndicator(device: device, ink: ink) } }
            .environment(\.colorScheme, store.appearance.colorScheme)
            .clipShape(RoundedRectangle(cornerRadius: device.cornerRadius, style: .continuous))
            .allowsHitTesting(interactive || commentMode)
            .padding(Self.bezel(device))
            .background {
                if device.isMac {
                    // macOS window: thin border, no bezel.
                    RoundedRectangle(cornerRadius: device.cornerRadius, style: .continuous)
                        .stroke(Color.black.opacity(0.25), lineWidth: 1)
                        .padding(-0.5)
                } else {
                    RoundedRectangle(cornerRadius: device.cornerRadius + Self.bezel(device), style: .continuous)
                        .fill(Color(white: 0.07))
                        .stroke(Color(white: 0.3), lineWidth: 1.5)
                }
            }
            .overlay {
                if !interactive && !commentMode {
                    Color.clear
                        .contentShape(Rectangle())
                        .onTapGesture(perform: onTap)
                }
            }
            .shadow(color: .black.opacity(0.18), radius: 24, y: 12)
    }
}

private struct SlotHighlight: View {
    let path: String?
    let anchors: [String: Anchor<CGRect>]

    var body: some View {
        GeometryReader { proxy in
            if let path, let anchor = anchors[path] {
                let rect = proxy[anchor]
                ZStack(alignment: .topLeading) {
                    Rectangle()
                        .fill(Color.accentColor.opacity(0.08))
                        .stroke(Color.accentColor, lineWidth: 2)
                        .frame(width: max(rect.width, 2), height: max(rect.height, 2))
                    Text(path.split(separator: "/").last.map(String.init) ?? path)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.accentColor)
                        .offset(y: rect.minY > 18 ? -18 : 0)
                }
                .offset(x: rect.minX, y: rect.minY)
            }
        }
        .allowsHitTesting(false)
    }
}

private struct StatusBar: View {
    let device: Device
    let ink: Color

    var body: some View {
        HStack {
            Text("9:41")
                .font(.system(size: device.hasIsland ? 17 : 15, weight: .semibold))
            Spacer()
            HStack(spacing: 5) {
                Image(systemName: "cellularbars")
                Image(systemName: "wifi")
                Image(systemName: "battery.100")
            }
            .font(.system(size: device.hasIsland ? 15 : 13, weight: .semibold))
        }
        .padding(.horizontal, device.hasIsland ? 36 : 16)
        .frame(height: device.hasIsland ? 59 : 20)
        .overlay(alignment: .top) {
            if device.hasIsland {
                Capsule().fill(.black)
                    .frame(width: 126, height: 37)
                    .padding(.top, 11)
            }
        }
        .foregroundStyle(ink)
        .dynamicTypeSize(.large)
        .allowsHitTesting(false)
    }
}

private struct HomeIndicator: View {
    let device: Device
    let ink: Color

    var body: some View {
        if device.safeBottom > 0 {
            Capsule()
                .fill(ink)
                .frame(width: 140, height: 5)
                .padding(.bottom, 8)
                .allowsHitTesting(false)
        }
    }
}

struct Pin: Identifiable {
    let number: Int
    let point: CGPoint
    let frame: CGRect?
    var label: String?
    let isDraft: Bool
    let isFocused: Bool
    var id: String { "\(number)-\(isDraft)" }
}

/// Figma-like selection: hovering outlines the deepest element under the pointer
/// (button, text, icon, tagged component or slot); clicking selects it and starts a comment.
private struct ElementPicker: View {
    let nodes: [DesignNode]
    let capture: PhoneCapture
    let screenName: String
    let onSelect: (CGPoint, [ElementInfo]) -> Void

    @State private var hovered: ElementInfo?

    var body: some View {
        GeometryReader { proxy in
            ZStack(alignment: .topLeading) {
                Color.clear
                    .contentShape(Rectangle())
                    .onContinuousHover(coordinateSpace: .local) { phase in
                        switch phase {
                        case .active(let point): hovered = chain(at: point, proxy: proxy).last
                        case .ended: hovered = nil
                        }
                    }
                    .onTapGesture(coordinateSpace: .local) { point in
                        let chain = chain(at: point, proxy: proxy)
                        // Hide the hover outline before the snapshot is taken.
                        hovered = nil
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.06) {
                            onSelect(point, chain)
                        }
                    }
                if let hovered, hovered.kind != "Écran" {
                    ElementOutline(frame: hovered.frame, label: hovered.title, color: .blue, dashed: false)
                        .allowsHitTesting(false)
                }
            }
        }
    }

    /// Every element containing the point, from the whole screen down to the most specific one.
    private func chain(at point: CGPoint, proxy: GeometryProxy) -> [ElementInfo] {
        var all = nodes.map { ElementInfo(kind: $0.kind, name: $0.name, frame: proxy[$0.anchor]) }
        all += capture.leaves()
        let hits = all.filter { $0.frame.insetBy(dx: -1, dy: -1).contains(point) }
        // Biggest first; on equal size, containers (slot, component) before leaves.
        let order = ["Slot": 0, "Composant": 1]
        var sorted = hits.sorted {
            let a = $0.frame.width * $0.frame.height, b = $1.frame.width * $1.frame.height
            if abs(a - b) > 1 { return a > b }
            return (order[$0.kind] ?? 2) < (order[$1.kind] ?? 2)
        }
        // Drop exact duplicates (same kind, name and frame).
        sorted = sorted.reduce(into: []) { result, element in
            if !result.contains(where: { $0.kind == element.kind && $0.name == element.name && $0.frame.integral == element.frame.integral }) {
                result.append(element)
            }
        }
        let screen = ElementInfo(kind: "Écran", name: screenName, frame: proxy.frame(in: .local))
        return [screen] + sorted
    }
}

private struct ElementOutline: View {
    let frame: CGRect
    let label: String?
    let color: Color
    let dashed: Bool

    var body: some View {
        ZStack(alignment: .topLeading) {
            Rectangle()
                .stroke(color, style: StrokeStyle(lineWidth: 2, dash: dashed ? [5, 3] : []))
                .background(color.opacity(0.06))
                .frame(width: max(frame.width, 2), height: max(frame.height, 2))
            if let label {
                Text(label)
                    .font(.system(size: 11, weight: .semibold))
                    .lineLimit(1)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 5)
                    .padding(.vertical, 2)
                    .background(color)
                    .fixedSize()
                    .offset(y: frame.minY > 18 ? -18 : frame.height)
            }
        }
        .offset(x: frame.minX, y: frame.minY)
    }
}

private struct CommentPinView: View {
    let pin: Pin

    var body: some View {
        ZStack(alignment: .topLeading) {
            if let frame = pin.frame, pin.isDraft || pin.isFocused {
                ElementOutline(frame: frame, label: pin.label, color: pin.isDraft ? .orange : .red, dashed: !pin.isDraft)
            }
            Text("\(pin.number)")
                .font(.system(size: 13, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 26, height: 26)
                .background(Circle().fill(pin.isDraft ? Color.orange : Color.red))
                .overlay(Circle().stroke(.white, lineWidth: 2.5))
                .shadow(color: .black.opacity(0.35), radius: 4, y: 2)
                .scaleEffect(pin.isFocused ? 1.2 : 1)
                .position(badgePosition)
        }
        .allowsHitTesting(false)
    }

    private var badgePosition: CGPoint {
        guard let frame = pin.frame else { return pin.point }
        return CGPoint(x: max(frame.minX, 13), y: max(frame.minY, 13))
    }
}

/// Brings a slot into view once it's laid out (and again when the variant shown changes).
private struct FocusScroller: View {
    let anchor: Anchor<CGRect>?
    let key: String
    let capture: PhoneCapture

    var body: some View {
        GeometryReader { proxy in
            // Resolve the slot frame now: a proxy used later, from a task, gives stale values.
            let rect = anchor.map { proxy[$0] }
            // Early layout passes can report the frame in the wrong space; wait for a sane one.
            let valid = rect.map { $0.minX >= -2 && $0.maxX <= proxy.size.width + 2 } ?? false
            Color.clear
                .task(id: "\(key)|\(valid)") {
                    guard valid else { return }
                    try? await Task.sleep(for: .milliseconds(150))
                    guard let rect else { return }
                    capture.scrollIntoView(rect)
                }
        }
        .allowsHitTesting(false)
    }
}
