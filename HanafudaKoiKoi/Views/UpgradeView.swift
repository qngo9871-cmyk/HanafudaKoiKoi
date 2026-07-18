import SwiftUI

struct UpgradeView: View {
    @StateObject private var purchases = PurchaseManager.shared
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color(red: 0.06, green: 0.09, blue: 0.14).ignoresSafeArea()
            VStack(spacing: 22) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 40))
                    .foregroundStyle(.yellow)
                Text("Koi-Koi Pro")
                    .font(.system(size: 26, weight: .heavy, design: .rounded))
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 10) {
                    featureRow("brain.head.profile", "Hard AI opponent")
                    featureRow("person.2.fill", "Local two-player mode")
                    featureRow("paintpalette.fill", "Alternate card back designs")
                    featureRow("infinity", "Unlimited matches, no ads ever")
                }
                .padding(.horizontal, 30)

                if purchases.isLoadingProduct {
                    ProgressView().tint(.white)
                } else if let product = purchases.product {
                    Button {
                        Task { await purchases.purchase() }
                    } label: {
                        Text(purchases.isPurchasing ? "Purchasing..." : "Unlock — \(product.displayPrice)")
                            .font(.system(size: 16, weight: .bold))
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(RoundedRectangle(cornerRadius: 14).fill(Color.yellow))
                    }
                    .disabled(purchases.isPurchasing)
                    .padding(.horizontal, 30)
                } else {
                    Text("Store unavailable right now.")
                        .foregroundStyle(.white.opacity(0.6))
                }

                if let error = purchases.purchaseError {
                    Text(error).font(.system(size: 12)).foregroundStyle(.red)
                }

                Button {
                    Task { await purchases.restorePurchases() }
                } label: {
                    Text("Restore Purchases")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundStyle(.white.opacity(0.7))
                }

                Button { dismiss() } label: {
                    Text("Not now").font(.system(size: 13)).foregroundStyle(.white.opacity(0.4))
                }
            }
            .padding(.top, 40)
        }
        .task { await purchases.loadProduct() }
        .onChange(of: purchases.isPro) { isPro in
            if isPro { dismiss() }
        }
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
