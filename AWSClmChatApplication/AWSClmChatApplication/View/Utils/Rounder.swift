//
//  Rounder.swift
//  AWSClmChatApplication
//
//  Created by Igor Clemente on 26/03/20.
//  Copyright © 2020 Igor Clemente. All rights reserved.
//

import Foundation

class Rounder : UIView {
    
    @IBInspectable var raddi: CGFloat = 10.0
    
    @IBInspectable var top: Bool = false
    @IBInspectable var bottom: Bool = false
    @IBInspectable var both: Bool = false
    
    override func layoutSubviews() {
        if both {
            self.roundCorners([.allCorners], radius: raddi)
            return
        }
        
        if top {
            self.roundCorners([.topLeft, .topRight], radius: raddi)
            return
        }
        
        self.roundCorners([.bottomLeft, .bottomRight], radius: raddi)
    }
}
