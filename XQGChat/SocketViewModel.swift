//
//  SocketViewModel.swift
//  XQGChat
//
//  Created by qiuzijie on 2018/3/30.
//  Copyright © 2018年 qiuzijie. All rights reserved.
//

import UIKit
import CocoaAsyncSocket

protocol SocketViewModelDelegate {
    func socketViewModel(_ socket: SocketViewModel, didReceiveMessage message: Message)
}

extension SocketViewModelDelegate {
    func socketViewModel(_ socket: SocketViewModel, didReceiveMessage message: Message){
        
    }
}

extension Notification.Name {
    static let SocketViewModelDebugLogUpdateNotification = Notification.Name("SocketViewModelDebugLogUpdateNotification")
}

class SocketViewModel: NSObject, GCDAsyncUdpSocketDelegate {
    
    static let `default` = SocketViewModel()
    
    let port: UInt16 = 2425
    var localHost: String? {
        return self.broadcastSocket.localHost()
    }
    var delegate: SocketViewModelDelegate?
    var userListUpdate: (([Client]) -> Void)?
    
    lazy var broadcastSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
    lazy var messages = [String]()
    lazy var users = [Client]()
    var lineClientCompletionHandler: (() -> Void)?
    
    override init() {
        super.init()
        do {
            try broadcastSocket.bind(toPort: port)
        } catch {
            self.appendErrorMessage("bind error")
        }
        
        do {
            try broadcastSocket.beginReceiving()
        } catch {
            self.appendErrorMessage("beginReceiving error")
        }
        
        do {
            try broadcastSocket.enableBroadcast(true)
        } catch {
            self.appendErrorMessage("enableBroadcast error")
        }
    }
    
    //MARK: - SendBroadcast
    func sendLinkRequest() {
        let linkMsg = "3.0:\(NSDate().timeIntervalSince1970):Qiu2:Qiu2:\(IPMSG_BR_ENTRY|IPMSG_UTF8OPT):iPhone8,1\0iPhone8,1"
        let data = linkMsg.data(using: .utf8)
        if data != nil {
            broadcastSocket.send(data!, toHost: "255.255.255.255", port: port, withTimeout: -1, tag: 1)
        }
    }
    
    func replyLinkRequest(_ host: String) {
        self.appendLogMessage("Reply Entry To:" + host)
        let replyMsg = "3.0:\(NSDate().timeIntervalSince1970):Qiu2:Qiu2:\(IPMSG_ANSENTRY|IPMSG_UTF8OPT):iPhone8,1\0iPhone8,1"
        let data = replyMsg.data(using: .utf8)
        if data != nil {
            broadcastSocket.send(data!, toHost: host, port: port, withTimeout: -1, tag: 2)
        }
    }
    
    //MARK: - Chat
    
    public func linkClient(_ client:Client, completionHandler: @escaping () -> Void) {
        
        do {
            try self.broadcastSocket.connect(toHost: client.host, onPort: port)
        } catch {
            self.appendErrorMessage("Link Error | Client:\(client.host)")
            self.appendLogMessage("Link Error | \(error.localizedDescription)")
        }

        self.lineClientCompletionHandler = completionHandler
    }
    
    public func sendMessage(_ message:Message, toClient host:String){
//        message.time = Date().timeIntervalSince1970
//        let data = message.formatToJsonData()
//        if data != nil {
//            self.broadcastSocket.send(data!, toHost: host, port: port, withTimeout: -1, tag: 3)
//        } else {
//            self.appendErrorMessage("Send Error | Nil Data")
//        }
    }
    
    //MARK: - GCDAsyncUdpSocketDelegate
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        self.appendLogMessage("已经发送消息 tag: \(String(tag))")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        let host = GCDAsyncUdpSocket.host(fromAddress: address) ?? ""
        let port = GCDAsyncUdpSocket.port(fromAddress: address)
        
        
        let string = String.init(data: data, encoding: .utf8)
        if string != nil {
            let message = Message.receiveMessageWith(originalString: string!)
            if message != nil {
                message!.host = host
                switch GET_MODE(command: (message?.command)!) {
                case IPMSG_BR_ENTRY:
                    self.appendLogMessage("receive Entry :" + host)
                    self.replyLinkRequest(host)
                    break
                default:
                    break
                }
            }
        }
        print("host：" + host)
        print("port：" + String(port))
    }
    
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotConnect error: Error?) {
        self.appendErrorMessage("Connect Failed")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didConnectToAddress address: Data) {
        self.appendLogMessage("Connect Success | " + GCDAsyncUdpSocket.host(fromAddress: address)!)
    }
    
    func udpSocketDidClose(_ sock: GCDAsyncUdpSocket, withError error: Error?) {
        self.appendErrorMessage((error?.localizedDescription)! + error.debugDescription)
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didNotSendDataWithTag tag: Int, dueToError error: Error?) {
        self.appendErrorMessage("Send Failed | Tag : \(tag)")
    }
    
    
    //MARK: - PrivateFunc
    
    private func appendLogMessage(_ message: String){
        print("Log:  \(message)")
        self.messages.append(message)
        NotificationCenter.default.post(name: NSNotification.Name.SocketViewModelDebugLogUpdateNotification, object: nil)
    }
    
    public func appendErrorMessage(_ message: String){
        self.appendLogMessage("❗️Error \(message)")
    }
    
    private func addNewUser(user: Client){
        let results = self.users.filter { (u) -> Bool in
            return (u.host == user.host)
        }
        if results.count == 0 {
            self.replyLinkRequest(user.host)
            self.users.append(user)
            if self.userListUpdate != nil {
                self.userListUpdate!(self.users)
            }
        }
    }
    
}






