//
//  ErrorExt.swift
//  LeoCommon
//
//  Created by 李理 on 2017/4/11.
//  Copyright © 2017年 李理. All rights reserved.
//

import Foundation
import Result

public enum LeoError:Error {
    
    public enum LocalStorageSaveFailureReason {
        case unknown(desc: String)
        case notfound(key: String)
        case encodeFailed(error: Error)
        case decodeFailed(error: Error)
    }
    
    public enum LocalStorageEncodeFailureReason {
        case unknown(value: Any)
    }
    
    public enum LocalStorageDecodeFailureReason {
        case unknown(value: Any)
    }
    
    case localStorageSaveFailured(reason: LocalStorageSaveFailureReason)
    case localStorageEncodeFailured(reason: LocalStorageEncodeFailureReason)
    case localStorageDecodeFailured(reason: LocalStorageDecodeFailureReason)
}

extension LeoError.LocalStorageSaveFailureReason {
    var localizedDescription: String {
        switch self {
        case .unknown(let desc):
            return "unknow error:\n\(desc)"
        case .notfound(let key):
            return "not found for key:\(key)"
        case .encodeFailed(let error):
            return "encode failed for value: "
        case .decodeFailed(let error):
            return "decode failed for value: "
        }
    }
}
