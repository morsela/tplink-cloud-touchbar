//
//  TPLinkHS100.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/12/19.
//  Copyright © 2019 Sela. All rights reserved.
//

import Cocoa

class TPLinkHS100: TPLinkDevice {
    public override func powerOn(completion: @escaping Completion) {
        setState(isOn: true, completion: completion)
    }
    
    public override func powerOff(completion: @escaping Completion) {
        setState(isOn: false, completion: completion)
    }
    
    public func sysInfo(completion: @escaping CompletionWith<SysInfoCodable>) {
        let sysInfoRequest = SysInfoCodable(system: SysInfoCodable.System(sysInfo: SysInfo(relayState: nil)))
        
        run(sysInfoRequest, responseType: SysInfoCodable.self, completion: completion)
    }

    public override func refreshDeviceState(completion: @escaping Completion) {
        sysInfo() { result in
            switch result {
            case .success(let data):
                if let relayState = data.system.sysInfo.relayState {
                    self.state = State(rawValue: relayState) ?? State.off
                }

                completion(.success(Void()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    private func setState(isOn: Bool, completion: @escaping Completion) {
        let setStateRequest = SystemRequest(system: SystemRequest.System(setRelayState: SystemRequest.System.SetRelayState(state: isOn ? 1 : 0)))
        run(setStateRequest, responseType: VoidStruct.self) { result in
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
    struct VoidStruct: Codable {}

    struct SystemRequest: Encodable {
        struct System: Encodable {
            struct SetRelayState: Encodable {
                let state: Int
            }

            let setRelayState: SetRelayState
            
            enum CodingKeys: String, CodingKey {
                case setRelayState = "set_relay_state"
            }
        }

        let system: System
    }

    struct SysInfo: Codable {
        let relayState: Int?
        
        enum CodingKeys: String, CodingKey {
            case relayState = "relay_state"
        }
    }
    
    struct SysInfoCodable: Codable {
        struct System: Codable {
            let sysInfo: SysInfo
            
            enum CodingKeys: String, CodingKey {
                case sysInfo = "get_sysinfo"
            }
        }
        
        let system: System
    }
}
