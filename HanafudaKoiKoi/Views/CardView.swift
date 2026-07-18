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
        case .bright: return "BRIGHT"
        case .animal: return "ANIMAL"
        case .ribbonPoetry: return "POETRY"
        case .ribbonBlue: return "RIBBON"
        case .ribbonRed, .ribbonPlain: return "RIBBON"
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
                    Text(card.name)
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

struct CardBackView: View {
    var body: some View {
        RoundedRectangle(cornerRadius: 9)
            .fill(LinearGradient(colors: [Color(red: 0.15, green: 0.18, blue: 0.28), Color(red: 0.08, green: 0.09, blue: 0.16)],
                                  startPoint: .top, endPoint: .bottom))
            .overlay(
                RoundedRectangle(cornerRadius: 9).stroke(Color.yellow.opacity(0.5), lineWidth: 1)
            )
            .overlay(
                Image(systemName: "leaf.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.yellow.opacity(0.6))
            )
    }
}
