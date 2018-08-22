//
//  UIScrollView+ZYScrollOffset.swift
//  ZYScrollController
//
//  Created by zhouyu on 2018/8/22.
//  Copyright © 2018年 zhouyu. All rights reserved.
//

import Foundation
import UIKit

extension UIScrollView {
    /// 最大的contentoffset.y
    func zy_maxOffsetY() -> CGFloat {
        if #available(iOS 11.0, *) {
            return adjustedContentInset.bottom + max(contentSize.height - bounds.size.height, 0)
        } else {
            return contentInset.bottom + max(contentSize.height - bounds.size.height, 0)
        }
    }
    
    /// 最小的contentoffset.y
    func zy_minOffsetY() -> CGFloat {
        if #available(iOS 11.0, *) {
            return -adjustedContentInset.top
        } else {
            return -contentInset.top;
        }
    }
    
    /// contentoffset.y是否不合法
    func zy_isOffsetYIlleagal() -> Bool {
        return contentOffset.y > zy_maxOffsetY()  || self.contentOffset.y < zy_minOffsetY();
    }
    
    func zy_setOffsetY(y: CGFloat) {
        contentOffset = CGPoint(x: contentOffset.x, y: y)
    }
}
