import SwiftUI

@main
struct UIStudioApp: App {
    @State private var store = StudioStore()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(store)
        }
    }
}
