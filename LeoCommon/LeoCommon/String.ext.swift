//
//  String.ext.swift
//  LeoCommon
//
//  Created by 李理 on 2017/4/19.
//  Copyright © 2017年 李理. All rights reserved.
//

import Foundation

import HEXColor
import SwiftRichString

extension String {
    public func string(name:String, size:Int, hex:String) -> NSAttributedString {
        let style = Style.init { style in
            style.font = FontAttribute.init(name, size: Float(size))
            style.color = UIColor(hex)
        }
        return self.set(style: style)
    }
    
    public func string(name:String, size:Int, color:UIColor) -> NSAttributedString {
        let style = Style.init { style in
            style.font = FontAttribute.init(name, size: Float(size))
            style.color = color
        }
        return self.set(style: style)
    }
}