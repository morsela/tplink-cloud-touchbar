//
//  BulbDevice.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/12/19.
//  Copyright © 2019 Sela. All rights reserved.
//

import Cocoa

public protocol BulbDevice {
    var supportsBrightnessAdjustment: Bool { get }
    
    func setBrightness(_ brightness: Int, completion: @escaping Completion)
    
    var brightness: Int { get }
}

