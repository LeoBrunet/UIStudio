import SwiftUI

struct Device: Identifiable, Hashable {
    let id: String
    let size: CGSize
    let cornerRadius: CGFloat
    let safeTop: CGFloat
    let safeBottom: CGFloat
    let hasIsland: Bool
    /// A Mac window instead of an iPhone (no bezel, status bar or home indicator; regular size class).
    var isMac = false

    var name: String { id }

    static let all: [Device] = [
        Device(id: "iPhone 17 Pro", size: CGSize(width: 402, height: 874), cornerRadius: 62, safeTop: 62, safeBottom: 34, hasIsland: true),
        Device(id: "iPhone 17 Pro Max", size: CGSize(width: 440, height: 956), cornerRadius: 62, safeTop: 62, safeBottom: 34, hasIsland: true),
        Device(id: "iPhone 16", size: CGSize(width: 393, height: 852), cornerRadius: 55, safeTop: 59, safeBottom: 34, hasIsland: true),
        Device(id: "iPhone SE", size: CGSize(width: 375, height: 667), cornerRadius: 0, safeTop: 20, safeBottom: 0, hasIsland: false),
    ]

    /// Frame for screens declared with `ScreenInfo(frame: .mac(...))`; not in the device picker.
    static func macWindow(width: CGFloat, height: CGFloat) -> Device {
        Device(id: "Mac", size: CGSize(width: width, height: height), cornerRadius: 12, safeTop: 0, safeBottom: 0, hasIsland: false, isMac: true)
    }

    static func named(_ id: String) -> Device {
        all.first { $0.id == id } ?? all[0]
    }
}

enum Appearance: String, CaseIterable, Identifiable {
    case light = "Light", dark = "Dark"
    var id: String { rawValue }
    var colorScheme: ColorScheme { self == .light ? .light : .dark }
}
