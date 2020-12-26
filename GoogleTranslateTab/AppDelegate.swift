//
//  AppDelegate.swift
//  GoogleTranslateTab
//
//  Created by Toby on 2020-08-02.
//  Copyright © 2020 Toby. All rights reserved.
//

import Cocoa
import SwiftUI

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var popover: NSPopover!
    var statusBarItem: NSStatusItem!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        
        let contentView = ContentView(translateManager: translateManagerSetup())
        
        popover = NSPopover()
        popover.contentSize = NSSize(width: 600, height: 500)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        
        statusBarItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
        
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: "Icon")
            button.imageScaling = .scaleProportionallyDown
            button.action = #selector(togglePopover)
        }
    }
    
    // Create the status item
    @objc func togglePopover(_ sender: AnyObject?) {
         if let button = statusBarItem.button {
              if popover.isShown {
                   popover.performClose(sender)
              } else {
                   popover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
              }
         }
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }

}

func translateManagerSetup() -> GoogleTranslate{
    guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GoogleApiKey") as? String else {
        fatalError("Cannot find GoogleApiKey in Info.plist")
    }
    let translate = GoogleTranslate(apiKey: apiKey, userLanguage: Locale.preferredLanguages[0])
    translate.supportedLanguages[.base] = ["en": "Engligh", "zh": "Chinese"]
    return translate
}
