//
//  GeneralURLHandlerApp.swift
//  GeneralURLHandler
//
//  Created by Joachim Bargsten on 04/01/2023.
//

import SwiftUI
import OSLog

extension Logger {
    static let logger = Logger(subsystem: "GeneralURLHandler", category: "general")
}

class AppDelegate: NSObject, NSApplicationDelegate {
  func application(_: NSApplication, open urls: [URL]) {
      Logger.logger.info("bob")
    guard let conf = try? loadConfig(path: getConfigFilePath()) else { return }

    guard let url = NSWorkspace.shared.urlForApplication(withBundleIdentifier: "org.alacritty")
    else { return }
    let configuration = NSWorkspace.OpenConfiguration()
    configuration.createsNewApplicationInstance = true
    print(urls)
    guard let (kasten, zid) = urls.first.flatMap({ extractZettelLocation(url: $0) }) else { return }

    guard let zhome = conf.kasten[kasten] else { return }

    let zettelAbs = "\(zhome)/docs/\(zid).md"

    configuration.arguments = ["-e", conf.nvim, zettelAbs]
    NSWorkspace.shared.openApplication(at: url, configuration: configuration, completionHandler: nil)
  }
}
