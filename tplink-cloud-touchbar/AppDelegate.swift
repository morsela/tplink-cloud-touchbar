//
//  AppDelegate.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/5/19.
//  Copyright © 2019 Sela. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    private lazy var mainWindow: NSWindow = {
        let window = NSWindow(contentRect: CGRect.zero, styleMask: [.titled, .closable, .miniaturizable, .resizable, .fullSizeContentView], backing: .buffered, defer: false)
        window.isMovableByWindowBackground = true
        window.collectionBehavior = .fullScreenNone
        window.center()
        
        if #available(OSX 10.12, *) {
            window.tabbingMode = .disallowed
        }
        window.level = .normal
        window.alphaValue = 0
        
        return window
    }()

    private lazy var mainWindowController = WindowController(window: mainWindow)
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        if #available(OSX 10.12.2, *) {
            NSApplication.shared.isAutomaticCustomizeTouchBarMenuItemEnabled = true
        }
        
        mainWindowController.showWindow(nil)
    }
    
    func applicationWillBecomeActive(_ notification: Notification) {
        mainWindowController.applicationWillBecomeActive()
    }
}

