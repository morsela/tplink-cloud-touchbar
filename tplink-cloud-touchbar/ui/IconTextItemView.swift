//
//  IconTextItemView.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/12/19.
//  Copyright © 2019 Sela. All rights reserved.
//

import Cocoa

@available(OSX 10.12.2, *)
class IconTextItemView: NSScrubberItemView {
    
    let imageView = NSImageView()
    
    let textField = NSTextField()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false

        textField.font = NSFont.systemFont(ofSize: 0)
        textField.textColor = NSColor.white
        
        addSubview(imageView)
        addSubview(textField)
        
        updateLayout()
    }
    
    convenience init(icon: NSImage?, text: String) {
        self.init(frame: NSRect(x: 0, y: 0, width: 50, height: 30))
        
        imageView.image = icon
        textField.stringValue = text
    }
    
    private func updateLayout() {
        imageView.translatesAutoresizingMaskIntoConstraints = false
        textField.translatesAutoresizingMaskIntoConstraints = false
        
        let viewBindings: [String: NSView] = ["imageView": imageView, "textField": textField]
        var formatString = "H:|-2-[imageView]-2-[textField]-2-|"
        let hconstraints = NSLayoutConstraint.constraints(withVisualFormat: formatString,
                                                          options: [],
                                                          metrics: nil,
                                                          views: viewBindings)
        formatString = "V:|-0-[imageView]-0-|"
        let vconstraints = NSLayoutConstraint.constraints(withVisualFormat: formatString,
                                                          options: [],
                                                          metrics: nil,
                                                          views: viewBindings)
        
        let alignConstraint = NSLayoutConstraint(item: imageView, attribute: .centerY,
                                                 relatedBy: .equal,
                                                 toItem: textField, attribute: .centerY,
                                                 multiplier: 1, constant: 0)
        NSLayoutConstraint.activate(hconstraints + vconstraints + [alignConstraint])
    }
}
