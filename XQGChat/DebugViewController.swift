//
//  DebugViewController.swift
//  XQGChat
//
//  Created by qiuzijie on 2018/3/30.
//  Copyright © 2018年 qiuzijie. All rights reserved.
//

import UIKit

class DebugViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITabBarDelegate {

    let viewModel = SocketViewModel.default
    
    @IBOutlet weak var usersTableView: UITableView!

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configView()
        self.viewModel.sendLinkRequest()
        NotificationCenter.default.addObserver(self, selector: #selector(socketViewModelMessagesUpdate), name: Notification.Name.SocketViewModelDebugLogUpdateNotification, object: nil)
    }
    
    //MARK: - ConfigVIiew
    func configView() {
        if #available(iOS 11.0, *) {
            self.navigationController?.navigationBar.prefersLargeTitles = true
        }
//        self.usersTableView.register(UITableViewCell.classForCoder(), forCellReuseIdentifier: "DebugCell")
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DebugCell")
        cell?.textLabel?.text = self.viewModel.messages[indexPath.row]
        cell?.textLabel?.adjustsFontSizeToFitWidth = true
        cell?.textLabel?.minimumScaleFactor = 0.5
        return cell!
    }
    
    //MARK: - Notification
    @objc func socketViewModelMessagesUpdate() {
        self.usersTableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
