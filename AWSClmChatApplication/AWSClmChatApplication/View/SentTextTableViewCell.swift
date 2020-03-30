//
//  SentTextTableViewCell.swift
//  AWSChat
//
//  Created by Abhishek Mishra on 14/04/2017.
//  Copyright © 2017 ASM Technology Ltd. All rights reserved.
//

import UIKit

class SentTextTableViewCell: UITableViewCell {

    @IBOutlet weak var messageTextLabel: UILabel?
    @IBOutlet weak var messageBalloon: Balloon?
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}
