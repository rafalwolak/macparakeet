import Foundation

public protocol TranslationServiceProtocol: Sendable {
    func translate(text: String, from source: Language, to target: Language) async throws -> String
    func translateStream(text: String, from source: Language, to target: Language) -> AsyncThrowingStream<String, Error>
    func detectLanguage(text: String) async throws -> Language
}
