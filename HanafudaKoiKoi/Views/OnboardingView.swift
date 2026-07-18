import SwiftUI

/// Four-page first-launch walkthrough covering the core Koi-Koi loop: match,
/// capture, score yaku, then choose koi-koi or stop. Shown once, and
/// re-accessible from Home via "How to Play".
struct OnboardingView: View {
    var onFinished: () -> Void

    @State private var page = 0

    private let pages: [(title: String, body: String)] = [
        ("Match to Capture", "Play a card from your hand onto a field card from the same month to capture both. No match? Your card stays on the field for later."),
        ("Collect Yaku", "Capture sets of brights, animals, ribbons, and plain cards to complete scoring combinations called yaku."),
        ("Koi-Koi or Stop", "The moment you complete a yaku, choose: call \"Koi-Koi\" to keep playing for more points, or \"Stop\" to bank what you've got — before your opponent catches up."),
        ("Play the AI", "Pick Easy, Normal, or Hard and see how far your hand can go."),
    ]

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.06, green: 0.09, blue: 0.14), Color(red: 0.11, green: 0.16, blue: 0.22)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 28) {
                Spacer()

                Image(systemName: "leaf.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.yellow)

                Text(pages[page].title)
                    .font(.system(size: 30, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)

                Text(pages[page].body)
                    .font(.body)
                    .foregroundStyle(.white.opacity(0.75))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 36)

                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { i in
                        Circle()
                            .fill(i == page ? Color.white : Color.white.opacity(0.25))
                            .frame(width: 6, height: 6)
                    }
                }

                Spacer()

                Button(action: advance) {
                    Text(page == pages.count - 1 ? "Let's Play" : "Next")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 4)
                }
                .buttonStyle(.borderedProminent)
                .tint(.yellow)
                .foregroundStyle(.black)
                .controlSize(.large)
                .padding(.horizontal, 36)
                .padding(.bottom, 50)
            }
        }
        .preferredColorScheme(.dark)
        .animation(.easeInOut, value: page)
    }

    private func advance() {
        if page < pages.count - 1 {
            page += 1
        } else {
            onFinished()
        }
    }
}

#Preview { OnboardingView(onFinished: {}) }
