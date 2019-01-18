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
    
    let imageView: NSImageView = {
        let imageView = NSImageView()
        return imageView
    }()
    
    let textField: NSTextField = {
        let textField = NSTextField()
        textField.font = NSFont.systemFont(ofSize: 0)
        textField.textColor = NSColor.white
        
        return textField
    }()
    
    let progressBar: NSProgressIndicator = {
        let progressBar = NSProgressIndicator()
        
        progressBar.style = .bar
        return progressBar
    }()
    
    let titleStackView: NSStackView = {
        let stackView = NSStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.orientation = .horizontal
        stackView.alignment = .centerY
        stackView.spacing = 2
        return stackView
    }()
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: NSRect) {
        super.init(frame: frame)
        
        translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(titleStackView)
        
        titleStackView.addArrangedSubview(imageView)
        titleStackView.addArrangedSubview(textField)

        updateLayout()
    }
    
    convenience init(icon: NSImage?, text: String) {
        self.init(frame: NSRect(x: 0, y: 0, width: 50, height: 30))
        
        imageView.image = icon
        textField.stringValue = text
    }
    
    private func updateLayout() {
        NSLayoutConstraint.activate([
            leadingAnchor.constraint(equalTo: titleStackView.leadingAnchor),
            trailingAnchor.constraint(equalTo: titleStackView.trailingAnchor),
            topAnchor.constraint(equalTo: titleStackView.topAnchor),
            bottomAnchor.constraint(equalTo: titleStackView.bottomAnchor),
        ])
    }
}
