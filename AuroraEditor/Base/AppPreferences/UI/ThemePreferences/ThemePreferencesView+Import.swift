//
//  ThemePreferencesView+Import.swift
//  AuroraEditor
//
//  Created by TAY KAI QUAN on 18/10/22.
//  Copyright © 2022 Aurora Company. All rights reserved.
//

import SwiftUI

extension ThemePreferencesView {

    // swiftlint:disable:next function_body_length
    func importTheme(type: AuroraTheme.ThemeFormat) {
        let dialog = NSOpenPanel()

        dialog.title = "Select the \(type)"
        dialog.showsResizeIndicator = true
        dialog.canChooseFiles = true
        dialog.canChooseDirectories = false
        dialog.allowsOtherFileTypes = false
        dialog.showsHiddenFiles = false

        switch type {
        case .vscode, .aeTheme, .oldAETheme:
            dialog.allowedContentTypes = [.json]
        case .textmate:
            dialog.allowedContentTypes = [.xml, .propertyList, .init(importedAs: ".tmTheme")]
        }

        dialog.begin { result in
            if result == NSApplication.ModalResponse.OK, let url = dialog.url {
                Log.info("Chosen to import \(url) as \(type.rawValue)")

                var theme: AuroraTheme?
                switch type {
                case .aeTheme:
                    // TODO: Load AuroraTheme from JSON
                    break
                case .vscode:
                    theme = ThemeJsonLoader.shared.loadVscJson(from: url)
                case .textmate:
                    theme = ThemeJsonLoader.shared.loadTmThemeXml(from: url)
                case .oldAETheme:
                    theme = ThemeJsonLoader.shared.loadOldAEThemeJson(from: url)
                }

                guard theme != nil else {
                    let errorAlert = NSAlert()
                    errorAlert.messageText = "Error decoding theme"
                    errorAlert.alertStyle = .warning
                    errorAlert.runModal()
                    return
                }

                let importConfirmation = NSAlert()
                importConfirmation.messageText = "Would you like to save this theme in AuroraTheme format?"
                importConfirmation.informativeText =
"""
If you chose not to, you will not be able to edit this theme from within AuroraEditor.
"""
                importConfirmation.alertStyle = .informational
                importConfirmation.addButton(withTitle: "Save as AuroraTheme")
                importConfirmation.addButton(withTitle: "Save as \(type.rawValue)")
                let result = importConfirmation.runModal()
                if result == .alertSecondButtonReturn {
                    // save as given type
                    var finishedCopying = false
                    do {
                        try ThemeModel.shared.copyTheme(at: url, named: url.lastPathComponent)
                        finishedCopying = true
                        try ThemeModel.shared.loadThemes()
                    } catch {
                        let errorAlert = NSAlert()
                        if finishedCopying {
                            errorAlert.messageText = "Theme file with identical name already exists."
                        } else {
                            errorAlert.messageText = "Error loading themes"
                        }
                        errorAlert.alertStyle = .warning
                        errorAlert.runModal()
                        return
                    }
                } else {
                    // TODO: save as AETheme
                }
            }
        }
    }
}
