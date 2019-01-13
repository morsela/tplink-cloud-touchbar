//
//  TPLinkClient.swift
//  tplink-cloud-touchbar
//
//  Created by Mor Sela on 1/6/19.
//  Copyright © 2019 Sela. All rights reserved.
//

import Alamofire

enum APIResult<T> {
    case success(T)
    case failure(Error)
}

typealias DataCompletion = (APIResult<Data>) -> Void
typealias Completion = (APIResult<Void>) -> Void

public struct APIError: Error {
    public let message: String
    
    init(_ message: String) {
        self.message = message
    }
}

class TPLinkClient {
    private var token: String?

    private var isInitialized: Bool {
        return token != nil
    }
    
    func login(user: String, password: String, termId: String, completion: @escaping Completion) {
        let parameters: [String: Any] = [
            "method": "login",
            "params": [
                "appType": "Kasa_Android",
                "cloudPassword": password,
                "cloudUserName": user,
                "terminalUUID": termId
            ]
        ]
        
        Alamofire.request("https://wap.tplinkcloud.com", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { [weak self] response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                if let response = try? decoder.decode(LoginResponse.self, from: data) {
                    self?.token = response.result.token
                    
                    completion(.success(Void()))
                } else {
                    completion(.failure(APIError("json parse error")))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func listDevices(completion: @escaping (APIResult<[TPLinkDevice]>) -> Void) {
        let parameters: [String: Any] = [
            "method": "getDeviceList",
            "params": [
                "appType": "Kasa_Android",
                "token": token
            ]
        ]

        Alamofire.request("https://wap.tplinkcloud.com", method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { [weak self] response in
            switch response.result {
            case .success(let data):
                guard let strongSelf = self else { return }
                
                let decoder = JSONDecoder()
                if let response = try? decoder.decode(ListDevicesResponse.self, from: data) {
                    let devices = response.result.deviceList.compactMap { TPLinkDeviceFactory.create(info: $0, client: strongSelf) }
                    
                    completion(.success(devices))
                } else {
                    completion(.failure(APIError("json parse error")))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func refreshDevicesState(devices: [TPLinkDevice], completion: @escaping Completion) {
        let dispatchGroup = DispatchGroup()
        
        for device in devices {
            dispatchGroup.enter()
            device.refreshDeviceState() { _ in
                dispatchGroup.leave()
            }
        }
        
        dispatchGroup.notify(queue: .main) {
            completion(.success(Void()))
        }
    }
    
    func run(deviceId: String, command: String, appServerUrl: String, completion: @escaping DataCompletion) {
        let parameters: [String: Any] = [
            "method": "passthrough",
            "params": [
                "appType": "Kasa_Android",
                "token": token,
                "deviceId": deviceId,
                "requestData": command
            ]
        ]
        
        Alamofire.request(appServerUrl, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { response in
            switch response.result {
            case .success(let data):
                let decoder = JSONDecoder()
                if let response = try? decoder.decode(RunResponse.self, from: data),
                    let responseData = response.result.responseData.data(using: .utf8) {
                    completion(.success(responseData))
                } else {
                    completion(.failure(APIError("json parse error")))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
}

extension TPLinkClient {
    struct RunResponse: Decodable {
        struct Result: Decodable {
            let responseData: String
        }
        
        let result: Result
    }
    
    struct LoginResponse: Decodable {
        struct Result: Decodable {
            let token: String
        }
        
        let result: Result
    }
    
    struct ListDevicesResponse: Decodable {
        struct Result: Decodable {
            let deviceList: [TPLinkDeviceInfo]
        }
        
        let result: Result
    }
}
