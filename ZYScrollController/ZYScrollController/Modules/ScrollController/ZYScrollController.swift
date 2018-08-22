//
//  ZYScrollController.swift
//  ZYScrollController
//
//  Created by zhouyu on 2018/8/22.
//  Copyright © 2018年 zhouyu. All rights reserved.
//

import UIKit

class ZYScrollController: NSObject, UIGestureRecognizerDelegate, ZYScrollPanGestureRecognizerDelegate {
    
    //上滑的最大距离
    var superMaxScrollY: CGFloat = 0.0
    //整个控制器是否可下拉回弹效果
    var superPullDisable: Bool = false
    //父滑动视图
    private var _superScrollView: UIScrollView?
    var superScrollView: UIScrollView? {
        get {
            return _superScrollView
        }
        set {
            if _superScrollView != subScrollView {
                disableGesture()
                _superScrollView = subScrollView
                enableGesture()
            }
        }
    }
    //子滑动视图
    private var _subScrollView: UIScrollView?
    var subScrollView: UIScrollView? {
        get {
            return _subScrollView
        }
        set {
            if _subScrollView != subScrollView {
                disableGesture()
                _subScrollView = subScrollView
                enableGesture()
            }
        }
    }

    fileprivate var panView: UIView?
    fileprivate var panGesture: ZYScrollPanGestureRecognizer?
    fileprivate var isVertical: Bool = true
    
    //弹性和惯性动画
    fileprivate var animator: UIDynamicAnimator?
    fileprivate var decelerationBehavior: UIDynamicItemBehavior?
    fileprivate var dynamicItem: ZYDynamicItem?
    fileprivate var springBehavior: UIAttachmentBehavior?

    
    // MARK: public
    func setupTouch(view: UIView?) -> () {
        if let view = view {
            panView = view
            panGesture = ZYScrollPanGestureRecognizer(target: self, action: #selector(panGestureRecognizerAction(_ :)))
            panGesture?.delegate = self
            panGesture?.scrollDelegate = self
            panView?.addGestureRecognizer(panGesture!)
            animator = UIDynamicAnimator.init(referenceView: panView!)
            dynamicItem = ZYDynamicItem()
        }
    }
    
    @objc fileprivate func panGestureRecognizerAction(_ panGesture: ZYScrollPanGestureRecognizer) {
        if panGesture.blocking {
            animator?.removeAllBehaviors()
            return
        }
        
        switch panGesture.state {
        case .began:
            let translation = panGesture.translation(in: panView)
            let velocity = panGesture.velocity(in: panView)
            if translation.y == 0.0 {
                // 增加速度的判断
                if fabs(velocity.y) >= fabs(velocity.x * 2) {
                    isVertical = true
                } else {
                    isVertical = false
                }
            } else {
                if fabs(translation.x / translation.y) >= 5.0 {
                    isVertical = false
                } else {
                    isVertical = true
                }
            }
            animator?.removeAllBehaviors()
        case .changed:
            if isVertical {
                let currentY = panGesture.translation(in: panView).y
                if superPullDisable {
                    self.controlScrollVerticalWithoutSuperPull(detal: currentY)
                } else {
                    self.controlScrollForVerticalWithSuperPull(detal: currentY)
                }
            }
        case .cancelled:
            animator?.removeAllBehaviors()
        case .ended:
            if isVertical {
                dynamicItem?.center = (panView?.bounds.origin)!
                //velocity是在手势结束的时候获取的竖直方向的手势速度
                let velocity = panGesture.velocity(in: panView)
                let inertialBehavior = UIDynamicItemBehavior.init(items: [dynamicItem!])
                inertialBehavior.addLinearVelocity(CGPoint(x: 0, y: velocity.y), for: dynamicItem!)
                // 通过尝试取2.0比较像系统的效果
                inertialBehavior.resistance = 2.0
                var lastCenter = CGPoint(x: 0, y: 0)
                inertialBehavior.action = { [weak self] in
                    if (self?.isVertical)! {
                        let currentY = (self?.dynamicItem?.center.y)! - lastCenter.y
                        if (self?.superPullDisable)! {
                            self?.controlScrollVerticalWithoutSuperPull(detal: currentY)
                            self?.normalizeOffsetWithoutSuperPull()
                        } else {
                            self?.controlScrollForVerticalWithSuperPull(detal: currentY)
                            self?.normalizeOffsetWithSuperPull()
                        }
                    }
                    lastCenter = (self?.dynamicItem?.center)!
                }
                animator?.addBehavior(inertialBehavior)
                decelerationBehavior = inertialBehavior
            }
        default: break
        }
        //保证每次只是移动的距离，不是从头一直移动的距离
        panGesture.setTranslation(CGPoint(x: 0, y: 0), in: panView)
    }
    
    fileprivate func controlScrollForVerticalWithSuperPull(detal: CGFloat) {
        
    }
    
    fileprivate func controlScrollVerticalWithoutSuperPull(detal: CGFloat) {
        
    }
    
    fileprivate func normalizeOffsetWithSuperPull() {
        let outsideFrame = (self.superScrollView!.contentOffset.y < (self.superScrollView?.zy_minOffsetY())!) || (self.subScrollView!.contentOffset.y > (self.subScrollView?.zy_maxOffsetY())!)
        if outsideFrame == false || self.springBehavior == nil {
            return
        }
        animator?.removeBehavior(decelerationBehavior!)
        
        var action = {() -> () in }
        var target = CGPoint(x: 0, y: 0)
        if (self.superScrollView!.contentOffset.y < self.superScrollView!.zy_minOffsetY()) {
            // super超出边界
            self.dynamicItem?.center = (self.superScrollView?.contentOffset)!
            target = CGPoint(x: (self.superScrollView?.contentOffset.x)!, y: (self.superScrollView?.zy_minOffsetY())!)
            action = { [weak self] in
                if ((self?.superScrollView!.contentOffset.y)! < (self?.superScrollView!.zy_minOffsetY())!) {
                    self?.superScrollView?.contentOffset = (self?.dynamicItem?.center)!
                } else {
                    self?.animator?.removeBehavior((self?.springBehavior)!)
                    self?.springBehavior = nil
                }
            }
        } else if (self.superScrollView!.contentOffset.y > self.superScrollView!.zy_maxOffsetY()) {
            // sub超出的边界
            self.dynamicItem?.center = (self.subScrollView?.contentOffset)!
            target = CGPoint(x: (self.superScrollView?.contentOffset.x)!, y: (self.superScrollView?.zy_maxOffsetY())!)
            action = { [weak self] in
                if ((self?.superScrollView!.contentOffset.y)! < (self?.superScrollView!.zy_maxOffsetY())!) {
                    self?.superScrollView?.contentOffset = (self?.dynamicItem?.center)!
                } else {
                    self?.animator?.removeBehavior((self?.springBehavior)!)
                    self?.springBehavior = nil
                }
            }

        }
        
        let springBehavior = attachBehavior(item: dynamicItem!, anchor: target, action: action)
        animator?.addBehavior(springBehavior)
        self.springBehavior = springBehavior
    }
    
    fileprivate func normalizeOffsetWithoutSuperPull() {
        if subScrollView?.zy_isOffsetYIlleagal() == false || self.springBehavior == nil {
            return
        }
        animator?.removeBehavior(decelerationBehavior!)
        
        var target = subScrollView?.contentOffset
        if subScrollView!.contentOffset.y < subScrollView!.zy_minOffsetY() {
            dynamicItem?.center = (subScrollView?.contentOffset)!
            target?.y = (subScrollView?.zy_minOffsetY())!
        } else if subScrollView!.contentOffset.y < subScrollView!.zy_maxOffsetY() {
            dynamicItem?.center = (subScrollView?.contentOffset)!
            target?.y = (subScrollView?.zy_maxOffsetY())!
        } else {
            // nothing, never going here
        }
        
        let springBehavior = attachBehavior(item: dynamicItem!, anchor: target!) { [weak self] in
            if (self?.subScrollView?.zy_isOffsetYIlleagal())! {
                self?.subScrollView?.contentOffset = (self?.dynamicItem?.center)!
            } else {
                self?.animator?.removeBehavior((self?.springBehavior)!)
                self?.springBehavior = nil
            }
        }
        
        animator?.addBehavior(springBehavior)
        self.springBehavior = springBehavior
    }
    
    fileprivate func attachBehavior(item: Any, anchor: CGPoint, action: @escaping(() -> ())) -> UIAttachmentBehavior {
        let springBehavior = UIAttachmentBehavior.init(item: dynamicItem!, attachedToAnchor: anchor)
        springBehavior.length = 0
        springBehavior.damping = 1
        springBehavior.frequency = 2
        springBehavior.action = action
        return springBehavior
    }
    
    // MARK: UIGestureRecognizerDelegate
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if gestureRecognizer.isKind(of: UIPanGestureRecognizer.classForCoder()) {
            let recognizer = gestureRecognizer as! UIPanGestureRecognizer
            let currentY = recognizer.translation(in: panView).y
            let currentX = recognizer.translation(in: panView).x
            if currentY == 0.0 {
                return true
            } else {
                if fabs(currentX / currentY) >= 5.0 {
                    return true
                } else {
                    return false
                }
            }
        } else {
            return false
        }
    }
    
    func refreshGesture() -> () {
        enableGesture()
        disableGesture()
    }
    
    fileprivate func enableGesture() {
        panGesture?.isEnabled = true
    }
    
    fileprivate func disableGesture() {
        panGesture?.isEnabled = false
        animator?.removeAllBehaviors()
    }
    
    // MARK: ZYScrollPanGestureRecognizerDelegate
    func shouldGesturerBeBlocked(gestureRecognizer: ZYScrollPanGestureRecognizer) -> Bool {
        if gestureRecognizer == panGesture {
            if (animator?.behaviors.count)! > 0 {
                animator?.removeAllBehaviors()
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
}
