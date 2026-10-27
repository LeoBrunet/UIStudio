import SwiftUI
import UIKit

/// Hosts a screen in its own UIHostingController so UIKit-backed containers
/// (NavigationStack, TabView, sheets…) see a real iPhone safe area, size classes,
/// and appearance — not the canvas window's.
struct PhoneHost: UIViewControllerRepresentable {
    let root: AnyView
    let device: Device
    let appearance: Appearance
    let capture: PhoneCapture

    func makeUIViewController(context: Context) -> PhoneHostController {
        let controller = PhoneHostController(root: root)
        capture.view = controller.host.view
        return controller
    }

    func updateUIViewController(_ controller: PhoneHostController, context: Context) {
        controller.host.rootView = root
        controller.desiredInsets = UIEdgeInsets(top: device.safeTop, left: 0, bottom: device.safeBottom, right: 0)
        let host = controller.host
        controller.overrideUserInterfaceStyle = appearance == .dark ? .dark : .light
        host.overrideUserInterfaceStyle = controller.overrideUserInterfaceStyle
        host.traitOverrides.horizontalSizeClass = device.isMac ? .regular : .compact
        host.traitOverrides.verticalSizeClass = .regular
    }
}

final class PhoneHostController: UIViewController {
    let host: UIHostingController<AnyView>

    var desiredInsets: UIEdgeInsets = .zero {
        didSet { if desiredInsets != oldValue { applyInsets() } }
    }

    init(root: AnyView) {
        host = UIHostingController(rootView: root)
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        addChild(host)
        host.view.frame = view.bounds
        host.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        host.view.backgroundColor = .systemBackground
        view.addSubview(host.view)
        host.didMove(toParent: self)
        applyInsets()
    }

    override func viewSafeAreaInsetsDidChange() {
        super.viewSafeAreaInsetsDidChange()
        applyInsets()
    }

    /// The container may inherit insets from the canvas window (e.g. under the toolbar).
    /// Compensate so the hosted screen always gets exactly the device's insets.
    private func applyInsets() {
        let inherited = view.safeAreaInsets
        host.additionalSafeAreaInsets = UIEdgeInsets(
            top: desiredInsets.top - inherited.top,
            left: desiredInsets.left - inherited.left,
            bottom: desiredInsets.bottom - inherited.bottom,
            right: desiredInsets.right - inherited.right
        )
    }
}
