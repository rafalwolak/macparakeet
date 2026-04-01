import Foundation

public enum AppPreferences {
    public static let menuBarOnlyModeKey = "menuBarOnlyMode"
    public static let telemetryEnabledKey = "telemetryEnabled"
    public static let translationEnabledKey = "translationEnabled"
    public static let sourceLanguageKey = "sourceLanguage"
    public static let targetLanguageKey = "targetLanguage"
    public static let translateHotkeyTriggerKey = "translateHotkeyTrigger"

    public static func isMenuBarOnlyModeEnabled(defaults: UserDefaults = .standard) -> Bool {
        defaults.object(forKey: menuBarOnlyModeKey) as? Bool ?? false
    }

    public static func isTelemetryEnabled(defaults: UserDefaults = .standard) -> Bool {
        defaults.object(forKey: telemetryEnabledKey) as? Bool ?? true
    }
}
