//
//  Message.swift
//  XQGChat
//
//  Created by qiuzijie on 2018/5/23.
//  Copyright © 2018年 qiuzijie. All rights reserved.
//

import UIKit

class Message: NSObject {
    var version: String = "1"
    var packetNo: String = ""
    var senderName: String = ""
    var senderHost: String = ""
    var content: String = ""
    var command: UInt32 = 0
    var date: Int = 0
    var host: String = ""//永远为对方的IP地址
    var isSender = true
    
    public static func makeMessageWith(receivingString str: String) -> Message? {
        let message = Message()
        let splitStr = str.split(separator: ":", maxSplits: 5, omittingEmptySubsequences: false)
        if splitStr.count == 6 {
            message.version    = String(splitStr[0])
            message.packetNo   = String(splitStr[1])
            message.senderName = String(splitStr[2])
            message.senderHost = String(splitStr[3])
            message.command    = UInt32(splitStr[4])!
            message.content    = String(splitStr[5])
            message.date       = Int(NSDate().timeIntervalSince1970)
            message.isSender   = false;
            return message
        }
        return nil
    }
    
    public static func makeMessageWith(command: UInt32, additionalInfo text: String) -> Message? {
        let message = Message()
        message.senderHost = User.default.mode!
        message.senderName = User.default.name!
        message.command = command
        message.date = Int(Date().timeIntervalSince1970)
        message.isSender = true
        switch GET_MODE(command: command) {
        case IPMSG_ANSENTRY,IPMSG_BR_ENTRY:
            message.content = UIDevice.current.name
            break;
        default:
            message.content = text
            break;
        }
        return message
    }
    
    public static func makeMessageWith(receiveFile file: ReceiveFile) -> Message? {
        var str = file.packetID + ":"
        str += String(file.fileID) + ":"
        str += "0"
        let message = Message.makeMessageWith(command: UInt32(IPMSG_GETFILEDATA), additionalInfo: str)
        return message
    }
    
    public static func makeMessageWith(sendFile file: ReceiveFile) -> Message? {
//      "id:photo\(time).png:\(data!.count):mtime:attribute"
        var text = file.fileID + ":"
        text += file.fileName + ":"
        text += String(file.sendData!.count) + ":"
        text += "0:"
        text += "0"
        let message = Message.makeMessageWith(command: UInt32(IPMSG_SENDMSG | IPMSG_FILEATTACHOPT | IPMSG_SENDCHECKOPT), additionalInfo: text)
        return message
    }
    
    func format() -> Data? {
        var str = "1" + ":"
        str += String(Date().timeIntervalSince1970) + ":"
        str += self.senderName + ":"
        str += self.senderHost + ":"
        str += String(self.command) + ":"
        str += self.content
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        return str.data(using: String.Encoding(rawValue: enc))
    }
    
}

struct ReceiveFile {
    var fileID: String
    var packetID: String
    var fileName: String
    var fileSize: Int64
    var fileMtime: Int
    var receiveData: NSMutableData?
    var sendData: Data?
    
    public static func make(withFileMessage message: Message) -> ReceiveFile? {
        let splitStr = message.content.split(separator: ":")
        if splitStr.count > 3 {
            var fileID = String(splitStr[0])
            let range = fileID.startIndex...fileID.index(fileID.startIndex, offsetBy: 0)
            fileID.removeSubrange(range)
            let fileName = String(splitStr[1])
            let fileSize = ReceiveFile.hexTodec(number: String(splitStr[2]))
            if let packetNo = Int(message.packetNo) {
                let packetID = ReceiveFile.decToHex(number: packetNo)
                let file = ReceiveFile(fileID: fileID,
                                       packetID: packetID,
                                       fileName:fileName,
                                       fileSize: fileSize,
                                       fileMtime: Int(splitStr[3])!,
                                       receiveData: nil,
                                       sendData: nil)
                return file
            }
        }
        return nil
    }
    
    
    static func hexTodec(number num:String) -> Int64 {
        let str = num.uppercased()
        var sum = Int64()
        for i in str.utf8 {
            sum = sum * 16 + Int64(i) - 48 // 0-9 从48开始
            if i >= 65 {                 // A-Z 从65开始，但有初始值10，所以应该是减去55
                sum -= 7
            }
        }
        return sum
    }
    
    static func decToHex(number num:Int) -> String {
        return String(num, radix: 16, uppercase: false)
    }
}


















