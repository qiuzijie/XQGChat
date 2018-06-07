//
//  ChatViewController.swift
//  XQGChat
//
//  Created by qiuzijie on 2018/5/21.
//  Copyright © 2018年 qiuzijie. All rights reserved.
//

import UIKit

class ChatViewController:
    UIViewController,
    UITableViewDelegate,
    UITableViewDataSource,
    UITextFieldDelegate,
    ConversationDelegate,
    UIImagePickerControllerDelegate,
    UINavigationControllerDelegate {
    
    public var conversation: Conversation!
    @IBOutlet weak var chatBarBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var tableView: UITableView!
    
//    required init?(coder aDecoder: NSCoder) {
//        fatalError("init(coder:) has not been implemented")
//    }
//    
//    init(with conversation: Conversation) {
//        self.conversation = conversation
//        super.init(nibName: nil, bundle: nil)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if conversation != nil {
            title = conversation.client?.name
            conversation.delegate = self
        } else {
            fatalError("ChatViewController Need Conversation Before ViewDidLoad")
        }
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(info:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(info:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //MARK: - Action
    @IBAction func didTapPhotoButton(_ sender: UIButton) {
        let picker = UIImagePickerController()
        picker.sourceType = .photoLibrary
        picker.delegate = self;
        self.navigationController?.present(picker, animated: true, completion: nil)
    }
    
    //MARK: - UITextfieldDelegate
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string == "\n" && (textField.text != nil){
            self.conversation.sendTextMessage(textField.text!)
            textField.text = nil
            return false
        }
        return true
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversation.messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell: ChatTextMessageCell?
        let message = conversation.messages[indexPath.row]
        
        if message.isSender {
            cell = tableView.dequeueReusableCell(withIdentifier: "ChatCellRight") as? ChatTextMessageCell
        } else {
            cell = tableView.dequeueReusableCell(withIdentifier: "ChatCellLeft") as? ChatTextMessageCell
        }
        
        cell?.contentLabel.text = message.content
        
        if message.date > 0{
            let date = Date.init(timeIntervalSince1970: TimeInterval(message.date))
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
        tableView.reloadData()
    }
    
    //MARK: -UIImagePickerControllerDelegate
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        picker.dismiss(animated: true, completion: nil)
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        //发送图片文件
        self.conversation.sendImage(image)
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
