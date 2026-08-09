import SwiftUI

@main
struct HanafudaKoiKoiApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LocalizationManager.shared)
        }
    }
}
