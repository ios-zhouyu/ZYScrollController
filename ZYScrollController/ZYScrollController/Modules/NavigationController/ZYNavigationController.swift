//
//  ZYNavigationController.swift
//  ZYScrollController
//
//  Created by zhouyu on 2018/8/21.
//  Copyright © 2018年 zhouyu. All rights reserved.
//

import UIKit

class ZYNavigationController: UINavigationController {

    override func viewDidLoad() {
        super.viewDidLoad()

        
    }

}

extension ZYNavigationController{
    override internal func pushViewController(_ viewController: UIViewController, animated: Bool) {
        if viewControllers.count > 0 {
            viewController.hidesBottomBarWhenPushed = true
            viewController.view.backgroundColor = UIColor.white
        }
        super.pushViewController(viewController, animated: animated)
    }
}
