import SwiftUI

enum CardKind: String, Equatable, Hashable, Codable {
    case bright
    case animal
    case ribbonPoetry   // akatan — Jan/Feb/Mar red poem ribbons
    case ribbonRed      // plain red ribbon — Apr/May/Jul
    case ribbonBlue     // aotan — Jun/Sep/Oct
    case ribbonPlain    // Nov ribbon
    case plain

    var isRibbon: Bool {
        switch self {
        case .ribbonPoetry, .ribbonRed, .ribbonBlue, .ribbonPlain: return true
        default: return false
        }
    }
}

struct HanafudaCard: Identifiable, Equatable, Hashable {
    let id: Int
    let month: Int          // 1...12
    let kind: CardKind
    let name: String        // canonical English identifier, not shown in UI
    let nameKey: String     // Localizable.strings key for the on-card label
    let symbol: String      // SF Symbol used on the card face

    /// Localized card-face label — always use this for display, never `name` directly.
    var localizedName: String { L(nameKey) }

    static func == (lhs: HanafudaCard, rhs: HanafudaCard) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum HanafudaDeck {

    /// The canonical 48-card Koi-Koi deck, in the standard month order.
    static let fullDeck: [HanafudaCard] = {
        var id = 0
        var cards: [HanafudaCard] = []
        func add(_ month: Int, _ kind: CardKind, _ name: String, _ nameKey: String, _ symbol: String) {
            cards.append(HanafudaCard(id: id, month: month, kind: kind, name: name, nameKey: nameKey, symbol: symbol))
            id += 1
        }

        // 1 — Pine
        add(1, .bright, "Crane", "card.crane", "bird.fill")
        add(1, .ribbonPoetry, "Poetry Ribbon", "card.poetryRibbon", "scroll.fill")
        add(1, .plain, "Pine", "card.pine", "leaf.fill")
        add(1, .plain, "Pine", "card.pine", "leaf.fill")

        // 2 — Plum
        add(2, .animal, "Bush Warbler", "card.bushWarbler", "bird")
        add(2, .ribbonPoetry, "Poetry Ribbon", "card.poetryRibbon", "scroll.fill")
        add(2, .plain, "Plum Blossom", "card.plumBlossom", "leaf.fill")
        add(2, .plain, "Plum Blossom", "card.plumBlossom", "leaf.fill")

        // 3 — Cherry Blossom
        add(3, .bright, "Curtain", "card.curtain", "flag.fill")
        add(3, .ribbonPoetry, "Poetry Ribbon", "card.poetryRibbon", "scroll.fill")
        add(3, .plain, "Cherry Blossom", "card.cherryBlossom", "leaf.fill")
        add(3, .plain, "Cherry Blossom", "card.cherryBlossom", "leaf.fill")

        // 4 — Wisteria
        add(4, .animal, "Cuckoo", "card.cuckoo", "bird")
        add(4, .ribbonRed, "Ribbon", "card.ribbon", "ribbon")
        add(4, .plain, "Wisteria", "card.wisteria", "leaf.fill")
        add(4, .plain, "Wisteria", "card.wisteria", "leaf.fill")

        // 5 — Iris
        add(5, .animal, "Bridge", "card.bridge", "point.topleft.down.curvedto.point.bottomright.up")
        add(5, .ribbonRed, "Ribbon", "card.ribbon", "ribbon")
        add(5, .plain, "Iris", "card.iris", "leaf.fill")
        add(5, .plain, "Iris", "card.iris", "leaf.fill")

        // 6 — Peony
        add(6, .animal, "Butterflies", "card.butterflies", "ladybug.fill")
        add(6, .ribbonBlue, "Blue Ribbon", "card.blueRibbon", "ribbon")
        add(6, .plain, "Peony", "card.peony", "leaf.fill")
        add(6, .plain, "Peony", "card.peony", "leaf.fill")

        // 7 — Bush Clover
        add(7, .animal, "Boar", "card.boar", "hare.fill")
        add(7, .ribbonRed, "Ribbon", "card.ribbon", "ribbon")
        add(7, .plain, "Bush Clover", "card.bushClover", "leaf.fill")
        add(7, .plain, "Bush Clover", "card.bushClover", "leaf.fill")

        // 8 — Pampas Grass
        add(8, .bright, "Moon", "card.moon", "moon.stars.fill")
        add(8, .animal, "Geese", "card.geese", "bird")
        add(8, .plain, "Pampas Grass", "card.pampasGrass", "leaf.fill")
        add(8, .plain, "Pampas Grass", "card.pampasGrass", "leaf.fill")

        // 9 — Chrysanthemum
        add(9, .animal, "Sake Cup", "card.sakeCup", "cup.and.saucer.fill")
        add(9, .ribbonBlue, "Blue Ribbon", "card.blueRibbon", "ribbon")
        add(9, .plain, "Chrysanthemum", "card.chrysanthemum", "leaf.fill")
        add(9, .plain, "Chrysanthemum", "card.chrysanthemum", "leaf.fill")

        // 10 — Maple
        add(10, .animal, "Deer", "card.deer", "hare.fill")
        add(10, .ribbonBlue, "Blue Ribbon", "card.blueRibbon", "ribbon")
        add(10, .plain, "Maple", "card.maple", "leaf.fill")
        add(10, .plain, "Maple", "card.maple", "leaf.fill")

        // 11 — Willow
        add(11, .bright, "Rain Man", "card.rainMan", "umbrella.fill")
        add(11, .animal, "Swallow", "card.swallow", "bird")
        add(11, .ribbonPlain, "Ribbon", "card.ribbon", "ribbon")
        add(11, .plain, "Willow", "card.willow", "leaf.fill")

        // 12 — Paulownia
        add(12, .bright, "Phoenix", "card.phoenix", "sparkles")
        add(12, .plain, "Paulownia", "card.paulownia", "leaf.fill")
        add(12, .plain, "Paulownia", "card.paulownia", "leaf.fill")
        add(12, .plain, "Paulownia", "card.paulownia", "leaf.fill")

        return cards
    }()

    static func monthName(_ month: Int) -> String {
        ["Pine", "Plum", "Cherry Blossom", "Wisteria", "Iris", "Peony",
         "Bush Clover", "Pampas Grass", "Chrysanthemum", "Maple", "Willow", "Paulownia"][month - 1]
    }

    static func monthColor(_ month: Int) -> Color {
        switch month {
        case 1: return Color(red: 0.11, green: 0.35, blue: 0.24)   // pine green
        case 2: return Color(red: 0.72, green: 0.36, blue: 0.55)   // plum pink
        case 3: return Color(red: 0.92, green: 0.62, blue: 0.70)   // sakura pink
        case 4: return Color(red: 0.47, green: 0.35, blue: 0.68)   // wisteria purple
        case 5: return Color(red: 0.29, green: 0.52, blue: 0.71)   // iris blue
        case 6: return Color(red: 0.80, green: 0.27, blue: 0.46)   // peony magenta
        case 7: return Color(red: 0.42, green: 0.55, blue: 0.29)   // clover green
        case 8: return Color(red: 0.14, green: 0.16, blue: 0.34)   // night navy
        case 9: return Color(red: 0.85, green: 0.68, blue: 0.24)   // chrysanthemum gold
        case 10: return Color(red: 0.80, green: 0.42, blue: 0.16)  // maple orange
        case 11: return Color(red: 0.20, green: 0.42, blue: 0.44)  // stormy teal
        default: return Color(red: 0.42, green: 0.24, blue: 0.52)  // paulownia purple
        }
    }
}
