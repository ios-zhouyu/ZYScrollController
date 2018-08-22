//
//  ZYScrollPanGestureRecognizer.swift
//  ZYScrollController
//
//  Created by zhouyu on 2018/8/22.
//  Copyright © 2018年 zhouyu. All rights reserved.
//

import UIKit
import UIKit.UIGestureRecognizerSubclass

@objc protocol ZYScrollPanGestureRecognizerDelegate: NSObjectProtocol {
    @objc optional func shouldGesturerBeBlocked(gestureRecognizer: ZYScrollPanGestureRecognizer) -> Bool
}

class ZYScrollPanGestureRecognizer: UIPanGestureRecognizer {
    weak var scrollDelegate: ZYScrollPanGestureRecognizerDelegate?
    // 阻塞的手势。场景: 滑动过程中开始的手势，识别为blocking，为无效手势
    var blocking: Bool = false
    // 是否禁止手势
    var prohibited: Bool = false
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        super.touchesBegan(touches, with: event)
        if self.scrollDelegate != nil
            && (self.scrollDelegate?.responds(to: #selector(ZYScrollPanGestureRecognizerDelegate.shouldGesturerBeBlocked(gestureRecognizer:))))!
            && (self.scrollDelegate?.shouldGesturerBeBlocked!(gestureRecognizer: self))! {
            prohibited = true
        } else {
            prohibited = false
        }
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        if prohibited {
            if canTouchesBeRecognized(touches: touches) {
                blocking = true
                state = .recognized
                return
            }
        }
        super.touchesMoved(touches, with: event)
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if prohibited {
            if canTouchesBeRecognized(touches: touches) {
                blocking = true
                state = .recognized
                return
            }
        }
        super.touchesEnded(touches, with: event)
    }
    
    override func reset() {
        super.reset()
        prohibited = false
        blocking = false
    }
    
    private func canTouchesBeRecognized(touches: Set<UITouch>) -> Bool {
        let touch: UITouch = (touches as NSSet).anyObject() as! UITouch
        let newPoint = touch.location(in: self.view)
        let previousPoint = touch.previousLocation(in: self.view)
        //FLT_EPSILON已废弃
        if fabs(newPoint.y - previousPoint.y) < CGFloat(Float.ulpOfOne) {
            return false
        }
        return true
    }
    
}
