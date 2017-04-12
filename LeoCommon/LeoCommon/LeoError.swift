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
        case noReturnForAsync
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

extension LeoError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .localStorageSaveFailured(let reason):
            return reason.localizedDescription
        case .localStorageEncodeFailured(let reason):
            return reason.localizedDescription
        case .localStorageDecodeFailured(let reason):
            return reason.localizedDescription
        }
    }
}

extension LeoError.LocalStorageSaveFailureReason {
    var localizedDescription: String {
        switch self {
        case .unknown(let desc):
            return "unknow error: \(desc)"
        case .notfound(let key):
            return "not found for key: \(key)"
        case .noReturnForAsync():
            return "not return value for async restore"
        case .encodeFailed(let error):
            return "could not be save because of error: \(error.localizedDescription)"
        case .decodeFailed(let error):
            return "could not be restore because of error: \(error.localizedDescription)"
        }
    }
}

extension LeoError.LocalStorageEncodeFailureReason {
    var localizedDescription: String {
        switch self {
        case .unknown(let value):
            return "encode failed for value: \(value)"
        }
    }
}

extension LeoError.LocalStorageDecodeFailureReason {
    var localizedDescription: String {
        switch self {
        case .unknown(let value):
            return "decode failed for value: \(value)"
        }
    }
}
