import SwiftUI

// Names views so UI Studio's selection tool can pick them like layers in Figma.
// Harmless in the real app: nothing reads this preference there.

struct DesignNode {
    let kind: String
    let name: String
    let anchor: Anchor<CGRect>
}

struct DesignNodesKey: PreferenceKey {
    static var defaultValue: [DesignNode] = []
    static func reduce(value: inout [DesignNode], nextValue: () -> [DesignNode]) {
        value += nextValue()
    }
}

extension View {
    /// Makes this view selectable as a named component in UI Studio.
    func studioComponent(_ name: String, kind: String = "Composant") -> some View {
        transformAnchorPreference(key: DesignNodesKey.self, value: .bounds) {
            $0.append(DesignNode(kind: kind, name: name, anchor: $1))
        }
    }
}
