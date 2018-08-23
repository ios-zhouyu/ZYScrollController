
//
//  ZYActivityListViewController.swift
//  ZYScrollController
//
//  Created by zhouyu on 2018/8/23.
//  Copyright © 2018年 zhouyu. All rights reserved.
//

import UIKit

private let ActivityListCell = "ActivityListCell"

class ZYActivityListViewController: ZYBaseViewController, UITableViewDelegate, UITableViewDataSource {
    
    weak var scrollDelegate: ZYScrollController?

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            if #available(iOS 11.0, *) {
                make.bottom.equalTo(self.view.safeAreaLayoutGuide.snp.bottom)
            } else {
                make.bottom.equalToSuperview()
            }
            make.top.left.width.equalToSuperview()
        }
        
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            self.automaticallyAdjustsScrollViewInsets = false
        }
        
    }
    
    

    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: ActivityListCell)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200.0
        tableView.tableFooterView = UIView()
        tableView.tableHeaderView = UIView()
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.showsHorizontalScrollIndicator = false
        tableView.backgroundColor = UIColor.white
        return tableView
    }()
}

extension ZYActivityListViewController {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 20
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ActivityListCell, for: indexPath)
        cell.textLabel?.text = "\(indexPath)" + "\(arc4random_uniform(1000))"
        cell.selectionStyle = .none
        return cell
    }
}
