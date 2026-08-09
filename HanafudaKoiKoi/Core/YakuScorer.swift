import Foundation

struct Yaku: Identifiable, Equatable {
    var id: String { nameKey }
    let nameKey: String
    let points: Int
    var name: String { L(nameKey) }
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
            result.append(Yaku(nameKey: "yaku.fiveBrights", points: 10))
        case 4:
            result.append(hasRainMan
                ? Yaku(nameKey: "yaku.rainyFourBrights", points: 7)
                : Yaku(nameKey: "yaku.fourBrights", points: 8))
        case 3 where !hasRainMan:
            result.append(Yaku(nameKey: "yaku.threeBrights", points: 6))
        default:
            break
        }

        let animals = captured.filter { $0.kind == .animal }
        if animals.count >= 5 {
            result.append(Yaku(nameKey: "yaku.animals", points: 1 + (animals.count - 5)))
        }
        let hasBoar = animals.contains { $0.month == 7 }
        let hasDeer = animals.contains { $0.month == 10 }
        let hasButterflies = animals.contains { $0.month == 6 }
        if hasBoar && hasDeer && hasButterflies {
            result.append(Yaku(nameKey: "yaku.boarDeerButterfly", points: 5))
        }

        let ribbons = captured.filter { $0.kind.isRibbon }
        if ribbons.count >= 5 {
            result.append(Yaku(nameKey: "yaku.ribbons", points: 1 + (ribbons.count - 5)))
        }
        let poetryRibbons = captured.filter { $0.kind == .ribbonPoetry }
        let blueRibbons = captured.filter { $0.kind == .ribbonBlue }
        let hasAllPoetry = poetryRibbons.count == 3
        let hasAllBlue = blueRibbons.count == 3
        if hasAllPoetry {
            result.append(Yaku(nameKey: "yaku.poetryRibbons", points: 6))
        }
        if hasAllBlue {
            result.append(Yaku(nameKey: "yaku.blueRibbons", points: 6))
        }
        if hasAllPoetry && hasAllBlue {
            result.append(Yaku(nameKey: "yaku.poetryBlueCombo", points: 10))
        }

        let plains = captured.filter { $0.kind == .plain }
        if plains.count >= 10 {
            result.append(Yaku(nameKey: "yaku.chaff", points: 1 + (plains.count - 10)))
        }

        let hasMoon = brights.contains { $0.month == 8 }
        let hasCurtain = brights.contains { $0.month == 3 }
        let hasSakeCup = animals.contains { $0.month == 9 }
        if hasMoon && hasSakeCup {
            result.append(Yaku(nameKey: "yaku.moonViewing", points: 5))
        }
        if hasCurtain && hasSakeCup {
            result.append(Yaku(nameKey: "yaku.flowerViewing", points: 5))
        }

        return result
    }

    static func totalPoints(_ captured: [HanafudaCard]) -> Int {
        evaluate(captured).reduce(0) { $0 + $1.points }
    }

    /// Static reference list for the in-app Yaku Guide — every yaku a player can score,
    /// with its point value and a plain-language description of how to complete it.
    static let referenceList: [(nameKey: String, points: String, descKey: String)] = [
        ("yaku.fiveBrights", "10", "yaku.fiveBrights.desc"),
        ("yaku.fourBrights", "8", "yaku.fourBrights.desc"),
        ("yaku.rainyFourBrights", "7", "yaku.rainyFourBrights.desc"),
        ("yaku.threeBrights", "6", "yaku.threeBrights.desc"),
        ("yaku.boarDeerButterfly", "5", "yaku.boarDeerButterfly.desc"),
        ("yaku.animals", "1+", "yaku.animals.desc"),
        ("yaku.ribbons", "1+", "yaku.ribbons.desc"),
        ("yaku.poetryRibbons", "6", "yaku.poetryRibbons.desc"),
        ("yaku.blueRibbons", "6", "yaku.blueRibbons.desc"),
        ("yaku.poetryBlueCombo", "10", "yaku.poetryBlueCombo.desc"),
        ("yaku.chaff", "1+", "yaku.chaff.desc"),
        ("yaku.moonViewing", "5", "yaku.moonViewing.desc"),
        ("yaku.flowerViewing", "5", "yaku.flowerViewing.desc"),
    ]
}
