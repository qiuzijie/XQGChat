//
//  Conversation.swift
//  XQGChat
//
//  Created by qiuzijie on 2018/5/22.
//  Copyright © 2018年 qiuzijie. All rights reserved.
//

import UIKit

protocol ConversationDelegate {
    func conversation(_ conversation: Conversation, didUpdateMessage message: Message)
}

class Conversation: NSObject, SocketViewModelDelegate {
    var client: Client?
    var delegate: ConversationDelegate?
    let socket = SocketViewModel.default
    var messages = [Message]()
    
    init(client: Client) {
        super.init()
        self.socket.delegate = self
        self.client = client
    }
    
    func open(){
        
    }
    
    func sendMessage(_ text: String) {
//        let message = Message.make(text: text, type: .text)
//        message.senderID = self.socket.localHost
//        if self.client?.host != nil {
//            socket.sendMessage(message, toClient: (self.client?.host)!)
//            self.updateMessage(message)
//        } else {
//            socket.appendErrorMessage("Send Error | client host nil")
//        }
    }
    
    func socketViewModel(_ socket: SocketViewModel, didReceiveMessage message: Message) {
        self.updateMessage(message)
    }
    
    func updateMessage(_ message: Message) {
        self.messages.append(message)
        self.delegate?.conversation(self, didUpdateMessage: message)
    }
}
