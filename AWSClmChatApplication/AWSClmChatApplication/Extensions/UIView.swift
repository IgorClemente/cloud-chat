//
//  UIView.swift
//  AWSClmChatApplication
//
//  Created by Igor Clemente on 26/03/20.
//  Copyright © 2020 Igor Clemente. All rights reserved.
//

import Foundation
import UIKit

extension UIView {
    
    func roundCorners(_ corners: UIRectCorner, radius: CGFloat) {
        
        let path = UIBezierPath(roundedRect: self.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))

        let maskLayer = CAShapeLayer()
        maskLayer.path = path.cgPath
        
        self.layer.mask = maskLayer
    }
}
