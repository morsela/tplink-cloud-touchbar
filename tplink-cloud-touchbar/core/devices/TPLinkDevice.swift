//
//  TPLinkDevice.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/12/19.
//  Copyright © 2019 Sela. All rights reserved.
//

struct TPLinkDeviceInfo: Decodable {
    let appServerUrl: String
    let deviceId: String
    let deviceName: String
    let deviceType: String
    let deviceModel: String
    let alias: String
    let fwId: String
    let hwId: String
    let deviceHwVer: String
    let oemId: String
    var status: Int
    let role: Int
}

class TPLinkDevice {
    enum State: Int {
        case off = 0
        case on = 1
        case unknown = 2
        
        func isOn() -> Bool {
            return self == .on
        }
        
        func isOff() -> Bool {
            return self == .off
        }
    }
    
    let info: TPLinkDeviceInfo
    var state: State = State.unknown
    
    weak var client: TPLinkClient?
    
    init(from info: TPLinkDeviceInfo, client: TPLinkClient) {
        self.info = info
        self.client = client
    }
    
    public func sysInfo(completion: @escaping (APIResult<[String: Any]>) -> Void) {
        run(command: "{\"system\":{\"get_sysinfo\":{}}}", completion: completion)
    }
    
    public func powerOn(completion: @escaping (APIResult<Void>) -> Void) {
        assertionFailure("Not implemented for model \(info.deviceModel)")
    }
    
    public func powerOff(completion: @escaping (APIResult<Void>) -> Void) {
        assertionFailure("Not implemented for model \(info.deviceModel)")
    }
    
    public func refreshDeviceState(completion: @escaping (APIResult<Void>) -> Void) {
        completion(.failure(APIError("unsupported")))
    }
    
    public func toggle(completion: @escaping (APIResult<Void>) -> Void) {
        refreshDeviceState { [weak self] result in
            switch result {
            case .success:
                guard let strongSelf = self else { return }
                
                strongSelf.state == State.off ? strongSelf.powerOn(completion: completion) : strongSelf.powerOff(completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func run(command: String, completion: @escaping (APIResult<[String: Any]>) -> Void) {
        client?.run(deviceId: info.deviceId, command: command, appServerUrl: info.appServerUrl, completion: completion)
    }
}
