import Foundation
import SwiftUI

enum AppLanguage: String, CaseIterable, Identifiable {
    case en, ja
    var id: String { rawValue }
    var displayName: String { self == .en ? "English" : "日本語" }
}

/// Manual bundle-swap localizer so the in-app language can change at runtime
/// without relaunching (system Locale-driven Text() only picks up the language
/// on next app launch, which isn't enough for an in-app switcher).
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()

    // NOTE: didSet must swap `bundle` too, not just persist the raw value — this is the
    // only observer that runs when the Home segmented Picker's `$language` binding sets
    // this property directly (which bypasses `setLanguage(_:)` below). Before this fix,
    // the picker toggled and persisted correctly but `string(_:)` kept resolving against
    // the stale bundle, so the UI never actually re-rendered in the new language until
    // the app was relaunched — found via a live mid-session XCUITest switch during the
    // 2026-08-12 polish pass (cold-launch-only HK_LANG verification never caught this).
    @Published var language: AppLanguage {
        didSet {
            UserDefaults.standard.set(language.rawValue, forKey: "app_language")
            bundle = Self.bundle(for: language)
        }
    }

    private var bundle: Bundle = .main

    init() {
        let stored = UserDefaults.standard.string(forKey: "app_language")
        let lang = AppLanguage(rawValue: stored ?? "") ?? Self.systemDefault()
        self.language = lang
        self.bundle = Self.bundle(for: lang)
    }

    private static func systemDefault() -> AppLanguage {
        let preferred = Locale.preferredLanguages.first ?? "en"
        return preferred.hasPrefix("ja") ? .ja : .en
    }

    private static func bundle(for lang: AppLanguage) -> Bundle {
        guard let path = Bundle.main.path(forResource: lang.rawValue, ofType: "lproj"),
              let b = Bundle(path: path) else { return .main }
        return b
    }

    func setLanguage(_ lang: AppLanguage) {
        language = lang
        bundle = Self.bundle(for: lang)
    }

    func string(_ key: String) -> String {
        bundle.localizedString(forKey: key, value: nil, table: nil)
    }
}

/// Shorthand: L("home.title") looks up the current in-app language, live.
func L(_ key: String) -> String {
    LocalizationManager.shared.string(key)
}
