//
//  API.swift
//  LeoCommon
//
//  Created by 李理 on 2017/4/12.
//  Copyright © 2017年 李理. All rights reserved.
//

import Foundation
import Alamofire
import ObjectMapper
import AlamofireObjectMapper

var API_MANAGER_DICT:Dictionary<String, Alamofire.SessionManager> = [:]
public typealias HTTPMethod = Alamofire.HTTPMethod

public protocol APIDelegate {
    func defaultHTTPHeaders() -> HTTPHeaders?
}

open class API:Alamofire.SessionManager {
    
    public let basePath:String
    
    private var manager:Alamofire.SessionManager?
    
    public var apiDelegate:APIDelegate?
    
    public init(basePath:String) {
        self.basePath = basePath
        super.init()
    }
    
    private func createManager() -> Alamofire.SessionManager {
        if self.manager == nil {
            if API_MANAGER_DICT[self.basePath] != nil {
                self.manager = API_MANAGER_DICT[self.basePath]!
            } else {
                let configuration = URLSessionConfiguration.default
                configuration.timeoutIntervalForRequest = 30
                configuration.httpAdditionalHeaders = self.buildHeaders()
                API_MANAGER_DICT[basePath] = self.manager
                self.manager = Alamofire.SessionManager(configuration: configuration)
            }
        }
        return self.manager!
    }
    
    private func buildHeaders(_ headers:HTTPHeaders? = nil) -> HTTPHeaders {
        var httpHeaders = SessionManager.defaultHTTPHeaders
        guard self.apiDelegate != nil else { return httpHeaders }
        guard self.apiDelegate!.defaultHTTPHeaders() != nil else { return httpHeaders }
        for (key, value) in self.apiDelegate!.defaultHTTPHeaders()! {
            httpHeaders[key] = value
        }
        guard headers != nil else {
            return httpHeaders
        }
        for (key, value) in headers! {
            httpHeaders[key] = value
        }
        return httpHeaders
    }
    
    public func execute<T:BaseMappable>(_ url: String,
                        method: HTTPMethod = .get,
                        parameters: Parameters? = nil,
                        headers: HTTPHeaders? = nil,
                        timeoutInterval: TimeInterval? = 30,
                        callback: @escaping ((LeoResult<T>) -> Void)) -> String {
        let absURL = self.basePath + url
        
        var request:URLRequest = URLRequest(url: URL(string: absURL)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeoutInterval!)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = self.buildHeaders(headers)
        debugPrint(request.allHTTPHeaderFields!)
        do {
            let encodedURLRequest = try URLEncoding.default.encode(request, with: parameters)
            self.createManager().request(encodedURLRequest).responseObject { (response:DataResponse<T>) in
                debugPrint(response.request?.allHTTPHeaderFields ?? [:])
                if let error = response.error {
                    callback(.failure(.afFailured(error: error)))
                } else {
                    callback(.success(response.value!))
                }
            }
        } catch {
            callback(.failure(.parameterEncodeFailured(error: error)))
        }
        return UUID().uuidString
    }
    
    deinit {
        debugPrint("API deinit")
    }
}
