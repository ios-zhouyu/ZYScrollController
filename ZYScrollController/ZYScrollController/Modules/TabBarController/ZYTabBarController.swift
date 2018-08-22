//
//  ZYTabBarController.swift
//  ZYScrollController
//
//  Created by zhouyu on 2018/8/21.
//  Copyright © 2018年 zhouyu. All rights reserved.
//

import UIKit

private let NorIconName = "NorIconName"        // 普通图片名称
private let SelIconName = "SelIconName"        // 选中图片名称
private let TabbarTitle = "TabbarTitle"       // 标题
private let RootVcName = "RootVcName"        // 控制器的名称字符串

class ZYTabBarController: UITabBarController {
    
    var childrenControllersArr: [NSDictionary]? {
        get {
            return NSArray.init(contentsOfFile: Bundle.main.path(forResource: "TabBarChildrenControllers.plist", ofType: nil)!) as? [NSDictionary]
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        setupChildControllers()
        
        tabBar.tintColor = UIColor.black
        selectedIndex = 0
    }

    private func setupChildControllers() {
        var temp = [UIViewController]()
        for item in childrenControllersArr! {
            let childrenControllerString: String = item[RootVcName] as! String
            let nameSpace = Bundle.main.infoDictionary!["CFBundleExecutable"] as! String
            let childrenControllerClass = NSClassFromString(nameSpace + "." + childrenControllerString)
            let childrenControllerType = childrenControllerClass as! UIViewController.Type
            let childrenController = childrenControllerType.init()
            
            childrenController.view.backgroundColor = UIColor.white
            childrenController.title = item[TabbarTitle] as? String
            childrenController.tabBarItem.image = UIImage.init(named: item[NorIconName] as! String)?.withRenderingMode(.alwaysOriginal)
            childrenController.tabBarItem.selectedImage = UIImage.init(named: item[SelIconName] as! String)?.withRenderingMode(.alwaysOriginal)
            
            let nav = ZYNavigationController.init(rootViewController: childrenController)
            temp.append(nav)
        }
        viewControllers = temp
    }
}
