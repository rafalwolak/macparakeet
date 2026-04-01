import SwiftUI
import MacParakeetCore
import MacParakeetViewModels

struct TranslationSettingsView: View {
    @Bindable var viewModel: SettingsViewModel

    var body: some View {
        VStack(spacing: DesignSystem.Spacing.md) {
            settingsToggleRow(
                title: "Enable translation",
                detail: "Translate dictation and transcription output to your target language.",
                isOn: $viewModel.translationEnabled
            )

            if viewModel.translationEnabled {
                Divider()

                // Source language
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Source language")
                            .font(DesignSystem.Typography.body)
                        Text("Language of your dictation input.")
                            .font(DesignSystem.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: DesignSystem.Spacing.md)
                    sourceLanguagePicker
                }

                Divider()

                // Target language
                HStack(alignment: .top) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Target language")
                            .font(DesignSystem.Typography.body)
                        Text("Language to translate into.")
                            .font(DesignSystem.Typography.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer(minLength: DesignSystem.Spacing.md)
                    targetLanguagePicker
                }

                Divider()

                // Translate hotkeys
                Section {
                    ForEach(viewModel.translateHotkeyConfigs) { config in
                        HStack {
                            HotkeyRecorderView(trigger: Binding(
                                get: { config.trigger },
                                set: { newTrigger in
                                    viewModel.updateTranslateHotkeyConfig(id: config.id, trigger: newTrigger)
                                }
                            ))
                            Spacer(minLength: DesignSystem.Spacing.md)
                            Picker("Language", selection: Binding(
                                get: { config.targetLanguage },
                                set: { newLang in
                                    viewModel.updateTranslateHotkeyConfig(id: config.id, targetLanguage: newLang)
                                }
                            )) {
                                ForEach(Language.targetLanguages, id: \.rawValue) { lang in
                                    Text("\(lang.displayName) (\(lang.nativeName))").tag(lang.rawValue)
                                }
                            }
                            .frame(width: 140)
                            Button {
                                viewModel.removeTranslateHotkeyConfig(id: config.id)
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .foregroundColor(.red)
                            }
                        }
                    }

                    Button {
                        viewModel.addTranslateHotkeyConfig()
                    } label: {
                        Label("Add Translate Hotkey", systemImage: "plus.circle")
                    }
                } header: {
                    Text("Translate Hotkeys")
                } footer: {
                    Text("Configure hotkeys for quick translation. Each hotkey translates from your source language to the selected target.")
                }

                Divider()

                // Info text
                HStack(alignment: .top) {
                    Image(systemName: "info.circle")
                        .foregroundStyle(.secondary)
                    Text("Translation uses your configured LLM provider. For best results, use a multilingual model like Gemma 3 with Ollama.")
                        .font(DesignSystem.Typography.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private var sourceLanguagePicker: some View {
        Picker("Source", selection: $viewModel.sourceLanguage) {
            Text("Auto-detect").tag(Language.auto.rawValue)
            ForEach(Language.targetLanguages, id: \.self) { language in
                Text("\(language.displayName) (\(language.nativeName))").tag(language.rawValue)
            }
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .frame(width: 200)
    }

    private var targetLanguagePicker: some View {
        Picker("Target", selection: $viewModel.targetLanguage) {
            ForEach(Language.targetLanguages, id: \.self) { language in
                Text("\(language.displayName) (\(language.nativeName))").tag(language.rawValue)
            }
        }
        .labelsHidden()
        .pickerStyle(.menu)
        .frame(width: 200)
    }

    private func settingsToggleRow(
        title: String,
        detail: String,
        isOn: Binding<Bool>
    ) -> some View {
        HStack(alignment: .top, spacing: DesignSystem.Spacing.md) {
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(DesignSystem.Typography.body)
                Text(detail)
                    .font(DesignSystem.Typography.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer(minLength: DesignSystem.Spacing.md)
            Toggle("", isOn: isOn)
                .labelsHidden()
                .toggleStyle(.switch)
        }
    }
}
