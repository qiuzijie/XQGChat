//
//  ClientListViewController.swift
//  XQGChat
//
//  Created by qiuzijie on 2018/5/21.
//  Copyright © 2018年 qiuzijie. All rights reserved.
//

import UIKit

class ClientListViewController: UITableViewController {
    
    let socket = SocketViewModel.default

    override func viewDidLoad() {
        super.viewDidLoad()
        socket.userListUpdate = {(users) in
            self.tableView.reloadData()
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return socket.users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell")
        cell?.textLabel?.text = socket.users[indexPath.row].host
        cell?.imageView?.image = UIImage.init(named: "default_face")
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60;
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        vc.chatPerson = socket.users[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
}









