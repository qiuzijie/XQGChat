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
    var conversationId: String{
        return (client?.host ?? "")
    }
    var client: Client?
    var delegate: ConversationDelegate?
    let socket = SocketViewModel.default
    var messages = [Message]()
    
    init(client: Client) {
        super.init()
        self.socket.delegate = self
        self.client = client
    }
    
    func sendTextMessage(_ text: String) {
        if self.client?.host != nil {
            let msg = Message.makeMessageWith(command: UInt32(IPMSG_SENDMSG), additionalInfo: text)
            if msg != nil {
                socket.sendMessage(msg!, toClient: (self.client?.host)!)
            }
        } else {
            socket.appendErrorMessage("Send Error | client host nil")
        }
    }
    
    func sendImage(_ image: UIImage) {
        if self.client?.host != nil {
            var data = UIImagePNGRepresentation(image)
            if data == nil {
                data = UIImageJPEGRepresentation(image, 0.5)
            }
            let time = UInt(Date().timeIntervalSince1970)
            if data != nil {
                let sendFile = ReceiveFile.init(fileID: "0", packetID: "", fileName: "photo\(time).png", fileSize: Int64(data!.count), fileMtime: 0, receiveData: nil, sendData: data!)
//                let text = "\0:photo\(time).png:\(data!.count):0:0"
                let imageMsg = Message.makeMessageWith(sendFile: sendFile)
                if imageMsg != nil {
                    socket.sendMessage(imageMsg!, toClient: (self.client?.host)!)
                }
            }
        } else {
            socket.appendErrorMessage("Send Error | client host nil")
        }
    }
    
    func updateMessage(_ message: Message) {
        self.messages.append(message)
        self.delegate?.conversation(self, didUpdateMessage: message)
    }
}










