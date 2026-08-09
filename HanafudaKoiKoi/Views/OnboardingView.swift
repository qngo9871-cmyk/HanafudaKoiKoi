import SwiftUI

/// Four-page first-launch walkthrough covering the core Koi-Koi loop: match,
/// capture, score yaku, then choose koi-koi or stop. Shown once, and
/// re-accessible from Home via "How to Play".
struct OnboardingView: View {
    var onFinished: () -> Void

    @State private var page = 0

    var onOpenYakuGuide: (() -> Void)? = nil

    private var pages: [(title: String, body: String)] {
        [
            (L("onboarding.page1.title"), L("onboarding.page1.body")),
            (L("onboarding.page2.title"), L("onboarding.page2.body")),
            (L("onboarding.page3.title"), L("onboarding.page3.body")),
            (L("onboarding.page4.title"), L("onboarding.page4.body")),
        ]
    }

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

                if page == 1, let onOpenYakuGuide {
                    Button(action: onOpenYakuGuide) {
                        Text(L("onboarding.seeYakuGuide"))
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundStyle(.yellow)
                    }
                }

                HStack(spacing: 8) {
                    ForEach(pages.indices, id: \.self) { i in
                        Circle()
                            .fill(i == page ? Color.white : Color.white.opacity(0.25))
                            .frame(width: 6, height: 6)
                    }
                }

                Spacer()

                Button(action: advance) {
                    Text(page == pages.count - 1 ? L("onboarding.letsPlay") : L("onboarding.next"))
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
