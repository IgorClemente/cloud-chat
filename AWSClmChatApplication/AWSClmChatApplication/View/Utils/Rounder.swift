//
//  Rounder.swift
//  AWSClmChatApplication
//
//  Created by Igor Clemente on 26/03/20.
//  Copyright © 2020 Igor Clemente. All rights reserved.
//

import Foundation

class Rounder : UIView {
    
    override func layoutSubviews() {
        self.roundCorners([.topLeft, .topRight], radius: 20.0)
    }
}
