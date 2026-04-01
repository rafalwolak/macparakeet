import Foundation

public struct TranslateHotkeyConfig: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public var trigger: HotkeyTrigger
    public var targetLanguage: String  // e.g., "en", "es", "fr"

    public init(id: UUID = UUID(), trigger: HotkeyTrigger, targetLanguage: String) {
        self.id = id
        self.trigger = trigger
        self.targetLanguage = targetLanguage
    }
}

public enum AppPreferences {
    public static let menuBarOnlyModeKey = "menuBarOnlyMode"
    public static let telemetryEnabledKey = "telemetryEnabled"
    public static let translationEnabledKey = "translationEnabled"
    public static let sourceLanguageKey = "sourceLanguage"
    public static let targetLanguageKey = "targetLanguage"
    public static let translateHotkeyConfigsKey = "translateHotkeyConfigs"

    public static func defaultTranslateHotkeyConfigs() -> [TranslateHotkeyConfig] {
        [
            TranslateHotkeyConfig(
                trigger: .chord(modifiers: ["control"], keyCode: 18),  // Ctrl+1
                targetLanguage: "en"
            ),
            TranslateHotkeyConfig(
                trigger: .chord(modifiers: ["control"], keyCode: 19),  // Ctrl+2
                targetLanguage: "es"
            ),
            TranslateHotkeyConfig(
                trigger: .chord(modifiers: ["control"], keyCode: 20),  // Ctrl+3
                targetLanguage: "fr"
            ),
        ]
    }

    public static func isMenuBarOnlyModeEnabled(defaults: UserDefaults = .standard) -> Bool {
        defaults.object(forKey: menuBarOnlyModeKey) as? Bool ?? false
    }

    public static func isTelemetryEnabled(defaults: UserDefaults = .standard) -> Bool {
        defaults.object(forKey: telemetryEnabledKey) as? Bool ?? true
    }
}
