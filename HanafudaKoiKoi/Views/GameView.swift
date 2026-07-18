import SwiftUI

struct GameView: View {
    @ObservedObject var game: GameModel
    @Environment(\.dismiss) private var dismiss

    private let cardWidth: CGFloat = 58
    private let cardHeight: CGFloat = 81

    var body: some View {
        ZStack {
            LinearGradient(colors: [Color(red: 0.05, green: 0.30, blue: 0.20), Color(red: 0.03, green: 0.18, blue: 0.13)],
                           startPoint: .top, endPoint: .bottom)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                scoreHeader

                // Opponent hand (face down)
                HStack(spacing: -14) {
                    ForEach(0..<game.aiHand.count, id: \.self) { _ in
                        CardBackView().frame(width: cardWidth * 0.7, height: cardHeight * 0.7)
                    }
                }
                .frame(height: cardHeight * 0.7)

                capturedRow(cards: game.aiCaptured, title: "Opponent captured")

                Spacer(minLength: 12).frame(maxHeight: 60)

                fieldGrid
                    .padding(20)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(RadialGradient(colors: [Color.white.opacity(0.10), Color.clear],
                                                  center: .center, startRadius: 4, endRadius: 260))
                    )

                Spacer(minLength: 12).frame(maxHeight: 60)

                capturedRow(cards: game.playerCaptured, title: "Your captures")

                Text(game.message)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.vertical, 2)

                // Player hand (face up, tappable)
                HStack(spacing: -8) {
                    ForEach(game.playerHand) { card in
                        Button {
                            game.playerSelectHand(card)
                        } label: {
                            CardView(card: card, isSelectable: true)
                                .frame(width: cardWidth, height: cardHeight)
                        }
                        .disabled(game.currentTurn != .player || game.turnPhase != .playFromHand)
                        .buttonStyle(.plain)
                    }
                }
                .padding(.bottom, 8)

                Spacer(minLength: 0)
            }
            .padding(.horizontal, 10)
            .padding(.top, 8)
            .frame(maxHeight: .infinity, alignment: .top)

            if case .chooseCaptureForHand(let matches) = game.turnPhase {
                capturePicker(matches: matches) { game.playerChooseCapture($0) }
            }
            if case .chooseCaptureForDraw(_, let matches) = game.turnPhase {
                capturePicker(matches: matches) { game.playerChooseDrawCapture($0) }
            }
            if case .koiKoiPrompt(let yaku, let points) = game.turnPhase {
                koiKoiOverlay(yaku: yaku, points: points)
            }
            if case .handOver = game.turnPhase {
                handOverOverlay
            }
            if case .matchOver = game.turnPhase {
                matchOverOverlay
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button("Quit") { dismiss() }.foregroundStyle(.white.opacity(0.8))
            }
        }
    }

    private var scoreHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text("Opponent").font(.system(size: 11)).foregroundStyle(.white.opacity(0.6))
                Text("\(game.aiMatchScore)").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(.white)
            }
            Spacer()
            Text("Hand \(game.handNumber)/\(GameModel.handsPerMatch)")
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                Text("You").font(.system(size: 11)).foregroundStyle(.white.opacity(0.6))
                Text("\(game.playerMatchScore)").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 6)
    }

    private var fieldGrid: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 8) {
            ForEach(game.field) { card in
                CardView(card: card, isHighlighted: game.lastCaptured.contains(card))
                    .frame(width: cardWidth, height: cardHeight)
            }
        }
        .padding(.horizontal, 12)
    }

    private func capturedRow(cards: [HanafudaCard], title: String) -> some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("\(title) (\(cards.count))")
                .font(.system(size: 10, weight: .medium))
                .foregroundStyle(.white.opacity(0.5))
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: -20) {
                    ForEach(cards) { card in
                        CardView(card: card)
                            .frame(width: cardWidth * 0.55, height: cardHeight * 0.55)
                    }
                }
            }
        }
        .frame(height: cardHeight * 0.55 + 16)
        .padding(.horizontal, 12)
    }

    private func capturePicker(matches: [HanafudaCard], onChoose: @escaping (HanafudaCard) -> Void) -> some View {
        VStack(spacing: 14) {
            Text("Choose a match").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
            HStack(spacing: 14) {
                ForEach(matches) { card in
                    Button { onChoose(card) } label: {
                        CardView(card: card, isSelectable: true)
                            .frame(width: cardWidth * 1.3, height: cardHeight * 1.3)
                    }
                    .buttonStyle(.plain)
                }
            }
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.85)))
        .padding(.horizontal, 30)
    }

    private func koiKoiOverlay(yaku: [Yaku], points: Int) -> some View {
        VStack(spacing: 16) {
            Text("Yaku!").font(.system(size: 22, weight: .heavy, design: .rounded)).foregroundStyle(.yellow)
            ForEach(yaku) { y in
                HStack {
                    Text(y.name).foregroundStyle(.white)
                    Spacer()
                    Text("+\(y.points)").foregroundStyle(.yellow)
                }
                .font(.system(size: 14, weight: .medium))
                .frame(width: 220)
            }
            Text("Total: \(points) pts").font(.system(size: 16, weight: .bold)).foregroundStyle(.white)

            HStack(spacing: 12) {
                Button { game.playerCallsKoiKoi() } label: {
                    Text("Koi-Koi\n(keep going)")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 18).padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.yellow))
                }
                Button { game.playerCallsShoubu() } label: {
                    Text("Shoubu\n(bank it)")
                        .multilineTextAlignment(.center)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 18).padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.15)))
                }
            }
        }
        .padding(24)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.9)))
        .padding(.horizontal, 30)
    }

    private var handOverOverlay: some View {
        VStack(spacing: 16) {
            Text(game.lastHandResult)
                .font(.system(size: 17, weight: .bold))
                .multilineTextAlignment(.center)
                .foregroundStyle(.white)
            Button { game.continueToNextHand() } label: {
                Text("Next Hand")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.yellow))
            }
        }
        .padding(28)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.9)))
        .padding(.horizontal, 30)
    }

    private var matchOverOverlay: some View {
        VStack(spacing: 16) {
            Text(matchResultText)
                .font(.system(size: 20, weight: .heavy, design: .rounded))
                .multilineTextAlignment(.center)
                .foregroundStyle(.yellow)
            Text("\(game.playerMatchScore) — \(game.aiMatchScore)")
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
            Button { dismiss() } label: {
                Text("Back to Menu")
                    .font(.system(size: 15, weight: .bold))
                    .foregroundStyle(.black)
                    .padding(.horizontal, 24).padding(.vertical, 12)
                    .background(RoundedRectangle(cornerRadius: 12).fill(Color.yellow))
            }
        }
        .padding(28)
        .background(RoundedRectangle(cornerRadius: 20).fill(Color.black.opacity(0.9)))
        .padding(.horizontal, 30)
    }

    private var matchResultText: String {
        switch game.matchWinner {
        case .player: return "You win the match!"
        case .ai: return "Opponent wins the match."
        case nil: return "Match tied."
        }
    }
}
