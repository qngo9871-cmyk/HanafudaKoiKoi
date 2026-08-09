import SwiftUI

/// Full scoring reference — every yaku a hand can complete, its point value, and how to
/// get it. Reachable from Home ("Yaku Guide") and from Onboarding's "Collect Yaku" page,
/// so the scoring system is genuinely explained in-app, not just implied by gameplay.
struct YakuGuideView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [Color(red: 0.06, green: 0.09, blue: 0.14), Color(red: 0.11, green: 0.16, blue: 0.22)],
                               startPoint: .top, endPoint: .bottom)
                    .ignoresSafeArea()

                ScrollView {
                    VStack(alignment: .leading, spacing: 18) {
                        Text(L("yakuguide.intro"))
                            .font(.system(size: 13))
                            .foregroundStyle(.white.opacity(0.65))
                            .padding(.bottom, 4)

                        ForEach(YakuScorer.referenceList, id: \.nameKey) { entry in
                            VStack(alignment: .leading, spacing: 4) {
                                HStack {
                                    Text(L(entry.nameKey))
                                        .font(.system(size: 16, weight: .bold, design: .rounded))
                                        .foregroundStyle(.white)
                                    Spacer()
                                    Text("\(entry.points) \(L("yakuguide.pts"))")
                                        .font(.system(size: 14, weight: .bold))
                                        .foregroundStyle(.yellow)
                                }
                                Text(L(entry.descKey))
                                    .font(.system(size: 13))
                                    .foregroundStyle(.white.opacity(0.7))
                            }
                            .padding(14)
                            .background(RoundedRectangle(cornerRadius: 12).fill(Color.white.opacity(0.06)))
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle(L("yakuguide.title"))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button(L("yakuguide.done")) { dismiss() }
                }
            }
        }
        .preferredColorScheme(.dark)
    }
}

#Preview { YakuGuideView() }
