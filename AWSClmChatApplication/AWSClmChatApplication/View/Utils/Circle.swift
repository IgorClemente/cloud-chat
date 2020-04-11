//
//  Circle.swift
//  Cloud Chat
//
//  Created by Igor Clemente on 28/03/20.
//  Copyright © 2020 Igor Clemente. All rights reserved.
//

import Foundation

class Circle : UIView {
    
    @IBOutlet var views: [UIView]? {
        didSet {
            self.views?.forEach({ (view) in
                view.clipsToBounds = true
                view.layer.cornerRadius = max(view.frame.width, view.frame.height) * 0.5
            })
        }
    }
}
