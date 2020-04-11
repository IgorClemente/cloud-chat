//
//  SentTextTableViewCell.swift
//  Cloud Chat
//
//  Created by Igor Clemente on 28/03/20.
//  Copyright © 2020 Igor Clemente. All rights reserved.
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
