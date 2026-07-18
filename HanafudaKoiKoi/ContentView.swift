import SwiftUI

struct ContentView: View {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false

    var body: some View {
        #if DEBUG
        if let capture = ProcessInfo.processInfo.environment["HK_CAPTURE"], capture != "home" {
            if capture == "onboarding" {
                return AnyView(OnboardingView(onFinished: {}))
            }
            if capture == "upgrade" {
                return AnyView(UpgradeView().preferredColorScheme(.dark))
            }
            let game = GameModel()
            game.captureSetup(capture)
            return AnyView(NavigationStack { GameView(game: game) }.preferredColorScheme(.dark))
        }
        if ProcessInfo.processInfo.environment["HK_SKIP_ONBOARDING"] != nil {
            return AnyView(HomeView())
        }
        #endif
        if !hasSeenOnboarding {
            return AnyView(OnboardingView(onFinished: { hasSeenOnboarding = true }))
        }
        return AnyView(HomeView())
    }
}

#Preview { ContentView() }
