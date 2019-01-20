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

typealias CompletionWith<T> = (APIResult<T>) -> Void
typealias Completion = CompletionWith<Void>

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
    
    func request<ResponseType: Decodable, T>(method: String, host: String = "https://wap.tplinkcloud.com", parameters: [String: Any], completion: @escaping CompletionWith<T>, handler: @escaping (ResponseType) -> T) {
        var innerParameters: [String: Any] = ["appType": "Kasa_Android"]
        if let token = token {
            innerParameters["token"] = token
        }
        innerParameters.merge(parameters, uniquingKeysWith: { (current, _) in current })
        
        let parameters: [String: Any] = [
            "method": method,
            "params": innerParameters
        ]
        
        Alamofire.request(host, method: .post, parameters: parameters, encoding: JSONEncoding.default).validate().responseData { response in
            switch response.result {
            case .success(let data):
                if let response = try? JSONDecoder().decode(ResponseType.self, from: data) {
                    completion(.success(handler(response)))
                } else {
                    completion(.failure(APIError("json parse error")))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func login(user: String, password: String, termId: String, completion: @escaping Completion) {
        let params = ["cloudPassword": password,
                      "cloudUserName": user,
                      "terminalUUID": termId]
        request(method: "login", parameters: params, completion: completion, handler: { [weak self] (data: LoginResponse) in
            self?.token = data.result.token
        })
    }
    
    func listDevices(completion: @escaping CompletionWith<[TPLinkDevice]>) {
        request(method: "getDeviceList", parameters: [:], completion: completion, handler: { [weak self] (data: ListDevicesResponse) in
            guard let strongSelf = self else { return [] }

            return data.result.deviceList.compactMap { TPLinkDeviceFactory.create(info: $0, client: strongSelf) }
        })
    }
    
    func run(_ command: String, deviceId: String, appServerUrl: String, completion: @escaping CompletionWith<Data>) {
        let params = ["deviceId": deviceId,
                      "requestData": command]
        
        request(method: "passthrough", host: appServerUrl, parameters: params, completion: completion, handler: { (data: RunResponse) in
            return data.result.responseData.data(using: .utf8) ?? Data()
        })
    }
    
    public func run<T: Decodable>(_ command: String, deviceId: String, appServerUrl: String, responseType: T.Type, completion: @escaping CompletionWith<T>) {
        run(command, deviceId: deviceId, appServerUrl: appServerUrl) { result in
            switch result {
            case .success(let data):
                if let decodedResponseData = try? JSONDecoder().decode(responseType, from: data) {
                    completion(.success(decodedResponseData))
                } else {
                    completion(.failure(APIError("json parse error")))
                }
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    public func run<Request: Encodable, Response: Decodable>(_ request: Request, deviceId: String, appServerUrl: String, responseType: Response.Type, completion: @escaping CompletionWith<Response>) {
        if let encodedObject = try? JSONEncoder().encode(request),
            let encodedObjectJsonString = String(data: encodedObject, encoding: .utf8) {
            
            run(encodedObjectJsonString, deviceId: deviceId, appServerUrl: appServerUrl, responseType: responseType, completion: completion)
        } else {
            completion(.failure(APIError("request json encode failure")))
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
