import Foundation

enum Turn: Equatable { case player, ai }

/// vsAI: seat `.ai` is driven by AIPlayer heuristics. twoPlayer: seat `.ai` (labelled
/// "Player 2" in the UI) is a second human, passing the same device back and forth.
enum GameMode { case vsAI, twoPlayer }

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
    var mode: GameMode = .vsAI
    private var koiKoiCalls: [Turn: Int] = [:]
    private var pendingHandCard: HanafudaCard?

    // MARK: - Match lifecycle

    func startNewMatch(difficulty: AIDifficulty) {
        mode = .vsAI
        self.difficulty = difficulty
        playerMatchScore = 0
        aiMatchScore = 0
        handNumber = 1
        matchWinner = nil
        dealHand()
    }

    /// Pass-and-play: seat `.ai` is a second human sharing this device — see `GameMode.twoPlayer`.
    func startLocalTwoPlayerMatch() {
        mode = .twoPlayer
        difficulty = .normal
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
        turnPhase = .playFromHand
        message = currentTurnMovePrompt()
        if currentTurn == .ai && mode == .vsAI {
            turnPhase = .aiThinking
            runAITurn()
        }
    }

    private func currentTurnMovePrompt() -> String {
        if currentTurn == .player { return L("game.yourMove") }
        return mode == .twoPlayer ? L("game.player2Move") : L("game.opponentMove")
    }

    // MARK: - Hand card selection (works for whichever seat is currently human-controlled:
    // `.player` always, and `.ai` too in local two-player mode)

    func selectFromHand(_ card: HanafudaCard) {
        guard turnPhase == .playFromHand else { return }
        if currentTurn == .player {
            guard playerHand.contains(card) else { return }
            playerHand.removeAll { $0.id == card.id }
            resolvePlacement(of: card, isHandCard: true, for: .player)
        } else if mode == .twoPlayer {
            guard aiHand.contains(card) else { return }
            aiHand.removeAll { $0.id == card.id }
            resolvePlacement(of: card, isHandCard: true, for: .ai)
        }
    }

    /// Legacy name, kept for the vsAI player-hand call sites.
    func playerSelectHand(_ card: HanafudaCard) { selectFromHand(card) }

    func playerChooseCapture(_ target: HanafudaCard) {
        guard case .chooseCaptureForHand(let matches) = turnPhase, matches.contains(target),
              let card = pendingHandCard else { return }
        pendingHandCard = nil
        let seat = currentTurn
        capture(card: card, target: target, for: seat)
        drawAndMatch(for: seat)
    }

    func playerChooseDrawCapture(_ target: HanafudaCard) {
        guard case .chooseCaptureForDraw(let drawn, let matches) = turnPhase, matches.contains(target) else { return }
        let seat = currentTurn
        capture(card: drawn, target: target, for: seat)
        finishCaptureStep(for: seat)
    }

    // MARK: - Koi-koi decision (whichever seat is currently prompted — always `.player`
    // in vsAI mode; either seat in local two-player mode)

    func callsKoiKoi() {
        guard case .koiKoiPrompt = turnPhase else { return }
        koiKoiCalls[currentTurn, default: 0] += 1
        message = L("game.koiKoiKeepGoing")
        endTurn()
    }

    func callsShoubu() {
        guard case .koiKoiPrompt(_, let points) = turnPhase else { return }
        settleHand(winner: currentTurn, points: points)
    }

    /// Legacy names, kept for the vsAI call sites (identical behavior — koi-koi/shoubu
    /// are only ever prompted to `.player` in vsAI mode anyway).
    func playerCallsKoiKoi() { callsKoiKoi() }
    func playerCallsShoubu() { callsShoubu() }

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

        // 2+ possible targets — needs a decision. In vsAI mode only `.player` is human;
        // in local two-player mode both seats are human.
        let isHumanSeat = player == .player || mode == .twoPlayer
        if isHumanSeat {
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
            if player == .player || mode == .twoPlayer {
                turnPhase = .koiKoiPrompt(newYaku: yaku, totalPoints: total)
                let yakuNames = yaku.map(\.name).joined(separator: ", ")
                let scoredKey = player == .player ? "game.youScored" : "game.player2Scored"
                message = String(format: L(scoredKey), yakuNames)
            } else {
                let keepGoing = AIPlayer.decideKoiKoi(currentPoints: total, captured: aiCaptured,
                                                       remainingHandCount: aiHand.count,
                                                       opponentCapturedCount: playerCaptured.count,
                                                       difficulty: difficulty)
                if keepGoing {
                    koiKoiCalls[.ai, default: 0] += 1
                    message = L("game.opponentKoiKoi")
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
        if currentTurn == .ai && mode == .vsAI {
            turnPhase = .aiThinking
            message = L("game.opponentMove")
            runAITurn()
        } else {
            turnPhase = .playFromHand
            message = currentTurnMovePrompt()
        }
    }

    private func runAITurn() {
        guard mode == .vsAI else { return }
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
            // Standard rule: the score doubles for EVERY koi-koi call made during the hand,
            // by either player — not just calls made by the eventual winner. Calling koi-koi
            // is a gamble that raises the stakes for whoever ends up winning the hand, even
            // if that turns out to be the opponent (e.g. AI calls koi-koi hoping for a bigger
            // yaku, player then completes a yaku first and stops — player's win is still
            // doubled by the AI's earlier koi-koi call).
            let calls = koiKoiCalls[.player, default: 0] + koiKoiCalls[.ai, default: 0]
            if calls > 0 { finalPoints = points * Int(pow(2.0, Double(calls))) }
            if winner == .player { playerMatchScore += finalPoints }
            else { aiMatchScore += finalPoints }
            let key: String
            if winner == .player { key = "game.youWonHand" }
            else { key = mode == .twoPlayer ? "game.player2WonHand" : "game.opponentWonHand" }
            lastHandResult = String(format: L(key), finalPoints)
        } else {
            lastHandResult = L("game.handDraw")
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
        message = L("game.yourMove")

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
