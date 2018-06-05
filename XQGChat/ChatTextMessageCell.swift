//
//  ChatTextMessageCell.swift
//  XQGChat
//
//  Created by qiuzijie on 2018/5/24.
//  Copyright © 2018年 qiuzijie. All rights reserved.
//

import UIKit

class ChatTextMessageCell: UITableViewCell {

    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
