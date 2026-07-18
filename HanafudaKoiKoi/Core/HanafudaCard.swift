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
    let name: String
    let symbol: String      // SF Symbol used on the card face

    static func == (lhs: HanafudaCard, rhs: HanafudaCard) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

enum HanafudaDeck {

    /// The canonical 48-card Koi-Koi deck, in the standard month order.
    static let fullDeck: [HanafudaCard] = {
        var id = 0
        var cards: [HanafudaCard] = []
        func add(_ month: Int, _ kind: CardKind, _ name: String, _ symbol: String) {
            cards.append(HanafudaCard(id: id, month: month, kind: kind, name: name, symbol: symbol))
            id += 1
        }

        // 1 — Pine
        add(1, .bright, "Crane", "bird.fill")
        add(1, .ribbonPoetry, "Poetry Ribbon", "scroll.fill")
        add(1, .plain, "Pine", "leaf.fill")
        add(1, .plain, "Pine", "leaf.fill")

        // 2 — Plum
        add(2, .animal, "Bush Warbler", "bird")
        add(2, .ribbonPoetry, "Poetry Ribbon", "scroll.fill")
        add(2, .plain, "Plum Blossom", "leaf.fill")
        add(2, .plain, "Plum Blossom", "leaf.fill")

        // 3 — Cherry Blossom
        add(3, .bright, "Curtain", "flag.fill")
        add(3, .ribbonPoetry, "Poetry Ribbon", "scroll.fill")
        add(3, .plain, "Cherry Blossom", "leaf.fill")
        add(3, .plain, "Cherry Blossom", "leaf.fill")

        // 4 — Wisteria
        add(4, .animal, "Cuckoo", "bird")
        add(4, .ribbonRed, "Ribbon", "ribbon")
        add(4, .plain, "Wisteria", "leaf.fill")
        add(4, .plain, "Wisteria", "leaf.fill")

        // 5 — Iris
        add(5, .animal, "Bridge", "point.topleft.down.curvedto.point.bottomright.up")
        add(5, .ribbonRed, "Ribbon", "ribbon")
        add(5, .plain, "Iris", "leaf.fill")
        add(5, .plain, "Iris", "leaf.fill")

        // 6 — Peony
        add(6, .animal, "Butterflies", "ladybug.fill")
        add(6, .ribbonBlue, "Blue Ribbon", "ribbon")
        add(6, .plain, "Peony", "leaf.fill")
        add(6, .plain, "Peony", "leaf.fill")

        // 7 — Bush Clover
        add(7, .animal, "Boar", "hare.fill")
        add(7, .ribbonRed, "Ribbon", "ribbon")
        add(7, .plain, "Bush Clover", "leaf.fill")
        add(7, .plain, "Bush Clover", "leaf.fill")

        // 8 — Pampas Grass
        add(8, .bright, "Moon", "moon.stars.fill")
        add(8, .animal, "Geese", "bird")
        add(8, .plain, "Pampas Grass", "leaf.fill")
        add(8, .plain, "Pampas Grass", "leaf.fill")

        // 9 — Chrysanthemum
        add(9, .animal, "Sake Cup", "cup.and.saucer.fill")
        add(9, .ribbonBlue, "Blue Ribbon", "ribbon")
        add(9, .plain, "Chrysanthemum", "leaf.fill")
        add(9, .plain, "Chrysanthemum", "leaf.fill")

        // 10 — Maple
        add(10, .animal, "Deer", "hare.fill")
        add(10, .ribbonBlue, "Blue Ribbon", "ribbon")
        add(10, .plain, "Maple", "leaf.fill")
        add(10, .plain, "Maple", "leaf.fill")

        // 11 — Willow
        add(11, .bright, "Rain Man", "umbrella.fill")
        add(11, .animal, "Swallow", "bird")
        add(11, .ribbonPlain, "Ribbon", "ribbon")
        add(11, .plain, "Willow", "leaf.fill")

        // 12 — Paulownia
        add(12, .bright, "Phoenix", "sparkles")
        add(12, .plain, "Paulownia", "leaf.fill")
        add(12, .plain, "Paulownia", "leaf.fill")
        add(12, .plain, "Paulownia", "leaf.fill")

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
