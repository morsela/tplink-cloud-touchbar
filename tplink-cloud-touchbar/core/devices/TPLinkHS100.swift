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
    
    public override func refreshDeviceState(completion: @escaping (APIResult<Void>) -> Void) {
        sysInfo() { result in
            switch result {
            case .success(let value):
                if let responseData = value["responseData"] as? String,
                    let jsonData = responseData.convertToDictionary(),
                    let system = jsonData["system"] as? [String: Any],
                    let sysInfo = system["get_sysinfo"] as? [String: Any],
                    let relayState = sysInfo["relay_state"] as? Int {
                    
                    self.state = State(rawValue: relayState) ?? State.off
                    
                    completion(.success(Void()))
                } else {
                    completion(.failure(APIError("json parsing failure")))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    private func setState(isOn: Bool, completion: @escaping (APIResult<Void>) -> Void) {
        run(command: "{\"system\":{\"set_relay_state\":{ \"state\": \(isOn ? "1" : "0")}}}") { result in
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
