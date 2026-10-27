import SwiftUI

// MARK: - Public API used by screens

/// One option for a `Slot`.
struct Variant {
    let name: String
    let content: AnyView

    init<V: View>(_ name: String, @ViewBuilder _ content: () -> V) {
        self.name = name
        self.content = AnyView(content())
    }

    /// A variant that renders nothing — use it to compare "with" vs "without".
    static var hidden: Variant {
        Variant("Hidden") { Color.clear.frame(width: 0, height: 0) }
    }
}

/// An open design question inside a screen: a named place with several variants.
/// Slots can be placed anywhere (whole screen, a section, a single button) and nested.
///
///     Slot("Header") {
///         Variant("Minimal") { ... }
///         Variant("Big title") { ... }
///     }
struct Slot: View {
    let name: String
    let variants: [Variant]

    @Environment(\.slotParentPath) private var parentPath
    @Environment(\.slotSelections) private var selections

    init(_ name: String, @VariantBuilder _ variants: () -> [Variant]) {
        self.name = name
        self.variants = variants()
    }

    var body: some View {
        let path = parentPath.isEmpty ? name : "\(parentPath)/\(name)"
        let chosen = variants.first { $0.name == selections[path] } ?? variants.first
        let info = SlotInfo(
            path: path,
            name: name,
            depth: path.split(separator: "/").count - 1,
            variants: variants.map(\.name),
            selected: chosen?.name ?? ""
        )
        return (chosen?.content ?? AnyView(Color.clear.frame(width: 0, height: 0)))
            .environment(\.slotParentPath, path)
            .transformAnchorPreference(key: SlotBoundsKey.self, value: .bounds) { $0[path] = $1 }
            .studioComponent(path, kind: "Slot")
            .transformPreference(SlotListKey.self) { $0.insert(info, at: 0) }
    }
}

@resultBuilder
enum VariantBuilder {
    static func buildExpression(_ variant: Variant) -> [Variant] { [variant] }
    static func buildExpression(_ variants: [Variant]) -> [Variant] { variants }
    static func buildBlock(_ parts: [Variant]...) -> [Variant] { parts.flatMap { $0 } }
    static func buildArray(_ parts: [[Variant]]) -> [Variant] { parts.flatMap { $0 } }
    static func buildOptional(_ part: [Variant]?) -> [Variant] { part ?? [] }
    static func buildEither(first part: [Variant]) -> [Variant] { part }
    static func buildEither(second part: [Variant]) -> [Variant] { part }
}

// MARK: - Plumbing between screens and the canvas

struct SlotInfo: Equatable, Identifiable {
    let path: String
    let name: String
    let depth: Int
    let variants: [String]
    let selected: String

    var id: String { path }
}

struct SlotListKey: PreferenceKey {
    static var defaultValue: [SlotInfo] = []
    static func reduce(value: inout [SlotInfo], nextValue: () -> [SlotInfo]) {
        value += nextValue()
    }
}

struct SlotBoundsKey: PreferenceKey {
    static var defaultValue: [String: Anchor<CGRect>] = [:]
    static func reduce(value: inout [String: Anchor<CGRect>], nextValue: () -> [String: Anchor<CGRect>]) {
        value.merge(nextValue()) { $1 }
    }
}

extension EnvironmentValues {
    @Entry var slotParentPath: String = ""
    /// Slot path -> chosen variant name, for the screen being rendered.
    @Entry var slotSelections: [String: String] = [:]
}
