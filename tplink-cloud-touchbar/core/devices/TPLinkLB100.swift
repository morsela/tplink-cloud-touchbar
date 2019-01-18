//
//  TPLinkLB100.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/12/19.
//  Copyright © 2019 Sela. All rights reserved.
//

import Cocoa

class TPLinkLB100: TPLinkDevice & BulbDevice {
    var brightness: Int = 100
    
    public override func powerOn(completion: @escaping Completion) {
        setState(isOn: true, completion: completion)
    }
    
    public override func powerOff(completion: @escaping Completion) {
        setState(isOn: false, completion: completion)
    }
    
    func setBrightness(_ brightness: Int, completion: @escaping Completion) {
        setState(isOn: true, brightness: brightness, completion: completion)
    }
    
    private func setState(isOn: Bool, brightness: Int = 100, completion: @escaping Completion) {
        let setState = SetState(lightingService: SetState.LightingService(lightState: LightState(brightness: brightness, onOff: isOn ? 1 : 0, dftOnState: nil)))
        run(setState, responseType: SetState.self) { [weak self] result in
            switch result {
            case .success(let data):
                self?.updateState(data.lightingService.lightState)

                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func updateState(_ state: LightState) {
        if let brightness = state.brightness ?? state.dftOnState?.brightness {
            self.brightness = brightness
            
        }

        if let onOff = state.onOff {
            self.state = State(value: onOff)
        }
        
        print("LB \(info.alias) state: \(self.state), brightness: \(self.brightness)")
    }

    public override func refreshDeviceState(completion: @escaping Completion) {
        let getState = GetState(lightingService: GetState.LightingService(lightState: LightState(brightness: nil, onOff: nil, dftOnState: nil)))
        run(getState, responseType: GetState.self) { [weak self] result in
            switch result {
            case .success(let data):
                self?.updateState(data.lightingService.lightState)
                
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public var supportsBrightnessAdjustment: Bool {
        return true
    }
}

extension TPLinkLB100 {
    struct LightState: Codable {
        struct DftOnState: Codable {
            let brightness: Int
        }
        
        let brightness: Int?
        let onOff: Int?
        let dftOnState: DftOnState?
        
        enum CodingKeys: String, CodingKey {
            case brightness
            case dftOnState = "dft_on_state"
            case onOff = "on_off"
        }
    }
    
    struct GetState: Codable {
        struct LightingService: Codable {
            let lightState: LightState
            
            enum CodingKeys: String, CodingKey {
                case lightState = "get_light_state"
            }
        }
        
        let lightingService: LightingService
        
        enum CodingKeys: String, CodingKey {
            case lightingService = "smartlife.iot.smartbulb.lightingservice"
        }
    }
    
    struct SetState: Codable {
        struct LightingService: Codable {
            let lightState: LightState
            
            enum CodingKeys: String, CodingKey {
                case lightState = "transition_light_state"
            }
        }
        
        let lightingService: LightingService
        
        enum CodingKeys: String, CodingKey {
            case lightingService = "smartlife.iot.smartbulb.lightingservice"
        }
    }
}
