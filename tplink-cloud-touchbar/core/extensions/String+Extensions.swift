//
//  String+Extensions.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/6/19.
//  Copyright © 2019 Sela. All rights reserved.
//

import Cocoa

extension String {
    func convertToDictionary() -> [String: Any]? {
        if let data = self.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
}
