//
//  ZYDynamicItem.swift
//  ZYScrollController
//
//  Created by zhouyu on 2018/8/22.
//  Copyright © 2018年 zhouyu. All rights reserved.
//

import UIKit

class ZYDynamicItem: NSObject, UIDynamicItem {
    
    var center: CGPoint
    var bounds: CGRect
    var transform: CGAffineTransform
    
    override init() {
        bounds = CGRect(x: 0.0, y: 0.0, width: 1.0, height: 1.0)
        center = CGPoint(x: 0.0, y: 0.0)
        transform = CGAffineTransform(a: 0.0, b: 0.0, c: 0.0, d: 0.0, tx: 0.0, ty: 0.0)
        super.init()
    }
    
}
