//
//  APIService.swift
//  LeoCommon
//
//  Created by 李理 on 2017/4/12.
//  Copyright © 2017年 李理. All rights reserved.
//

import Foundation
import Alamofire

open class APIService:APIDelegate {
    public init() {}
    public func defaultHTTPHeaders() -> HTTPHeaders? {
        return nil
    }
}
