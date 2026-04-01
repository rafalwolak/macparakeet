import Foundation

public enum TranslationError: LocalizedError, Sendable {
    case notConfigured
    case providerUnavailable
    case translationFailed(String)
    case unsupportedLanguagePair(source: Language, target: Language)
    case textTooLong(maxChars: Int)

    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "No LLM provider configured. Set up a provider in Settings to enable translation."
        case .providerUnavailable:
            return "Translation provider is unavailable. Please check your connection."
        case .translationFailed(let detail):
            return "Translation failed: \(detail)"
        case .unsupportedLanguagePair(let source, let target):
            return "Unsupported language pair: \(source.displayName) to \(target.displayName)"
        case .textTooLong(let maxChars):
            return "Text exceeds maximum length of \(maxChars) characters."
        }
    }
}
