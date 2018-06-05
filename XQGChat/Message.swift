//
//  Message.swift
//  XQGChat
//
//  Created by qiuzijie on 2018/5/23.
//  Copyright © 2018年 qiuzijie. All rights reserved.
//

import UIKit

class Message: NSObject {
    var version: String?
    var packetNo: String?
    var senderName: String?
    var senderHost: String?
    var content: String?
    var command: UInt32?
    var date: TimeInterval?
    var host: String?
    var isSender : Bool {
        return (senderHost == SocketViewModel.default.localHost)
    }
    
    public static func receiveMessageWith(originalString str: String) -> Message? {
        let message = Message()
        let splitStr = str.split(separator: ":")
        if splitStr.count == 6 {
            message.version    = String(splitStr[0])
            message.packetNo   = String(splitStr[1])
            message.senderName = String(splitStr[2])
            message.senderHost = String(splitStr[3])
            message.command    = UInt32(splitStr[4])
            message.content    = String(splitStr[5])
            message.date       = NSDate().timeIntervalSince1970
            return message
        }
        return nil
    }
    
    public static func sendMessageWith(command: UInt32) -> Message? {
        return nil
    }
    
}
