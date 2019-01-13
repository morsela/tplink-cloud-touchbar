//
//  BulbDevice.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/12/19.
//  Copyright © 2019 Sela. All rights reserved.
//

import Cocoa

protocol BulbDevice {
    var supportsBrightnessAdjustment: Bool { get }
    
    func setBrightness(_ brightness: Int32, completion: @escaping Completion)
    
    var brightness: Int32 { get }
}

