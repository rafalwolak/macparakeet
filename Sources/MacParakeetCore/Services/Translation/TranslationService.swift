import Foundation

public final class TranslationService: TranslationServiceProtocol, Sendable {
    private let client: LLMClientProtocol
    private let configStore: LLMConfigStoreProtocol

    // Maximum text length for translation
    private static let maxTextLength = 10_000

    public init(
        client: LLMClientProtocol = LLMClient(),
        configStore: LLMConfigStoreProtocol = LLMConfigStore()
    ) {
        self.client = client
        self.configStore = configStore
    }

    // MARK: - Sync Variant

    public func translate(text: String, from source: Language, to target: Language) async throws -> String {
        guard text.count <= Self.maxTextLength else {
            throw TranslationError.textTooLong(maxChars: Self.maxTextLength)
        }

        let config = try loadConfig()
        let messages = buildTranslationMessages(text: text, from: source, to: target)

        do {
            let response = try await client.chatCompletion(messages: messages, config: config, options: .default)
            Telemetry.send(.translationUsed(
                provider: config.id.rawValue,
                sourceLang: source.rawValue,
                targetLang: target.rawValue,
                charCount: text.count
            ))
            return response.content
        } catch {
            if !(error is CancellationError) {
                let provider = (try? configStore.loadConfig())?.id.rawValue ?? "unknown"
                Telemetry.send(.translationFailed(
                    provider: provider,
                    errorType: Self.errorType(for: error)
                ))
            }
            throw Self.mapError(error)
        }
    }

    public func detectLanguage(text: String) async throws -> Language {
        let config = try loadConfig()
        let messages = [
            ChatMessage(role: .system, content: Prompts.languageDetection),
            ChatMessage(role: .user, content: text),
        ]

        do {
            let response = try await client.chatCompletion(messages: messages, config: config, options: .default)
            let detected = response.content.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
            return Language.allCases.first { $0.rawValue == detected || $0.displayName.lowercased() == detected } ?? .english
        } catch {
            throw Self.mapError(error)
        }
    }

    // MARK: - Streaming Variant

    public func translateStream(text: String, from source: Language, to target: Language) -> AsyncThrowingStream<String, Error> {
        AsyncThrowingStream { continuation in
            let task = Task {
                do {
                    guard text.count <= Self.maxTextLength else {
                        throw TranslationError.textTooLong(maxChars: Self.maxTextLength)
                    }

                    let config = try self.loadConfig()
                    let messages = self.buildTranslationMessages(text: text, from: source, to: target)
                    let stream = self.client.chatCompletionStream(messages: messages, config: config, options: .default)

                    for try await token in stream {
                        continuation.yield(token)
                    }

                    Telemetry.send(.translationUsed(
                        provider: config.id.rawValue,
                        sourceLang: source.rawValue,
                        targetLang: target.rawValue,
                        charCount: text.count
                    ))
                    continuation.finish()
                } catch {
                    if !(error is CancellationError) {
                        let provider = (try? self.configStore.loadConfig())?.id.rawValue ?? "unknown"
                        Telemetry.send(.translationFailed(
                            provider: provider,
                            errorType: Self.errorType(for: error)
                        ))
                    }
                    continuation.finish(throwing: Self.mapError(error))
                }
            }
            continuation.onTermination = { _ in task.cancel() }
        }
    }

    // MARK: - Private Helpers

    private func loadConfig() throws -> LLMProviderConfig {
        guard let config = try configStore.loadConfig() else {
            throw TranslationError.notConfigured
        }
        return config
    }

    private func buildTranslationMessages(text: String, from source: Language, to target: Language) -> [ChatMessage] {
        let systemPrompt = Prompts.translation(source: source, target: target)
        return [
            ChatMessage(role: .system, content: systemPrompt),
            ChatMessage(role: .user, content: text),
        ]
    }

    private static func errorType(for error: Error) -> String {
        TelemetryErrorClassifier.classify(error)
    }

    private static func mapError(_ error: Error) -> TranslationError {
        if let translationError = error as? TranslationError {
            return translationError
        }
        if let llmError = error as? LLMError {
            switch llmError {
            case .notConfigured:
                return .notConfigured
            case .connectionFailed, .providerError:
                return .providerUnavailable
            default:
                return .translationFailed(llmError.localizedDescription)
            }
        }
        return .translationFailed(error.localizedDescription)
    }

    // MARK: - Prompt Templates

    private enum Prompts {
        static func translation(source: Language, target: Language) -> String {
            let sourceName = source == .auto ? "auto-detected language" : source.nativeName
            return """
                You are a professional translator. Translate the following text from \(sourceName) to \(target.nativeName). \
                Return ONLY the translated text, no explanations, quotes, or formatting. \
                Preserve the tone and style of the original text.
                """
        }

        static let languageDetection = """
            Detect the language of the following text. Respond with only the ISO 639-1 language code \
            (e.g., "en", "pl", "es", "de"). If uncertain, respond with "en".
            """
    }
}
