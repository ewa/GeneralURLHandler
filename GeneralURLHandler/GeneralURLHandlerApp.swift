//
//  GeneralURLHandlerApp.swift
//  GeneralURLHandler
//
//  Created by Joachim Bargsten on 04/01/2023.
//

import SwiftUI
import Foundation
import OSLog

extension Logger {
    static let main = Logger(subsystem: "GeneralURLHandler", category: "main")
}

class AppDelegate: NSObject, NSApplicationDelegate {

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Set preference if needed.
        let defaults = UserDefaults.standard
        if defaults.string(forKey: "cmd") == nil {
            defaults.set("/opt/homebrew/bin/emacsclient", forKey: "cmd")
        }
    }
    
    func application(_: NSApplication, open urls: [URL]) {
        
        Logger.main.info("Starting: \(urls, privacy:.public)")
        if (urls.count != 1) {
            Logger.main.error("List too long or too short")
            return
        }
        let cmd:String = UserDefaults.standard.string(forKey: "cmd")!
        Logger.main.info("command preference: \(cmd,  privacy:.public)")
        
        let ec_url = NSURL(fileURLWithPath: cmd)
        
        let configuration = NSWorkspace.OpenConfiguration()
        configuration.createsNewApplicationInstance = false
        configuration.promptsUserIfNeeded = true
        configuration.activates = false
        configuration.hides = true
        configuration.arguments = [cmd, urls[0].absoluteString]
        Logger.main.info("Command url: \(ec_url as URL, privacy:.public), command arguments: \(configuration.arguments,  privacy:.public)")
        
        //NSWorkspace.shared.openApplication(at: ec_url as URL, configuration: configuration, completionHandler: nil)
        let client:Process = Process()
        client.executableURL = ec_url as URL
        client.arguments = [urls[0].absoluteString]
        let outPipe = Pipe()
        let errPipe = Pipe()
               
        client.standardOutput=outPipe
        client.standardError=errPipe
        client.terminationHandler = { (process) in
            Logger.main.debug("\nFinished. running: \(process.isRunning, privacy:.public), status: \(process.terminationStatus, privacy:.public)")
        }
        do {
            try client.run()
        } catch {
            Logger.main.error("Well, shit")
            return
        }
    }
}
