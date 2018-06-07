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
    
}

extension SocketViewModelDelegate {

}

extension Notification.Name {
    static let SocketDebugLogUpdateNotification = Notification.Name("socketDebugLogUpdateNotification")
    static let SocketConversationListUpdateNotification = Notification.Name("socketConversationListUpdateNotification")
}

class SocketViewModel: NSObject, GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate {
    
    static let `default` = SocketViewModel()
    
    let port: UInt16 = 2425
    var localHost: String? {
        return self.broadcastSocket.localHost()
    }
    var delegate: SocketViewModelDelegate?
    var userListUpdate: (([Client]) -> Void)?
    
    lazy var broadcastSocket = GCDAsyncUdpSocket(delegate: self, delegateQueue: DispatchQueue.main)
    
    lazy var logs = [String]()
    lazy var users = [Client]()
    lazy var conversations = [Conversation]()
    lazy var sockets = [GCDAsyncSocket]()
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
    
    //MARK: - UDP
    func sendEntryRequest() {
        let data = Message.makeMessageWith(command: UInt32(IPMSG_BR_ENTRY), additionalInfo: "")?.format()
        if data != nil {
            broadcastSocket.send(data!, toHost: "255.255.255.255", port: port, withTimeout: -1, tag: 1)
        }
    }
    
    func replyEntryRequest(_ host: String) {
        self.appendLogMessage("Reply Entry To:" + host)
        let data = Message.makeMessageWith(command: UInt32(IPMSG_ANSENTRY), additionalInfo: "")?.format()
        if data != nil {
            broadcastSocket.send(data!, toHost: host, port: port, withTimeout: -1, tag: 2)
        }
    }
    
    func replyReceiveMsg(_ host: String, packetNo: String) {
        let data = Message.makeMessageWith(command: UInt32(IPMSG_RECVMSG), additionalInfo: packetNo)?.format()
        if data != nil {
            broadcastSocket.send(data!, toHost: host, port: port, withTimeout: -1, tag: 3)
        }
    }

    
    public func sendMessage(_ message:Message, toClient host:String){
        message.host = host
        self.broadcastSocket.send((message.format())!, toHost: host, port: port, withTimeout: -1, tag: 4)
        self.updateConversations(ByMessage: message)
        
        let opt = (GET_OPT(command: message.command) & IPMSG_FILEATTACHOPT)
        if opt == IPMSG_FILEATTACHOPT {
            self.accept()
        }
    }
    
    //MARK: - GCDAsyncUdpSocketDelegate
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didSendDataWithTag tag: Int) {
        self.appendLogMessage("已经发送消息 tag: \(String(tag))")
    }
    
    func udpSocket(_ sock: GCDAsyncUdpSocket, didReceive data: Data, fromAddress address: Data, withFilterContext filterContext: Any?) {
        
        let host = GCDAsyncUdpSocket.host(fromAddress: address) ?? ""
        let port = GCDAsyncUdpSocket.port(fromAddress: address)
        
        if host.hasPrefix("::ffff:") {return}
        
//        var originalString = String.init(data: data, encoding: .utf8)
        let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
        let originalString = String.init(data: data, encoding: String.Encoding(rawValue: enc))
        
        if originalString != nil {
            self.appendLogMessage("receive : " + originalString!)
            let message = Message.makeMessageWith(receivingString: originalString!)

            if message != nil {
                message!.host = host
                let command = (message?.command)!
                
                switch GET_MODE(command: command) {//
                case IPMSG_BR_ENTRY:
                    self.replyReceiveMsg(host, packetNo: (message?.packetNo)!)
                    self.replyEntryRequest(host)
                    self.addNewUser(user: Client.make(name: message?.senderName, mode:message?.senderHost, host: host))
                    break
                case IPMSG_ANSENTRY:
                    self.addNewUser(user: Client.make(name: message?.senderName, mode:message?.senderHost, host: host))
                    break;
                case IPMSG_SENDMSG:
                    if GET_OPT(command: command) == IPMSG_SENDCHECKOPT {
//                        self.replyReceiveMsg(host, packetNo: (message?.packetNo)!)
                    }
                    self.updateConversations(ByMessage: message!)
                    break;
                case IPMSG_RECVMSG:
                    
                    break;
                default:
                    break
                }
                let opt = (GET_OPT(command: command) & IPMSG_FILEATTACHOPT)
                if opt == IPMSG_FILEATTACHOPT {
                    if let file = ReceiveFile.make(withFileMessage: message!) {
                        self.connect(toHost: host, withFile: file)
                    }
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
    
    //MARK: - TCP
    
    func accept() {
        let server = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main);
        
        do {
            try server.accept(onPort: port)
            sockets.append(server)
        } catch {
            self.appendErrorMessage("accept error")
        }
    }
    
    func connect(toHost host: String, withFile file: ReceiveFile) {
        let socket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.main)
        socket.userData = ["type":"ReceiveFile","file":file]
        do {
            try socket.connect(toHost: host, onPort: port)
        } catch {
            self.appendErrorMessage("connectServer:\(host) Error ")
        }
    }
    
    //MARK: - GCDAsyncSocketDelegate
//    func newSocketQueueForConnection(fromAddress address: Data, on sock: GCDAsyncSocket) -> DispatchQueue? {
//
//    }
    
    func socket(_ sock: GCDAsyncSocket, didAcceptNewSocket newSocket: GCDAsyncSocket) {
        newSocket.readData(withTimeout: -1, tag: 101)
        newSocket.userData = ["type":"SendFile",]
        self.sockets.append(newSocket)
    }
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        sockets.append(sock)
        sock.readData(withTimeout: -1, tag: 100)
        if let userData = sock.userData as? Dictionary<String, Any> {
            if (userData["type"] as! String) == "ReceiveFile" {
                if let file = userData["file"] as? ReceiveFile {
                    let msg = Message.makeMessageWith(receiveFile: file)
                    let data = msg?.format()
                    if data != nil {
                        sock.write(data!, withTimeout: -1, tag: 10)
                    }
                }
            }
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        sock.readData(withTimeout: -1, tag: 100)
        if var userData = sock.userData as? Dictionary<String, Any> {
            let type = userData["type"] as! String
            if type == "ReceiveFile" {
                if var file = userData["file"] as? ReceiveFile {
                    if file.receiveData == nil {
                        file.receiveData = NSMutableData()
                    }
                    file.receiveData?.append(data)
                    let size = file.receiveData?.length
                    userData["file"] = file
                    sock.userData = userData
                    if Int(file.fileSize) == size {
                        let image = UIImage.init(data: file.receiveData! as Data)
                        print("接收完成！！！！ ")
                    }
                }
            } else if type == "SendFile" {
                let enc = CFStringConvertEncodingToNSStringEncoding(CFStringEncoding(CFStringEncodings.GB_18030_2000.rawValue))
                let originalString = String.init(data: data, encoding: String.Encoding(rawValue: enc))
                
                
            }
        }
    }
    
    func socket(_ sock: GCDAsyncSocket, didReadPartialDataOfLength partialLength: UInt, tag: Int) {
        
    }
    
    func socket(_ sock: GCDAsyncSocket, shouldTimeoutReadWithTag tag: Int, elapsed: TimeInterval, bytesDone length: UInt) -> TimeInterval {
        return -1
    }
    
    func socket(_ sock: GCDAsyncSocket, didWriteDataWithTag tag: Int) {
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didReceive trust: SecTrust, completionHandler: @escaping (Bool) -> Void) {
        
    }
    
    func socket(_ sock: GCDAsyncSocket, didWritePartialDataOfLength partialLength: UInt, tag: Int) {
        
    }
    
    func socketDidCloseReadStream(_ sock: GCDAsyncSocket) {
        
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
//        sockets.remove(at: sockets.index(of: sock)!)
    }
    
    //MARK: - PublicFunc
    
    public func appendErrorMessage(_ message: String){
        self.appendLogMessage("❗️Error \(message)")
    }
    
    //MARK: - PrivateFunc
    
    private func appendLogMessage(_ message: String){
        print("Log:  \(message)")
        self.logs.append(message)
        NotificationCenter.default.post(name: NSNotification.Name.SocketDebugLogUpdateNotification, object: nil)
    }
    
    private func addNewUser(user: Client){
        let results = self.users.filter { (u) -> Bool in
            return (u.host == user.host)
        }
        if results.count == 0 {
            self.users.append(user)
            if self.userListUpdate != nil {
                self.userListUpdate!(self.users)
            }
        }
    }
    
    private func updateConversations(ByMessage msg: Message) {
        //
        let client = Client.make(name: msg.senderName, mode: msg.senderHost, host: msg.host)
        let conversation = self.conversation(ByClient: client)
        conversation.updateMessage(msg)
        NotificationCenter.default.post(name: .SocketConversationListUpdateNotification, object: nil)
    }
    
    public func updateConversations(ByClient client: Client) -> Conversation {
        let conversation = self.conversation(ByClient: client)
        NotificationCenter.default.post(name: .SocketConversationListUpdateNotification, object: nil)
        return conversation
    }
    
    private func conversation(ByClient client: Client) -> Conversation{
        for c in conversations {
            if c.conversationId == client.host {
                conversations.remove(at: conversations.index(of: c)!)
                conversations.insert(c, at: 0)
                return c
            }
        }
        let newConversation = Conversation(client: client)
        conversations.append(newConversation)
        return newConversation
    }
    
}






