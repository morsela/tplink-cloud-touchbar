//
//  TPLinkDevice.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/12/19.
//  Copyright © 2019 Sela. All rights reserved.
//

import Cocoa

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
    
    public func run<Request: Encodable, Response: Decodable>(_ request: Request, responseType: Response.Type, completion: @escaping (APIResult<Response>) -> Void) {
        client?.run(request, deviceId: info.deviceId, appServerUrl: info.appServerUrl, responseType: responseType, completion: completion)
    }
    
    public func run(_ command: String, completion: @escaping CompletionWith<Data>) {
        client?.run(command, deviceId: info.deviceId, appServerUrl: info.appServerUrl, completion: completion)
    }
    
    public func powerOn(completion: @escaping Completion) {
        assertionFailure("Not implemented for model \(info.deviceModel)")
    }
    
    public func powerOff(completion: @escaping Completion) {
        assertionFailure("Not implemented for model \(info.deviceModel)")
    }
    
    public func refreshDeviceState(completion: @escaping Completion) {
        completion(.failure(APIError("unsupported")))
    }
    
    public func toggle(completion: @escaping Completion) {
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
}
