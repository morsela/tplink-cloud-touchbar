/*
 Copyright (C) 2018 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 The primary window controller for this sample.
 */

import Cocoa

class WindowController: NSWindowController {
    private lazy var devicesViewController = DevicesViewController()
    
    // MARK: - Window Controller Life Cycle
    
    override init(window: NSWindow?) {
        super.init(window: window)
        
        self.window?.contentViewController = devicesViewController
        self.touchBar = devicesViewController.makeTouchBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func applicationWillBecomeActive() {
        devicesViewController.applicationWillBecomeActive()
    }
}
