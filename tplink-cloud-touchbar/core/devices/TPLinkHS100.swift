//
//  TPLinkHS100.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/12/19.
//  Copyright © 2019 Sela. All rights reserved.
//

import Cocoa

class TPLinkHS100: TPLinkDevice {
    public override func powerOn(completion: @escaping (APIResult<Void>) -> Void) {
        setState(isOn: true, completion: completion)
    }
    
    public override func powerOff(completion: @escaping (APIResult<Void>) -> Void) {
        setState(isOn: false, completion: completion)
    }
    
    public func sysInfo(completion: @escaping CompletionWith<SysInfoResponse>) {
        run("{\"system\":{\"get_sysinfo\":{}}}", responseType: SysInfoResponse.self, completion: completion)
    }

    public override func refreshDeviceState(completion: @escaping (APIResult<Void>) -> Void) {
        sysInfo() { result in
            switch result {
            case .success(let data):
                self.state = State(rawValue: data.system.sysInfo.relayState) ?? State.off
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func setState(isOn: Bool, completion: @escaping (APIResult<Void>) -> Void) {
        run("{\"system\":{\"set_relay_state\":{ \"state\": \(isOn ? "1" : "0")}}}") { result in
            switch result {
            case .success:
                self.state = State(rawValue: isOn ? 1 : 0) ?? State.off
                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

class TPLinkHS105: TPLinkHS100 {}

extension TPLinkHS100 {
    struct SysInfo: Decodable {
        let relayState: Int
        
        enum CodingKeys: String, CodingKey {
            case relayState = "relay_state"
        }
    }
    
    struct SysInfoResponse: Decodable {
        struct SystemResponse: Decodable {
            let sysInfo: SysInfo
            
            enum CodingKeys: String, CodingKey {
                case sysInfo = "get_sysinfo"
            }
        }
        
        let system: SystemResponse
    }
}
