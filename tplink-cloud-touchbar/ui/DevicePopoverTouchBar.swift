//
//  DevicePopoverTouchBar.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/7/19.
//  Copyright © 2019 Sela. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
fileprivate extension NSTouchBarItem.Identifier {
    static let toggleButton = NSTouchBarItem.Identifier("com.TouchBarCatalog.TouchBarItem.button")
    static let deviceAlias = NSTouchBarItem.Identifier("com.TouchBarCatalog.TouchBarItem.deviceAlias")
    static let slider = NSTouchBarItem.Identifier("com.TouchBarCatalog.TouchBarItem.slider")
}

// MARK: -

protocol DevicePopoverTouchBarDelegate: AnyObject {
    func actionHandler(device: TPLinkDevice)
    func sliderValueChanged(device: inout BulbDevice, sliderValue: Int)
}

@available(OSX 10.12.2, *)
class DevicePopoverTouchBar: NSTouchBar {
    
    var presentingItem: NSPopoverTouchBarItem?
    
    var device: TPLinkDevice? {
        didSet {
            defaultItemIdentifiers = [.deviceAlias, .toggleButton]
            
            guard let device = device else { return }
            
            if let deviceAliasItem = item(forIdentifier: NSTouchBarItem.Identifier.deviceAlias),
                let deviceAliasTextField = deviceAliasItem.view as? NSTextField {
                deviceAliasTextField.stringValue = device.info.alias
            }
            
            if let toggleButtonItem = item(forIdentifier: NSTouchBarItem.Identifier.toggleButton),
                let button = toggleButtonItem.view as? NSButton {
                let title = device.state.isOn() ? "Power Off" : "Power On"
                button.attributedTitle = NSAttributedString(string: title, attributes: [ NSAttributedString.Key.foregroundColor : NSColor.white ])
            }
            
            guard let bulbDevice = device as? BulbDevice else { return }
            
            if bulbDevice.supportsBrightnessAdjustment {
                defaultItemIdentifiers = [.deviceAlias, .toggleButton, .slider]
            }
            
            if let sliderItem = item(forIdentifier: NSTouchBarItem.Identifier.slider) as? NSSliderTouchBarItem {
                sliderItem.slider.intValue = bulbDevice.brightness
            }
        }
    }

    weak var actionDelegate: DevicePopoverTouchBarDelegate?
    
    override init() {
        super.init()
        
        delegate = self
        defaultItemIdentifiers = [.deviceAlias, .toggleButton, .slider]
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    convenience init(presentingItem: NSPopoverTouchBarItem? = nil) {
        self.init()

        self.presentingItem = presentingItem
    }
    
    @objc func actionHandler(_ sender: Any?) {
        guard let device = device else { return }
        actionDelegate?.actionHandler(device: device)
    }
    
    @objc func sliderValueChanged(_ sender: Any) {
        if let sliderItem = sender as? NSSliderTouchBarItem {
            guard var bulbDevice = device as? BulbDevice else { return }
            
            actionDelegate?.sliderValueChanged(device: &bulbDevice, sliderValue: Int(sliderItem.slider.intValue))
        }
    }
}

// MARK: - NSTouchBarDelegate

@available(OSX 10.12.2, *)
extension DevicePopoverTouchBar: NSTouchBarDelegate {
    
    // This gets called while the NSTouchBar is being constructed, for each NSTouchBarItem to be created.
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        switch identifier {
        case NSTouchBarItem.Identifier.toggleButton:
            let custom = NSCustomTouchBarItem(identifier: identifier)
            custom.customizationLabel = NSLocalizedString("Toggle", comment:"")
            
            let button = NSButton(title: NSLocalizedString("Toggle", comment:""), target: self, action: #selector(actionHandler(_:)))
                
            custom.view = button
            return custom
            
        case NSTouchBarItem.Identifier.slider:
            let sliderItem = NSSliderTouchBarItem(identifier: identifier)
            let slider = sliderItem.slider
            slider.minValue = 0.0
            slider.maxValue = 100.0
            sliderItem.label = NSLocalizedString("Brightness", comment: "")
            
            sliderItem.customizationLabel = NSLocalizedString("Slider", comment:"")
            sliderItem.target = self
            sliderItem.action = #selector(sliderValueChanged(_:))
            
            let viewBindings: [String: NSView] = ["slider": slider]
            let constraints = NSLayoutConstraint.constraints(withVisualFormat: "[slider(300)]",
                                                             options: [],
                                                             metrics: nil,
                                                             views: viewBindings)
            NSLayoutConstraint.activate(constraints)
            return sliderItem
            
        case NSTouchBarItem.Identifier.deviceAlias:
            let custom = NSCustomTouchBarItem(identifier: identifier)
            
            let label = NSTextField(labelWithString:
                NSLocalizedString("", comment: ""))
            custom.view = label
            
            return custom
            
        default:
            return nil
        }
    }
}


