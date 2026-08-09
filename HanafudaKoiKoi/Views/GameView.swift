import SwiftUI

struct GameView: View {
    @ObservedObject var game: GameModel
    @Environment(\.dismiss) private var dismiss
    @AppStorage("cardBackStyle") private var cardBackStyleRaw = CardBackStyle.ink.rawValue
    @State private var passOverlayVisible = false

    private var cardBackStyle: CardBackStyle { CardBackStyle(rawValue: cardBackStyleRaw) ?? .ink }

    // Design height the fixed-size board elements below were sized for (full-height iPhone).
    // On shorter viewports — iPhone SE, or an iPad running this iPhone-only app in its
    // compatibility window — everything is scaled down so the board always fits without
    // clipping or overlapping (this is what triggered the App Store Guideline 4 rejection).
    private let designHeight: CGFloat = 820

    private func scale(for availableHeight: CGFloat) -> CGFloat {
        min(1.0, max(0.6, availableHeight / designHeight))
    }

    /// In vsAI mode the bottom seat is always the human player. In local two-player mode
    /// the bottom (face-up, tappable) seat is whichever human's turn it currently is.
    private var bottomSeatIsPlayer: Bool {
        game.mode != .twoPlayer || game.currentTurn == .player
    }
    private var bottomHand: [HanafudaCard] { bottomSeatIsPlayer ? game.playerHand : game.aiHand }
    private var topHandCount: Int { bottomSeatIsPlayer ? game.aiHand.count : game.playerHand.count }

    private var topLabel: String {
        if game.mode != .twoPlayer { return L("game.opponentCaptured") }
        return bottomSeatIsPlayer ? L("game.player2Captured") : L("game.player1Captured")
    }
    private var bottomLabel: String {
        if game.mode != .twoPlayer { return L("game.yourCaptures") }
        return bottomSeatIsPlayer ? L("game.player1Captured") : L("game.player2Captured")
    }
    private var topCaptured: [HanafudaCard] { bottomSeatIsPlayer ? game.aiCaptured : game.playerCaptured }
    private var bottomCaptured: [HanafudaCard] { bottomSeatIsPlayer ? game.playerCaptured : game.aiCaptured }

    var body: some View {
        GeometryReader { geo in
            let scale = scale(for: geo.size.height)
            let cardWidth: CGFloat = 58 * scale
            let cardHeight: CGFloat = 81 * scale
            let gapMax: CGFloat = 60 * scale
            let gapMin: CGFloat = 8 * scale

            ZStack {
                LinearGradient(colors: [Color(red: 0.05, green: 0.30, blue: 0.20), Color(red: 0.03, green: 0.18, blue: 0.13)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                VStack(spacing: 16 * scale) {
                    scoreHeader

                    // Away hand (face down)
                    HStack(spacing: -14) {
                        ForEach(0..<topHandCount, id: \.self) { _ in
                            CardBackView(style: cardBackStyle).frame(width: cardWidth * 0.7, height: cardHeight * 0.7)
                        }
                    }
                    .frame(height: cardHeight * 0.7)

                    capturedRow(cards: topCaptured, title: topLabel, cardWidth: cardWidth, cardHeight: cardHeight)

                    Spacer(minLength: gapMin).frame(maxHeight: gapMax)

                    fieldGrid(cardWidth: cardWidth, cardHeight: cardHeight)
                        .padding(20 * scale)
                        .background(
                            RoundedRectangle(cornerRadius: 24)
                                .fill(RadialGradient(colors: [Color.white.opacity(0.10), Color.clear],
                                                      center: .center, startRadius: 4, endRadius: 260))
                        )

                    Spacer(minLength: gapMin).frame(maxHeight: gapMax)

                    capturedRow(cards: bottomCaptured, title: bottomLabel, cardWidth: cardWidth, cardHeight: cardHeight)

                    Text(game.message)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.85))
                        .padding(.vertical, 2)

                    // Active hand (face up, tappable)
                    HStack(spacing: -8) {
                        ForEach(bottomHand) { card in
                            Button {
                                game.selectFromHand(card)
                            } label: {
                                CardView(card: card, isSelectable: true)
                                    .frame(width: cardWidth, height: cardHeight)
                            }
                            .disabled(game.turnPhase != .playFromHand)
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
                    capturePicker(matches: matches, cardWidth: cardWidth, cardHeight: cardHeight) { game.playerChooseCapture($0) }
                }
                if case .chooseCaptureForDraw(_, let matches) = game.turnPhase {
                    capturePicker(matches: matches, cardWidth: cardWidth, cardHeight: cardHeight) { game.playerChooseDrawCapture($0) }
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

                if game.mode == .twoPlayer && passOverlayVisible {
                    passDeviceOverlay
                }
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(L("game.quit")) { dismiss() }.foregroundStyle(.white.opacity(0.8))
            }
        }
        .onAppear {
            if game.mode == .twoPlayer { passOverlayVisible = true }
        }
        .onChange(of: game.currentTurn) { _ in
            if game.mode == .twoPlayer { passOverlayVisible = true }
        }
    }

    private var scoreHeader: some View {
        HStack {
            VStack(alignment: .leading, spacing: 1) {
                Text(game.mode == .twoPlayer ? L("game.player2") : L("game.opponentLabel"))
                    .font(.system(size: 11)).foregroundStyle(.white.opacity(0.6))
                Text("\(game.aiMatchScore)").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(.white)
            }
            Spacer()
            Text(String(format: L("game.handLabel"), game.handNumber, GameModel.handsPerMatch))
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(.white.opacity(0.7))
            Spacer()
            VStack(alignment: .trailing, spacing: 1) {
                Text(game.mode == .twoPlayer ? L("game.player1") : L("game.youLabel"))
                    .font(.system(size: 11)).foregroundStyle(.white.opacity(0.6))
                Text("\(game.playerMatchScore)").font(.system(size: 20, weight: .bold, design: .rounded)).foregroundStyle(.white)
            }
        }
        .padding(.horizontal, 6)
    }

    private func fieldGrid(cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 6), count: 4), spacing: 8) {
            ForEach(game.field) { card in
                CardView(card: card, isHighlighted: game.lastCaptured.contains(card))
                    .frame(width: cardWidth, height: cardHeight)
            }
        }
        .padding(.horizontal, 12)
    }

    private func capturedRow(cards: [HanafudaCard], title: String, cardWidth: CGFloat, cardHeight: CGFloat) -> some View {
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

    private func capturePicker(matches: [HanafudaCard], cardWidth: CGFloat, cardHeight: CGFloat, onChoose: @escaping (HanafudaCard) -> Void) -> some View {
        VStack(spacing: 14) {
            Text(L("game.chooseMatch")).font(.system(size: 16, weight: .bold)).foregroundStyle(.white)
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
            Text(L("game.yaku")).font(.system(size: 22, weight: .heavy, design: .rounded)).foregroundStyle(.yellow)
            ForEach(yaku) { y in
                HStack {
                    Text(y.name).foregroundStyle(.white)
                    Spacer()
                    Text("+\(y.points)").foregroundStyle(.yellow)
                }
                .font(.system(size: 14, weight: .medium))
                .frame(width: 220)
            }
            Text(String(format: L("game.total"), points)).font(.system(size: 16, weight: .bold)).foregroundStyle(.white)

            HStack(spacing: 12) {
                Button { game.callsKoiKoi() } label: {
                    Text(L("game.koiKoiButton"))
                        .multilineTextAlignment(.center)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 18).padding(.vertical, 12)
                        .background(RoundedRectangle(cornerRadius: 12).fill(Color.yellow))
                }
                Button { game.callsShoubu() } label: {
                    Text(L("game.shoubuButton"))
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
                Text(L("game.nextHand"))
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
                Text(L("game.backToMenu"))
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

    /// Full-screen privacy gate shown between turns in local two-player mode, so a
    /// player doesn't see the other's hand while passing the device across the table.
    private var passDeviceOverlay: some View {
        ZStack {
            Color.black.opacity(0.97).ignoresSafeArea()
            VStack(spacing: 20) {
                Image(systemName: "hand.tap.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.yellow)
                Text(String(format: L("game.passToPlayer"), game.currentTurn == .player ? L("game.player1") : L("game.player2")))
                    .font(.system(size: 20, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)
                Button { passOverlayVisible = false } label: {
                    Text(L("game.readyReveal"))
                        .font(.system(size: 15, weight: .bold))
                        .foregroundStyle(.black)
                        .padding(.horizontal, 28).padding(.vertical, 14)
                        .background(RoundedRectangle(cornerRadius: 14).fill(Color.yellow))
                }
            }
        }
    }

    private var matchResultText: String {
        switch game.matchWinner {
        case .player: return game.mode == .twoPlayer ? String(format: L("game.playerWinsMatch"), L("game.player1")) : L("game.youWinMatch")
        case .ai: return game.mode == .twoPlayer ? String(format: L("game.playerWinsMatch"), L("game.player2")) : L("game.opponentWinsMatch")
        case nil: return L("game.matchTied")
        }
    }
}
