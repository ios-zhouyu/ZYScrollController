//
//  ZYHomeViewController.swift
//  ZYScrollController
//
//  Created by zhouyu on 2018/8/21.
//  Copyright © 2018年 zhouyu. All rights reserved.
//

import UIKit

private let headerHeight: CGFloat = 200

class ZYHomeViewController: ZYBaseViewController, UIScrollViewDelegate {

    var topBarBottom: CGFloat {
        return UIApplication.shared.statusBarFrame.size.height + (navigationController?.navigationBar.bounds.size.height)!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.width.left.top.equalToSuperview()
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.edges.equalToSuperview()
            }
        }
        
        extendedLayoutIncludesOpaqueBars = true
        if #available(iOS 11.0, *) {
            scrollView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        
        scrollView.addSubview(headerView)
        headerView.snp.makeConstraints { (make) in
            make.top.left.right.equalTo(self.view)
            make.height.equalTo(headerHeight)
        }
        
        addChildViewController(activityListController)
        scrollView.addSubview(activityListController.view)
        activityListController.didMove(toParentViewController: self)
        activityListController.view.snp.makeConstraints { (make) in
            make.top.equalTo(headerView.snp.bottom)
            make.left.right.equalTo(self.view)
            make.height.equalTo(UIScreen.main.bounds.height - headerHeight)
        }
        
        self.scrollController = ZYScrollController()
        scrollController.superScrollView = scrollView
        scrollController.subScrollView = activityListController.tableView
        scrollController.superMaxScrollY = headerHeight
        scrollController.superPullDisable = false
        scrollController.setupTouch(self.view)
        activityListController.tableView.isScrollEnabled = false
        activityListController.tableView.panGestureRecognizer.isEnabled = false
        activityListController.scrollDelegate = scrollController
    }
    
    lazy var scrollController: ZYScrollController = {
        let scrollController = ZYScrollController()
        return scrollController
    }()
    
    lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.panGestureRecognizer.isEnabled = false
        scrollView.isScrollEnabled = false
        scrollView.delegate = self
        return scrollView
    }()
    
    lazy var headerView: ZYHomeHeaderView = {
        let headerView = ZYHomeHeaderView()
        return headerView
    }()
    
    lazy var activityListController: ZYActivityListViewController = {
        let activityListController = ZYActivityListViewController()
        return activityListController
    }()

}
