//
//  ConversationListViewController.swift
//  XQGChat
//
//  Created by qiuzijie on 2018/6/7.
//  Copyright © 2018 qiuzijie. All rights reserved.
//

import UIKit

class ConversationListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var tableView: UITableView!
    let socket = SocketViewModel.default
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(conversationListUpdated), name: .SocketConversationListUpdateNotification, object: nil)
        tableView.tableFooterView = UIView()
    }
    
    //MARK: - UITableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return socket.conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConversationCell")
        let conversation = socket.conversations[indexPath.row]
        cell?.textLabel?.text = conversation.client?.name
        if conversation.messages.count > 0 {
            cell?.detailTextLabel?.text = conversation.messages.last?.content
        }
        cell?.imageView?.image = UIImage.init(named: "default_face")
        return cell!
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let vc = self.storyboard?.instantiateViewController(withIdentifier: "ChatViewController") as! ChatViewController
        vc.conversation = socket.conversations[indexPath.row]
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - PrivateFunc
    @objc func conversationListUpdated() {
        tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
