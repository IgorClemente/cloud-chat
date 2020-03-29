//
//  Circle.swift
//  AWSClmChatApplication
//
//  Created by Igor Clemente on 28/03/20.
//  Copyright © 2020 Igor Clemente. All rights reserved.
//

import Foundation

class Circle : UIView {
    
    @IBOutlet var views: [UIView]?
    
    override func layoutSubviews() {
        self.views?.forEach({ (view) in
            view.clipsToBounds = true
            view.translatesAutoresizingMaskIntoConstraints = true
            view.layer.cornerRadius = view.frame.width * 0.5
        })
    }
}
