import SwiftUI

/// Original vector card face — no licensed hanafuda artwork, just month colour + icon + label.
struct CardView: View {
    let card: HanafudaCard
    var isSelectable: Bool = false
    var isHighlighted: Bool = false

    private var accentColor: Color {
        switch card.kind {
        case .bright: return Color(red: 1.0, green: 0.85, blue: 0.35)
        case .animal: return .white
        case .ribbonPoetry, .ribbonRed, .ribbonPlain: return Color(red: 1.0, green: 0.45, blue: 0.42)
        case .ribbonBlue: return Color(red: 0.45, green: 0.70, blue: 1.0)
        case .plain: return .white.opacity(0.85)
        }
    }

    private var kindLabel: String {
        switch card.kind {
        case .bright: return L("cardkind.bright")
        case .animal: return L("cardkind.animal")
        case .ribbonPoetry: return L("cardkind.poetry")
        case .ribbonBlue: return L("cardkind.ribbon")
        case .ribbonRed, .ribbonPlain: return L("cardkind.ribbon")
        case .plain: return ""
        }
    }

    var body: some View {
        RoundedRectangle(cornerRadius: 9)
            .fill(
                LinearGradient(colors: [HanafudaDeck.monthColor(card.month), HanafudaDeck.monthColor(card.month).opacity(0.72)],
                               startPoint: .top, endPoint: .bottom)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 9)
                    .stroke(isHighlighted ? Color.yellow : Color.white.opacity(0.35), lineWidth: isHighlighted ? 3 : 1)
            )
            .overlay(alignment: .topLeading) {
                Text("\(card.month)")
                    .font(.system(size: 11, weight: .bold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.85))
                    .padding(.horizontal, 5).padding(.top, 4)
            }
            .overlay {
                VStack(spacing: 3) {
                    Image(systemName: card.symbol)
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundStyle(accentColor)
                        .shadow(color: .black.opacity(0.35), radius: 1, y: 1)
                    Text(card.localizedName)
                        .font(.system(size: 8.5, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                        .padding(.horizontal, 3)
                    if !kindLabel.isEmpty {
                        Text(kindLabel)
                            .font(.system(size: 6.5, weight: .bold))
                            .tracking(0.5)
                            .foregroundStyle(accentColor)
                    }
                }
            }
            .shadow(color: .black.opacity(0.3), radius: isSelectable ? 4 : 2, y: 2)
    }
}

/// Pro-only alternate card-back designs (see `UpgradeView`/`PurchaseManager.isPro`).
enum CardBackStyle: String, CaseIterable, Identifiable {
    case ink, sakura

    var id: String { rawValue }

    var titleKey: String {
        switch self {
        case .ink: return "cardback.ink"
        case .sakura: return "cardback.sakura"
        }
    }

    fileprivate var colors: [Color] {
        switch self {
        case .ink: return [Color(red: 0.15, green: 0.18, blue: 0.28), Color(red: 0.08, green: 0.09, blue: 0.16)]
        case .sakura: return [Color(red: 0.42, green: 0.14, blue: 0.24), Color(red: 0.20, green: 0.06, blue: 0.14)]
        }
    }

    fileprivate var accent: Color {
        switch self {
        case .ink: return .yellow
        case .sakura: return Color(red: 1.0, green: 0.68, blue: 0.78)
        }
    }

    fileprivate var symbol: String {
        switch self {
        case .ink: return "leaf.fill"
        case .sakura: return "sparkle"
        }
    }
}

struct CardBackView: View {
    var style: CardBackStyle = .ink

    var body: some View {
        RoundedRectangle(cornerRadius: 9)
            .fill(LinearGradient(colors: style.colors, startPoint: .top, endPoint: .bottom))
            .overlay(
                RoundedRectangle(cornerRadius: 9).stroke(style.accent.opacity(0.5), lineWidth: 1)
            )
            .overlay(
                Image(systemName: style.symbol)
                    .font(.system(size: 16))
                    .foregroundStyle(style.accent.opacity(0.6))
            )
    }
}
