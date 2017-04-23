//
// Created by 李理 on 2017/4/19.
// Copyright (c) 2017 李理. All rights reserved.
//

import Foundation
import ReactiveSwift

open class BaseObject {
    private let token = Lifetime.Token()
    public var lifetime: Lifetime {
        return Lifetime(token)
    }
    
    public init() {
        let type = String(describing: self).components(separatedBy: ".").last!
        self.lifetime.observeEnded {
            debugPrint("\(type) lifetime is ended")
        }
    }
}
