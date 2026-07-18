import Foundation

enum AIDifficulty: String, CaseIterable {
    case easy, normal, hard

    var blunderChance: Double {
        switch self {
        case .easy: return 0.35
        case .normal: return 0.12
        case .hard: return 0.0
        }
    }
}

enum AIPlayer {

    private static func value(_ card: HanafudaCard) -> Int {
        switch card.kind {
        case .bright: return 40
        case .animal: return card.month == 9 ? 26 : 20   // sake cup slightly favoured (viewing yaku)
        case .ribbonPoetry, .ribbonBlue: return 22
        case .ribbonRed, .ribbonPlain: return 12
        case .plain: return 4
        }
    }

    /// Choose which field card to pair with a played/drawn card when more than one match exists.
    static func chooseCapture(among matches: [HanafudaCard], difficulty: AIDifficulty) -> HanafudaCard {
        if difficulty == .easy, Double.random(in: 0...1) < difficulty.blunderChance, matches.count > 1 {
            return matches.randomElement()!
        }
        return matches.max { value($0) < value($1) } ?? matches[0]
    }

    /// Decide whether the AI calls "koi-koi" (keep playing) or "shoubu" (bank the points and end the hand).
    static func decideKoiKoi(currentPoints: Int, captured: [HanafudaCard], remainingHandCount: Int,
                              opponentCapturedCount: Int, difficulty: AIDifficulty) -> Bool {
        if difficulty == .easy { return Double.random(in: 0...1) < 0.5 }

        // Rough upside estimate: how close is this hand to a bigger yaku.
        let brights = captured.filter { $0.kind == .bright }.count
        let animals = captured.filter { $0.kind == .animal }.count
        let ribbons = captured.filter { $0.kind.isRibbon }.count
        var upside = 0
        if brights == 3 || brights == 4 { upside += 3 }
        if animals >= 3 && animals < 5 { upside += 2 }
        if ribbons >= 3 && ribbons < 5 { upside += 2 }

        // Running out of hand cards or already well ahead in captures narrows the safe window.
        let risk = max(0, opponentCapturedCount - captured.count) + (remainingHandCount <= 1 ? 3 : 0)

        if difficulty == .hard {
            // Play tighter: bank sooner once points are meaningful unless upside clearly outweighs risk.
            if currentPoints >= 7 { return upside > risk + 2 }
            return upside >= risk
        }

        // normal
        if currentPoints >= 5 && risk > upside { return false }
        return currentPoints < 8
    }
}
