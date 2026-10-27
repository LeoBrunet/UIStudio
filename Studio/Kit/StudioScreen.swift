import SwiftUI

/// A screen shown on the canvas.
/// Conform any SwiftUI view; `studio.sh` regenerates `ScreenRegistry.all` before each build.
protocol StudioScreen: View {
    init()
    static var info: ScreenInfo { get }
}

struct ScreenInfo {
    let name: String
    /// Which project's canvas the screen belongs to (switch projects in the top bar).
    let project: String
    let flow: String
    /// Display position. Flows are ordered by their lowest screen order, screens within a flow
    /// by order then name. Leave the default to land at the end (sorted by name).
    let order: Int
    let notes: String
    /// What the screen is drawn in: the device picked in the top bar, or a fixed Mac window.
    let frame: ScreenFrame
    /// Source file of the screen, captured automatically at the declaration site.
    let file: String

    static let defaultOrder = 10_000
    static let defaultProject = "Coach"

    init(_ name: String, project: String = ScreenInfo.defaultProject, flow: String = "General", order: Int = ScreenInfo.defaultOrder, notes: String = "", frame: ScreenFrame = .iPhone, file: String = #filePath) {
        self.name = name
        self.project = project
        self.flow = flow
        self.order = order
        self.notes = notes
        self.frame = frame
        self.file = file
    }
}

enum ScreenFrame {
    /// The iPhone chosen in the top bar.
    case iPhone
    /// A macOS window of this size (for designing Mac UI, e.g. UI Studio itself).
    case mac(width: CGFloat = 1200, height: CGFloat = 760)
}

struct ScreenEntry: Identifiable {
    let info: ScreenInfo
    let make: () -> AnyView

    /// Default-project ids stay "Flow/Name" so saved selections and comments keep working.
    var id: String {
        let base = "\(info.flow)/\(info.name)"
        return info.project == ScreenInfo.defaultProject ? base : "\(info.project):\(base)"
    }

    init<S: StudioScreen>(_ type: S.Type) {
        info = S.info
        make = { AnyView(S()) }
    }
}
