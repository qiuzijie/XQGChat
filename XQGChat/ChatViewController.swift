//
//  ChatViewController.swift
//  XQGChat
//
//  Created by qiuzijie on 2018/5/21.
//  Copyright © 2018年 qiuzijie. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, ConversationDelegate {
    
    public var chatPerson: Client?
    var conversation: Conversation?
    @IBOutlet weak var chatBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.conversation = Conversation.init(client: self.chatPerson!)
        self.conversation?.delegate = self;
        self.conversation?.open()
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 100
        self.tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(info:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(info:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //MARK: - UITextfield
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" && (textField.text != nil){
            self.conversation?.sendMessage(textField.text!)
            textField.text = nil
            return false
        }
        return true
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (conversation?.messages.count)!
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: ChatTextMessageCell?
        let message = conversation?.messages[indexPath.row]
        
        if (message?.isSender)! {
            cell = tableView.dequeueReusableCell(withIdentifier: "ChatCellLeft") as? ChatTextMessageCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "ChatCellRight") as? ChatTextMessageCell
        }
        
        cell?.contentLabel.text = message?.content
        
        if (message?.date) != nil {
            let date = Date.init(timeIntervalSince1970: (message?.date)!)
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            cell?.timeLabel.text = formatter.string(from: date)
        }
        
        return cell!
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        self.view.endEditing(true)
    }
    
    
    
    //MARK: - ConversationDelegate
    func conversation(_ conversation: Conversation, didUpdateMessage message: Message) {
        self.tableView.reloadData()
    }
    
    //MARK: - KeyboardNotification
    @objc func keyboardWillShow(info: Notification) {
        let userInfo = info.userInfo! as NSDictionary
        let keyboardSize = (userInfo.object(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue).cgRectValue.size
        self.chatBarBottomConstraint.constant = keyboardSize.height;
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(info: NSNotification) {
        self.chatBarBottomConstraint.constant = 0;
        UIView.animate(withDuration: 0.25) {
            self.view.layoutIfNeeded()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}
