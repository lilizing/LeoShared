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

var API_MANAGERS:Dictionary<String, Alamofire.SessionManager> = [:]
var API_REQUESTS:Dictionary<String, Alamofire.DataRequest> = [:]

public typealias HTTPMethod = Alamofire.HTTPMethod
public typealias Parameters = Alamofire.Parameters
public typealias HTTPHeaders = Alamofire.HTTPHeaders

public protocol APIDelegate {
    func defaultHTTPHeaders() -> HTTPHeaders?
}

open class API:Alamofire.SessionManager {
    
    public let basePath:String
    
    private var manager:Alamofire.SessionManager?
    
    public var apiDelegate:APIDelegate?
    
    private let queue = DispatchQueue(label: "com.leo.api.queue")
    
    public init(basePath:String) {
        self.basePath = basePath
        super.init()
    }
    
    private func createManager() -> Alamofire.SessionManager {
        if self.manager == nil {
            if API_MANAGERS[self.basePath] != nil {
                self.manager = API_MANAGERS[self.basePath]!
            } else {
                let configuration = URLSessionConfiguration.default
                configuration.timeoutIntervalForRequest = 30
                configuration.httpAdditionalHeaders = self.buildHeaders()
                self.manager = Alamofire.SessionManager(configuration: configuration)
                API_MANAGERS[basePath] = self.manager
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
    
    public func fetch<T:BaseMappable>(_ url: String,
                      method: HTTPMethod = .get,
                      parameters: Parameters? = nil,
                      headers: HTTPHeaders? = nil,
                      timeoutInterval: TimeInterval? = 30,
                      resultMap: @escaping ([String : Any]) -> (TResult<T>),
                      errorHandler: @escaping (TResult<T>) -> Void = { _ in },
                      callback: @escaping (TResult<T>) -> Void = { _ in }) -> String {
        let absURL = self.basePath + url
        var request:URLRequest = URLRequest(url: URL(string: absURL)!, cachePolicy: .useProtocolCachePolicy, timeoutInterval: timeoutInterval!)
        request.httpMethod = method.rawValue
        request.allHTTPHeaderFields = self.buildHeaders(headers)
        let requestID = UUID().uuidString
        do {
            let encodedURLRequest = try URLEncoding.default.encode(request, with: parameters)
            let task = self.createManager().request(encodedURLRequest).responseJSON(completionHandler: { response in
                var result:TResult<T>? = nil
                if let error = response.error {
                    result = .failure(TAnyError(error))
                } else {
                    result = resultMap(response.value! as! [String : Any])
                }
                errorHandler(result!)
                callback(result!)
            })
            self.queue.sync {
                API_REQUESTS[requestID] = task
            }
        } catch {
            callback(.failure(TAnyError(error)))
        }
        return requestID
    }
    
    deinit {
        debugPrint("API deinit")
    }
    
    public func cancel(requestID:String) {
        if let request = API_REQUESTS[requestID] {
            request.cancel()
            _ = self.queue.sync {
                API_REQUESTS.removeValue(forKey: requestID)
            }
        }
    }
}
