//
//  LoginTextField.swift
//  AWSClmChatApplication
//
//  Created by Igor Clemente on 26/03/20.
//  Copyright © 2020 Igor Clemente. All rights reserved.
//

import Foundation
import UIKit


class LoginTextField : UITextField {
    
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets.init(top: 0, left: 2.0, bottom: 5.0, right: 5.0))
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: UIEdgeInsets.init(top: 0, left: 2.0, bottom: 5.0, right: 5.0))
    }
    
    override func layoutSubviews() {
        
        super.layoutSubviews()
        
        self.clearsContextBeforeDrawing = true
        
        self.borderStyle = .none
        
        let defaultTint: UIColor = UIColor.white
        let defaultColor: UIColor = UIColor.white
        let defaultColorPlaceholder: UIColor = UIColor(red: 0.867, green: 0.867, blue: 0.867, alpha: 1)
        
        let borderWidth: CGFloat = 1.0
        
        let defaultFont: UIFont = UIFont(name: "Roboto-Medium", size: 15) ?? UIFont()

        if let placeholderText = self.placeholder {
            let attributesDictionary: [NSAttributedString.Key : Any] = [.foregroundColor : defaultColorPlaceholder]
            
            let attributes: NSAttributedString = NSAttributedString(string: placeholderText, attributes: attributesDictionary)
            
            self.attributedPlaceholder = attributes
        }
        
        let border = CALayer()
        border.backgroundColor = defaultColor.cgColor
        border.frame = CGRect(x: 0, y: (frame.height - borderWidth),
                              width: frame.size.width, height: frame.size.height)
        
        self.tintColor = defaultTint
        self.textColor = defaultTint
        
        self.layer.addSublayer(border)
        self.layer.masksToBounds = true
    }
}


