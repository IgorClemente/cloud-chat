//
//  GenericWithImage.swift
//  AWSClmChatApplication
//
//  Created by Igor Clemente on 28/03/20.
//  Copyright © 2020 Igor Clemente. All rights reserved.
//

import Foundation

protocol SentImageDelegate {
    func uploadImage()
}

class GenericWithImage : UITextField {
    
    @IBInspectable var image: UIImage?
    @IBInspectable var left: Bool = false
    @IBInspectable var right: Bool = false
    
    var sendImageController: SentImageDelegate?
    
    var asideView : UIView? {
        if let image = self.image {
            
            let view = UIView(frame: CGRect(x: 0, y: 0, width: 40, height: 25))
            
            let attachmentButton = UIButton()
            attachmentButton.frame = CGRect(x: 0, y: 0, width: 25, height: 25)
            attachmentButton.setImage(image, for: .normal)
            attachmentButton.contentMode = .scaleAspectFit
            attachmentButton.addTarget(self, action: #selector(tapAttachment), for: .touchUpInside)
            
            view.addSubview(attachmentButton)
            
            return view
        }
        
        return nil
    }
    
    override func draw(_ rect: CGRect) {
        if left && !right {
            guard let asideView = self.asideView else { return }
            
            self.leftView = asideView
            self.leftViewMode = .always
            self.textAlignment = .natural
                    
            return
        }
            
        if right && !left {
            guard let asideView = self.asideView else { return }
                
            self.rightView = asideView
            self.rightViewMode = .always
            self.textAlignment = .natural
                        
            return
        }
    }
    
    @objc func tapAttachment() {
        sendImageController?.uploadImage()
    }
}
