//
//  TPLinkDevice.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/12/19.
//  Copyright © 2019 Sela. All rights reserved.
//

import Cocoa

public struct TPLinkDeviceInfo: Decodable {
    public let appServerUrl: String
    public let deviceId: String
    public let deviceName: String
    public let deviceType: String
    public let deviceModel: String
    public let alias: String
    public let fwId: String
    public let hwId: String
    public let deviceHwVer: String
    public let oemId: String
    public var status: Int
    public let role: Int
}

public class TPLinkDevice {
    public enum State: Int {
        case off = 0
        case on = 1
        case unknown = 2
        
        init(isOn: Bool) {
            self.init(value: isOn ? 1 : 0)
        }
        
        init(value: Int) {
            self = State.init(rawValue: value) ?? .off
        }

        public func isOn() -> Bool {
            return self == .on
        }
        
        public func isOff() -> Bool {
            return self == .off
        }
    }
    
    public let info: TPLinkDeviceInfo
    public var state: State = State.unknown
    
    weak var client: TPLinkClient?
    
    init(from info: TPLinkDeviceInfo, client: TPLinkClient) {
        self.info = info
        self.client = client
    }
    
    public func run<Request: Encodable, Response: Decodable>(_ request: Request, responseType: Response.Type, completion: @escaping CompletionWith<Response>) {
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
