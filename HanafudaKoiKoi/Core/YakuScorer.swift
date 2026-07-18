import Foundation

struct Yaku: Identifiable, Equatable {
    var id: String { name }
    let name: String
    let points: Int
}

enum YakuScorer {

    /// Compute every yaku currently satisfied by a captured-card set. Pure function —
    /// call it fresh each time (no incremental state) so "newly achieved" is just a diff
    /// of totals between two calls.
    static func evaluate(_ captured: [HanafudaCard]) -> [Yaku] {
        var result: [Yaku] = []

        let brights = captured.filter { $0.kind == .bright }
        let hasRainMan = brights.contains { $0.month == 11 }
        switch brights.count {
        case 5:
            result.append(Yaku(name: "Five Brights", points: 10))
        case 4:
            result.append(hasRainMan
                ? Yaku(name: "Rainy Four Brights", points: 7)
                : Yaku(name: "Four Brights", points: 8))
        case 3 where !hasRainMan:
            result.append(Yaku(name: "Three Brights", points: 6))
        default:
            break
        }

        let animals = captured.filter { $0.kind == .animal }
        if animals.count >= 5 {
            result.append(Yaku(name: "Animals", points: 1 + (animals.count - 5)))
        }
        let hasBoar = animals.contains { $0.month == 7 }
        let hasDeer = animals.contains { $0.month == 10 }
        let hasButterflies = animals.contains { $0.month == 6 }
        if hasBoar && hasDeer && hasButterflies {
            result.append(Yaku(name: "Boar-Deer-Butterfly", points: 5))
        }

        let ribbons = captured.filter { $0.kind.isRibbon }
        if ribbons.count >= 5 {
            result.append(Yaku(name: "Ribbons", points: 1 + (ribbons.count - 5)))
        }
        let poetryRibbons = captured.filter { $0.kind == .ribbonPoetry }
        let blueRibbons = captured.filter { $0.kind == .ribbonBlue }
        let hasAllPoetry = poetryRibbons.count == 3
        let hasAllBlue = blueRibbons.count == 3
        if hasAllPoetry {
            result.append(Yaku(name: "Poetry Ribbons", points: 6))
        }
        if hasAllBlue {
            result.append(Yaku(name: "Blue Ribbons", points: 6))
        }
        if hasAllPoetry && hasAllBlue {
            result.append(Yaku(name: "Poetry + Blue Combo", points: 10))
        }

        let plains = captured.filter { $0.kind == .plain }
        if plains.count >= 10 {
            result.append(Yaku(name: "Chaff", points: 1 + (plains.count - 10)))
        }

        let hasMoon = brights.contains { $0.month == 8 }
        let hasCurtain = brights.contains { $0.month == 3 }
        let hasSakeCup = animals.contains { $0.month == 9 }
        if hasMoon && hasSakeCup {
            result.append(Yaku(name: "Moon Viewing", points: 5))
        }
        if hasCurtain && hasSakeCup {
            result.append(Yaku(name: "Flower Viewing", points: 5))
        }

        return result
    }

    static func totalPoints(_ captured: [HanafudaCard]) -> Int {
        evaluate(captured).reduce(0) { $0 + $1.points }
    }
}
