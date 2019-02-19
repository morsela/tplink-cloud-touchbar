//
//  TPLinkDeviceFactory.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/12/19.
//  Copyright © 2019 Sela. All rights reserved.
//

import Cocoa

class TPLinkDeviceFactory {
    public static func create(info: TPLinkDeviceInfo, client: TPLinkClient) -> TPLinkDevice? {
        if info.deviceModel.contains("LB100") {
            return TPLinkLB100(from: info, client: client)
        } else if info.deviceModel.contains("HS105") {
            return TPLinkHS105(from: info, client: client)
        } else {
            assertionFailure("Unknown device model encountered: \(info.deviceModel)")

            return nil
        }
    }
}
