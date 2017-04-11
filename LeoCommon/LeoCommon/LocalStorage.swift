//
//  LocalStorage.swift
//  LeoCommon
//
//  Created by 李理 on 2017/4/11.
//  Copyright © 2017年 李理. All rights reserved.
//

import Foundation
import Result

public typealias LocalStorageCallBack = (Result<Any, LeoError>) -> Void
public typealias LocalStorageEncode = (Any) -> Result<Any, LeoError>
public typealias LocalStorageDecode = (Any) -> Result<Any, LeoError>

final public class LocalStorage {

    public static let shared: LocalStorage = LocalStorage()

    private init() { }
    
    let queue = DispatchQueue(label: "com.leo.localstorage")
    
    public func save(_ value:Any, key:String, async:Bool, encode:@escaping LocalStorageEncode, callback: @escaping LocalStorageCallBack) -> Void {
        let action = {
            let encodeValue = encode(value)
            encodeValue.analysis(ifSuccess: { data in
                UserDefaults.standard.setValue(data, forKey: key)
                UserDefaults.standard.synchronize()
                DispatchQueue.main.async {
                    callback(.success(value))
                }
            }, ifFailure: { error in
                callback(.failure(.localStorageSaveFailured(reason: .encodeFailed(error: error))))
            })
        }
        if async {
            queue.async {
                action()
            }
        } else {
            action()
        }
    }
    
    public func save(_ value:Any, key:String, async:Bool, callback: @escaping LocalStorageCallBack) -> Void {
        self.save(value, key: key, async: async, encode: { (value) -> Result<Any, LeoError> in
            return .success(value)
        }, callback: callback)
    }
    
    public func save(_ value:Any, key:String, async:Bool) -> Void {
        self.save(value, key: key, async: async, callback: { (result) -> Void in
            debugPrint("save value success for key: ", key)
        })
    }
    
    public func save(_ value:Any, key:String) -> Void {
        self.save(value, key: key, async: false)
    }
    
    public func restore(_ key:String, async:Bool, decode:@escaping LocalStorageDecode, callback: @escaping LocalStorageCallBack) -> Void {
        let action = {
            let data = UserDefaults.standard.value(forKey: key)
            if data != nil {
                let decodeValue = decode(data!)
                DispatchQueue.main.async {
                    decodeValue.analysis(ifSuccess: { value in
                        callback(.success(value))
                    }, ifFailure: { error in
                        callback(.failure(.localStorageSaveFailured(reason: .decodeFailed(error: error))))
                    })
                }
            } else {
                callback(.failure(.localStorageSaveFailured(reason:.notfound(key: key))))
            }
        }
        if async {
            queue.async {
                action()
            }
        } else {
            action()
        }
    }
    
    public func restore(_ key:String, async:Bool, callback: @escaping LocalStorageCallBack) -> Void {
        self.restore(key, async: async, decode: { (data) -> Result<Any, LeoError> in
            return .success(data)
        }, callback: callback)
    }

    public func restore(_ key:String, async:Bool) -> Void {
        self.restore(key, async: async, callback: { (result) -> Void in
            debugPrint("restore value success for key: ", key)
        })
    }
    
    public func restore(_ key:String) -> Void {
        self.restore(key, async: false)
    }
}
