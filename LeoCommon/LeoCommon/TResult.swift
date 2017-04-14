//
//  LeoResult.swift
//  LeoCommon
//
//  Created by 李理 on 2017/4/13.
//  Copyright © 2017年 李理. All rights reserved.
//

// 该工具类主要用于解决Alamofire和Result框架的冲突

import Foundation
import Result

public typealias TAnyError = AnyError
public typealias TNoError = NoError
public typealias TResult<T> = Result<T, TAnyError>
