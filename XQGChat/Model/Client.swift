//
//  Client.swift
//  XQGChat
//
//  Created by qiuzijie on 2018/4/20.
//  Copyright © 2018年 qiuzijie. All rights reserved.
//

import UIKit

class Client: NSObject {
    var name: String?
    var mode: String?
    var host: String?
    
    public static func make(name: String?, mode: String?, host: String?) -> Client {
        let c = Client()
        c.name = name
        c.host = host
        c.mode = mode
        return c
    }
}
