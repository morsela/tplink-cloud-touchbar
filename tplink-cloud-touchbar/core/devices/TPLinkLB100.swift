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
    
    public override func powerOn(completion: @escaping (APIResult<Void>) -> Void) {
        setState(isOn: true, completion: completion)
    }
    
    public override func powerOff(completion: @escaping (APIResult<Void>) -> Void) {
        setState(isOn: false, completion: completion)
    }
    
    private func setState(isOn: Bool, brightness: Int = 100, completion: @escaping Completion) {
        run("{\"smartlife.iot.smartbulb.lightingservice\":{\"transition_light_state\":{ \"brightness\": \(brightness) , \"on_off\": \(isOn ? "1" : "0")}}}", responseType: SetStateResponse.self) { [weak self] result in
            switch result {
            case .success(let data):
                self?.updateState(data.lightingService.lightState)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func setBrightness(_ brightness: Int, completion: @escaping Completion) {
        setState(isOn: true, brightness: brightness, completion: completion)
    }
    
    private func updateState(_ state: LightState) {
        self.brightness = state.brightness ?? state.dftOnState?.brightness ?? 100
        self.state = State(rawValue: state.onOff) ?? State.off
    }

    public override func refreshDeviceState(completion: @escaping Completion) {
        run("{\"smartlife.iot.smartbulb.lightingservice\":{\"get_light_state\":{}}}", responseType: GetStateResponse.self) { [weak self] result in
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
    struct LightState: Decodable {
        struct DftOnState: Decodable {
            let brightness: Int
        }
        
        let brightness: Int?
        let onOff: Int
        let dftOnState: DftOnState?
        
        enum CodingKeys: String, CodingKey {
            case brightness
            case dftOnState = "dft_on_state"
            case onOff = "on_off"
        }
    }
    
    struct GetStateResponse: Decodable {
        struct LightingService: Decodable {
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
    
    struct SetStateResponse: Decodable {
        struct LightingService: Decodable {
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
