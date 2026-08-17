import SwiftUI

struct UpgradeView: View {
    @StateObject private var purchases = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss
    @AppStorage("cardBackStyle") private var cardBackStyleRaw = CardBackStyle.ink.rawValue

    private var cardBackStyle: Binding<CardBackStyle> {
        Binding(
            get: { CardBackStyle(rawValue: cardBackStyleRaw) ?? .ink },
            set: { cardBackStyleRaw = $0.rawValue }
        )
    }

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.09, blue: 0.14).ignoresSafeArea()
            ScrollView {
                VStack(spacing: 22) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 40))
                        .foregroundStyle(.yellow)
                    Text(L("upgrade.title"))
                        .font(.system(size: 26, weight: .heavy, design: .rounded))
                        .foregroundStyle(.white)

                    Text(L(purchases.isPro || purchases.trialActive ? "upgrade.subtitle" : "upgrade.subtitle.trialended"))
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.65))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)

                    VStack(alignment: .leading, spacing: 10) {
                        featureRow("brain.head.profile", L("upgrade.featureHardAI"))
                        featureRow("person.2.fill", L("upgrade.featureTwoPlayer"))
                        featureRow("paintpalette.fill", L("upgrade.featureCardBacks"))
                        featureRow("infinity", L("upgrade.featureNoAds"))
                    }
                    .padding(.horizontal, 30)

                    if purchases.isPro {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(L("upgrade.cardBackPicker"))
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundStyle(.white.opacity(0.7))
                            HStack(spacing: 16) {
                                ForEach(CardBackStyle.allCases) { style in
                                    Button { cardBackStyle.wrappedValue = style } label: {
                                        VStack(spacing: 6) {
                                            CardBackView(style: style)
                                                .frame(width: 54, height: 76)
                                                .overlay(
                                                    RoundedRectangle(cornerRadius: 9)
                                                        .stroke(Color.white, lineWidth: cardBackStyleRaw == style.rawValue ? 2 : 0)
                                                )
                                            Text(L(style.titleKey))
                                                .font(.system(size: 11, weight: .medium))
                                                .foregroundStyle(.white.opacity(0.8))
                                        }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                        }
                        .padding(.horizontal, 30)
                    }

                    if purchases.isPro {
                        // Nothing to buy or load — the picker above is the whole point of
                        // being here. Don't show a spinner for a purchase flow that's moot.
                        EmptyView()
                    } else if purchases.isLoadingProduct {
                        ProgressView().tint(.white)
                    } else if let product = purchases.product, !purchases.isPro {
                        Button {
                            Task { await purchases.purchase() }
                        } label: {
                            Text(purchases.isPurchasing ? L("upgrade.purchasing") : String(format: L("upgrade.unlock"), product.displayPrice))
                                .font(.system(size: 16, weight: .bold))
                                .foregroundStyle(.black)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(RoundedRectangle(cornerRadius: 14).fill(Color.yellow))
                        }
                        .disabled(purchases.isPurchasing)
                        .padding(.horizontal, 30)
                    } else if !purchases.isPro {
                        Text(L("upgrade.storeUnavailable"))
                            .foregroundStyle(.white.opacity(0.6))
                    }

                    if let error = purchases.purchaseError {
                        Text(error).font(.system(size: 12)).foregroundStyle(.red)
                    }

                    if !purchases.isPro {
                        Button {
                            Task { await purchases.restorePurchases() }
                        } label: {
                            Text(L("upgrade.restorePurchases"))
                                .font(.system(size: 13, weight: .medium))
                                .foregroundStyle(.white.opacity(0.7))
                        }
                    }

                    Button { dismiss() } label: {
                        Text(purchases.isPro ? L("upgrade.done") : L("upgrade.notNow"))
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.4))
                    }
                }
                .padding(.top, 40)
                .padding(.bottom, 24)
            }
        }
        .task { await purchases.loadProduct() }
        // Deliberately does NOT auto-dismiss on purchase (unlike the old version) — a
        // first-time purchaser lands right on the card-back picker instead of being
        // bounced back to Home before they can use their new Pro perks.
    }

    private func featureRow(_ symbol: String, _ text: String) -> some View {
        HStack(spacing: 12) {
            Image(systemName: symbol).foregroundStyle(.yellow).frame(width: 22)
            Text(text).foregroundStyle(.white)
            Spacer()
        }
        .font(.system(size: 14, weight: .medium))
    }
}

#Preview { UpgradeView() }
