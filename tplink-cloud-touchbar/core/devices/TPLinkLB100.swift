//
//  TPLinkLB100.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/12/19.
//  Copyright © 2019 Sela. All rights reserved.
//

import Cocoa

class TPLinkLB100: TPLinkDevice & BulbDevice {
    var brightness: Int32 = 100
    
    public override func powerOn(completion: @escaping (APIResult<Void>) -> Void) {
        setState(isOn: true, completion: completion)
    }
    
    public override func powerOff(completion: @escaping (APIResult<Void>) -> Void) {
        setState(isOn: false, completion: completion)
    }
    
    private func setState(isOn: Bool, brightness: Int = 100, completion: @escaping (APIResult<Void>) -> Void) {
        run(command: "{\"smartlife.iot.smartbulb.lightingservice\":{\"transition_light_state\":{ \"brightness\": \(brightness) , \"on_off\": \(isOn ? "1" : "0")}}}") { [weak self] result in
            switch result {
            case .success(let value):
                if let responseData = value["responseData"] as? String,
                    let jsonData = responseData.convertToDictionary(),
                    let lightingservice = jsonData["smartlife.iot.smartbulb.lightingservice"] as? [String: Any],
                    let state = lightingservice["transition_light_state"] as? [String: Any] {
                    
                    self?.updateState(state)
                    
                    completion(.success(Void()))
                } else {
                    completion(.failure(APIError("json parsing failure")))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func setBrightness(_ brightness: Int32) {
        setState(isOn: true, brightness: Int(brightness), completion: { _ in })
    }
    
    private func updateState(_ state: [String: Any]) {
        if let dftOnState = state["dft_on_state"] as? [String: Any],
            let brightness = dftOnState["brightness"] as? Int {
            self.brightness = Int32(brightness)
        }
        
        if let brightness = state["brightness"] as? Int {
            self.brightness = Int32(brightness)
        }
        
        if let onOff = state["on_off"] as? Int {
            self.state = State(rawValue: onOff) ?? State.off
        }
    }
    
    public override func refreshDeviceState(completion: @escaping (APIResult<Void>) -> Void) {
        run(command: "{\"smartlife.iot.smartbulb.lightingservice\":{\"get_light_state\":{}}}") { [weak self] result in
            switch result {
            case .success(let value):
                if let responseData = value["responseData"] as? String,
                    let jsonData = responseData.convertToDictionary(),
                    let lightingservice = jsonData["smartlife.iot.smartbulb.lightingservice"] as? [String: Any],
                    let state = lightingservice["get_light_state"] as? [String: Any] {
                    
                    self?.updateState(state)
                    completion(.success(Void()))
                } else {
                    completion(.failure(APIError("json parsing failure")))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public var supportsBrightnessAdjustment: Bool {
        return true
    }
}
