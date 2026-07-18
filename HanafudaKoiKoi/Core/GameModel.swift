import Foundation

enum Turn { case player, ai }

enum TurnPhase: Equatable {
    case playFromHand
    case chooseCaptureForHand([HanafudaCard])
    case chooseCaptureForDraw(HanafudaCard, [HanafudaCard])
    case aiThinking
    case koiKoiPrompt(newYaku: [Yaku], totalPoints: Int)
    case handOver
    case matchOver
}

struct KoiKoiPromptInfo: Equatable {
    let newYaku: [Yaku]
    let totalPoints: Int
}

/// Drives a full Koi-Koi hand: dealing, capture resolution, yaku detection,
/// koi-koi/shoubu decisions, and hand-to-hand scoring across a short match.
final class GameModel: ObservableObject {

    static let handsPerMatch = 3

    // Table state
    @Published var deck: [HanafudaCard] = []
    @Published var field: [HanafudaCard] = []
    @Published var playerHand: [HanafudaCard] = []
    @Published var aiHand: [HanafudaCard] = []
    @Published var playerCaptured: [HanafudaCard] = []
    @Published var aiCaptured: [HanafudaCard] = []

    // Turn state
    @Published var currentTurn: Turn = .player
    @Published var turnPhase: TurnPhase = .playFromHand
    @Published var lastCaptured: [HanafudaCard] = []
    @Published var message: String = ""

    // Match state
    @Published var playerMatchScore: Int = 0
    @Published var aiMatchScore: Int = 0
    @Published var handNumber: Int = 1
    @Published var matchWinner: Turn?
    @Published var lastHandResult: String = ""

    var difficulty: AIDifficulty = .normal
    private var koiKoiCalls: [Turn: Int] = [:]
    private var pendingHandCard: HanafudaCard?

    // MARK: - Match lifecycle

    func startNewMatch(difficulty: AIDifficulty) {
        self.difficulty = difficulty
        playerMatchScore = 0
        aiMatchScore = 0
        handNumber = 1
        matchWinner = nil
        dealHand()
    }

    func dealHand() {
        var shuffled = HanafudaDeck.fullDeck.shuffled()
        playerHand = Array(shuffled.prefix(8)); shuffled.removeFirst(8)
        aiHand = Array(shuffled.prefix(8)); shuffled.removeFirst(8)
        field = Array(shuffled.prefix(8)); shuffled.removeFirst(8)
        deck = shuffled

        playerCaptured = []
        aiCaptured = []
        lastCaptured = []
        koiKoiCalls = [:]
        currentTurn = handNumber % 2 == 1 ? .player : .ai
        turnPhase = currentTurn == .player ? .playFromHand : .aiThinking
        message = currentTurn == .player ? "Your move — pick a card." : "Opponent's move..."
        if currentTurn == .ai { runAITurn() }
    }

    // MARK: - Player: hand card

    func playerSelectHand(_ card: HanafudaCard) {
        guard currentTurn == .player, turnPhase == .playFromHand, playerHand.contains(card) else { return }
        playerHand.removeAll { $0.id == card.id }
        resolvePlacement(of: card, isHandCard: true, for: .player)
    }

    func playerChooseCapture(_ target: HanafudaCard) {
        guard case .chooseCaptureForHand(let matches) = turnPhase, matches.contains(target),
              let card = pendingHandCard else { return }
        pendingHandCard = nil
        capture(card: card, target: target, for: .player)
        drawAndMatch(for: .player)
    }

    func playerChooseDrawCapture(_ target: HanafudaCard) {
        guard case .chooseCaptureForDraw(let drawn, let matches) = turnPhase, matches.contains(target) else { return }
        capture(card: drawn, target: target, for: .player)
        finishCaptureStep(for: .player)
    }

    // MARK: - Koi-koi decision (player)

    func playerCallsKoiKoi() {
        guard case .koiKoiPrompt = turnPhase else { return }
        koiKoiCalls[.player, default: 0] += 1
        message = "Koi-Koi! Keep going."
        endTurn()
    }

    func playerCallsShoubu() {
        guard case .koiKoiPrompt(_, let points) = turnPhase else { return }
        settleHand(winner: .player, points: points)
    }

    // MARK: - Core resolution

    /// Places a card (from hand or drawn from the deck) onto the field, capturing if it matches.
    private func resolvePlacement(of card: HanafudaCard, isHandCard: Bool, for player: Turn) {
        let matches = field.filter { $0.month == card.month }

        if matches.isEmpty {
            field.append(card)
            if isHandCard {
                drawAndMatch(for: player)
            } else {
                finishCaptureStep(for: player)
            }
            return
        }

        if matches.count == 3 {
            // All three remaining field cards of this month plus the played card — sweep.
            capture(card: card, targets: matches, for: player)
            if isHandCard { drawAndMatch(for: player) } else { finishCaptureStep(for: player) }
            return
        }

        if matches.count == 1 {
            capture(card: card, target: matches[0], for: player)
            if isHandCard { drawAndMatch(for: player) } else { finishCaptureStep(for: player) }
            return
        }

        // 2+ possible targets — needs a decision.
        if player == .player {
            if isHandCard {
                pendingHandCard = card
                turnPhase = .chooseCaptureForHand(matches)
            } else {
                turnPhase = .chooseCaptureForDraw(card, matches)
            }
        } else {
            let choice = AIPlayer.chooseCapture(among: matches, difficulty: difficulty)
            capture(card: card, target: choice, for: player)
            if isHandCard { drawAndMatch(for: player) } else { finishCaptureStep(for: player) }
        }
    }

    private func drawAndMatch(for player: Turn) {
        guard !deck.isEmpty else { finishCaptureStep(for: player); return }
        let drawn = deck.removeFirst()
        resolvePlacement(of: drawn, isHandCard: false, for: player)
    }

    private func capture(card: HanafudaCard, target: HanafudaCard, for player: Turn) {
        field.removeAll { $0.id == target.id }
        lastCaptured = [card, target]
        appendCaptured([card, target], for: player)
    }

    private func capture(card: HanafudaCard, targets: [HanafudaCard], for player: Turn) {
        field.removeAll { t in targets.contains(where: { $0.id == t.id }) }
        lastCaptured = [card] + targets
        appendCaptured([card] + targets, for: player)
    }

    private func appendCaptured(_ cards: [HanafudaCard], for player: Turn) {
        if player == .player { playerCaptured.append(contentsOf: cards) }
        else { aiCaptured.append(contentsOf: cards) }
    }

    // MARK: - End of a turn's capture sequence

    private func finishCaptureStep(for player: Turn) {
        let captured = player == .player ? playerCaptured : aiCaptured
        let yaku = YakuScorer.evaluate(captured)
        let total = yaku.reduce(0) { $0 + $1.points }
        let alreadyDeclaredThisHand = koiKoiCalls[player] != nil || (player == .player ? playerDeclaredOnce : aiDeclaredOnce)

        if total > 0 && (!alreadyDeclaredThisHand || total > lastDeclaredPoints(for: player)) {
            recordDeclaredPoints(total, for: player)
            if player == .player {
                turnPhase = .koiKoiPrompt(newYaku: yaku, totalPoints: total)
                message = "You scored \(yaku.map(\.name).joined(separator: ", "))! Koi-Koi or stop?"
            } else {
                let keepGoing = AIPlayer.decideKoiKoi(currentPoints: total, captured: aiCaptured,
                                                       remainingHandCount: aiHand.count,
                                                       opponentCapturedCount: playerCaptured.count,
                                                       difficulty: difficulty)
                if keepGoing {
                    koiKoiCalls[.ai, default: 0] += 1
                    message = "Opponent calls Koi-Koi!"
                    endTurn()
                } else {
                    settleHand(winner: .ai, points: total)
                }
            }
            return
        }
        endTurn()
    }

    private var playerDeclaredOnce = false
    private var aiDeclaredOnce = false
    private var playerLastDeclaredPoints = 0
    private var aiLastDeclaredPoints = 0

    private func lastDeclaredPoints(for player: Turn) -> Int {
        player == .player ? playerLastDeclaredPoints : aiLastDeclaredPoints
    }
    private func recordDeclaredPoints(_ points: Int, for player: Turn) {
        if player == .player { playerDeclaredOnce = true; playerLastDeclaredPoints = points }
        else { aiDeclaredOnce = true; aiLastDeclaredPoints = points }
    }

    // MARK: - Turn switching

    private func endTurn() {
        if playerHand.isEmpty && aiHand.isEmpty {
            settleHand(winner: nil, points: 0)   // hand exhausted with no shoubu called — draw
            return
        }
        currentTurn = currentTurn == .player ? .ai : .player
        if currentTurn == .ai {
            turnPhase = .aiThinking
            message = "Opponent's move..."
            runAITurn()
        } else {
            turnPhase = .playFromHand
            message = "Your move — pick a card."
        }
    }

    private func runAITurn() {
        guard !aiHand.isEmpty else { endTurn(); return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.7) { [weak self] in
            guard let self, self.currentTurn == .ai else { return }
            let card = self.aiHand.removeFirst()
            self.resolvePlacement(of: card, isHandCard: true, for: .ai)
        }
    }

    // MARK: - Hand settlement

    private func settleHand(winner: Turn?, points: Int) {
        var finalPoints = points
        if let winner {
            let calls = koiKoiCalls[winner, default: 0]
            if calls > 0 { finalPoints = points * Int(pow(2.0, Double(calls))) }
            if winner == .player { playerMatchScore += finalPoints }
            else { aiMatchScore += finalPoints }
            lastHandResult = winner == .player
                ? "You won the hand — +\(finalPoints) points"
                : "Opponent won the hand — +\(finalPoints) points"
        } else {
            lastHandResult = "Hand ended in a draw — no points."
        }

        playerDeclaredOnce = false; aiDeclaredOnce = false
        playerLastDeclaredPoints = 0; aiLastDeclaredPoints = 0

        if handNumber >= Self.handsPerMatch {
            matchWinner = playerMatchScore == aiMatchScore ? nil : (playerMatchScore > aiMatchScore ? .player : .ai)
            turnPhase = .matchOver
        } else {
            turnPhase = .handOver
        }
    }

    func continueToNextHand() {
        handNumber += 1
        dealHand()
    }
}

#if DEBUG
// MARK: - Screenshot capture helpers (DEBUG only; launch args never set in production)
extension GameModel {

    /// Entry point. name: table | yaku | matchover
    func captureSetup(_ name: String) {
        difficulty = .normal
        playerMatchScore = 4
        aiMatchScore = 2
        handNumber = 2

        var shuffled = HanafudaDeck.fullDeck.shuffled()
        playerHand = Array(shuffled.prefix(6)); shuffled.removeFirst(6)
        aiHand = Array(shuffled.prefix(5)); shuffled.removeFirst(5)
        field = Array(shuffled.prefix(6)); shuffled.removeFirst(6)
        deck = shuffled

        let brights = HanafudaDeck.fullDeck.filter { $0.kind == .bright }
        let animals = HanafudaDeck.fullDeck.filter { $0.kind == .animal }
        playerCaptured = Array(brights.prefix(3)) + Array(animals.prefix(4))
        aiCaptured = Array(HanafudaDeck.fullDeck.filter { $0.kind == .plain }.prefix(6))

        currentTurn = .player
        lastCaptured = Array(playerCaptured.suffix(2))
        message = "Your move — pick a card."

        switch name {
        case "yaku":
            let yaku = YakuScorer.evaluate(playerCaptured)
            turnPhase = .koiKoiPrompt(newYaku: yaku, totalPoints: yaku.reduce(0) { $0 + $1.points })
        case "matchover":
            handNumber = Self.handsPerMatch
            matchWinner = .player
            turnPhase = .matchOver
        default:
            turnPhase = .playFromHand
        }
    }
}
#endif
