import Foundation

public enum Language: String, CaseIterable, Codable, Sendable {
    case auto = "auto"
    case english = "en"
    case polish = "pl"
    case spanish = "es"
    case german = "de"
    case french = "fr"
    case italian = "it"
    case portuguese = "pt"
    case dutch = "nl"
    case japanese = "ja"
    case korean = "ko"
    case chineseSimplified = "zh"
    case arabic = "ar"
    case russian = "ru"
    case hindi = "hi"

    public var displayName: String {
        switch self {
        case .auto: return "Auto-detect"
        case .english: return "English"
        case .polish: return "Polish"
        case .spanish: return "Spanish"
        case .german: return "German"
        case .french: return "French"
        case .italian: return "Italian"
        case .portuguese: return "Portuguese"
        case .dutch: return "Dutch"
        case .japanese: return "Japanese"
        case .korean: return "Korean"
        case .chineseSimplified: return "Chinese (Simplified)"
        case .arabic: return "Arabic"
        case .russian: return "Russian"
        case .hindi: return "Hindi"
        }
    }

    public var nativeName: String {
        switch self {
        case .auto: return "Auto-detect"
        case .english: return "English"
        case .polish: return "Polski"
        case .spanish: return "Español"
        case .german: return "Deutsch"
        case .french: return "Français"
        case .italian: return "Italiano"
        case .portuguese: return "Português"
        case .dutch: return "Nederlands"
        case .japanese: return "日本語"
        case .korean: return "한국어"
        case .chineseSimplified: return "简体中文"
        case .arabic: return "العربية"
        case .russian: return "Русский"
        case .hindi: return "हिन्दी"
        }
    }

    public static var targetLanguages: [Language] {
        allCases.filter { $0 != .auto }
    }
}
