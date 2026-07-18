import SwiftUI

struct HomeView: View {
    @StateObject private var game = GameModel()
    @StateObject private var purchases = PurchaseManager.shared
    @State private var showGame = false
    @State private var showUpgrade = false
    @State private var pendingDifficulty: AIDifficulty = .normal

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(red: 0.06, green: 0.09, blue: 0.14), Color(red: 0.11, green: 0.16, blue: 0.22)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                GeometryReader { geo in
                    ZStack {
                        decorativeCard(rotation: -18, color: HanafudaDeck.monthColor(3))
                            .position(x: geo.size.width * 0.18, y: geo.size.height * 0.30)
                        decorativeCard(rotation: 14, color: HanafudaDeck.monthColor(8))
                            .position(x: geo.size.width * 0.85, y: geo.size.height * 0.22)
                        decorativeCard(rotation: 24, color: HanafudaDeck.monthColor(6))
                            .position(x: geo.size.width * 0.80, y: geo.size.height * 0.72)
                        decorativeCard(rotation: -12, color: HanafudaDeck.monthColor(1))
                            .position(x: geo.size.width * 0.15, y: geo.size.height * 0.80)
                    }
                }
                .allowsHitTesting(false)

                VStack(spacing: 28) {
                    Spacer(minLength: 40).frame(maxHeight: 90)

                    VStack(spacing: 6) {
                        Image(systemName: "leaf.fill")
                            .font(.system(size: 44))
                            .foregroundStyle(.yellow)
                        Text("Koi-Koi")
                            .font(.system(size: 40, weight: .heavy, design: .rounded))
                            .foregroundStyle(.white)
                        Text("Hanafuda · Go-Stop · Hwatu")
                            .font(.system(size: 15, weight: .medium))
                            .foregroundStyle(.white.opacity(0.65))
                    }

                    VStack(spacing: 14) {
                        ForEach(AIDifficulty.allCases, id: \.self) { level in
                            Button {
                                if level == .hard && !purchases.isPro {
                                    showUpgrade = true
                                } else {
                                    pendingDifficulty = level
                                    game.startNewMatch(difficulty: level)
                                    showGame = true
                                }
                            } label: {
                                HStack {
                                    Text(label(for: level))
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                    Spacer()
                                    if level == .hard && !purchases.isPro {
                                        Image(systemName: "lock.fill").font(.system(size: 14))
                                    } else {
                                        Image(systemName: "chevron.right").font(.system(size: 14))
                                    }
                                }
                                .foregroundStyle(.white)
                                .padding(.horizontal, 20).padding(.vertical, 16)
                                .background(RoundedRectangle(cornerRadius: 14).fill(Color.white.opacity(0.08)))
                            }
                        }
                    }
                    .padding(.horizontal, 28)

                    Spacer()

                    if !purchases.isPro {
                        Button { showUpgrade = true } label: {
                            Text("Unlock Pro — Hard AI, Local 2-Player & Card Backs")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.yellow)
                        }
                        .padding(.bottom, 20)
                    }
                }
            }
            .navigationDestination(isPresented: $showGame) {
                GameView(game: game)
            }
            .sheet(isPresented: $showUpgrade) {
                UpgradeView()
            }
            .task { await purchases.loadProduct() }
        }
        .preferredColorScheme(.dark)
    }

    private func decorativeCard(rotation: Double, color: Color) -> some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(color)
            .frame(width: 90, height: 126)
            .opacity(0.16)
            .rotationEffect(.degrees(rotation))
    }

    private func label(for level: AIDifficulty) -> String {
        switch level {
        case .easy: return "Play — Easy"
        case .normal: return "Play — Normal"
        case .hard: return "Play — Hard"
        }
    }
}

#Preview { HomeView() }
