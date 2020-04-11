//
//  Button.swift
//  Cloud Chat
//
//  Created by Igor Clemente on 25/03/20.
//  Copyright © 2020 Igor Clemente. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class RoundedButton : NSObject {
    
    @IBInspectable var radi: CGFloat = 5.0
    
    @IBOutlet var views: [UIView] = [] {
        didSet {
            self.views.forEach { (view) in
                view.layer.cornerRadius = radi
            }
        }
    }
}
