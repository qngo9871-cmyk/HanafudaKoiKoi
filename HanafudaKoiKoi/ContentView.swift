import SwiftUI

struct ContentView: View {
    var body: some View {
        #if DEBUG
        if let capture = ProcessInfo.processInfo.environment["HK_CAPTURE"], capture != "home" {
            let game = GameModel()
            game.captureSetup(capture)
            return AnyView(NavigationStack { GameView(game: game) }.preferredColorScheme(.dark))
        }
        #endif
        return AnyView(HomeView())
    }
}

#Preview { ContentView() }
