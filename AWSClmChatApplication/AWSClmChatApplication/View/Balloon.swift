//
//  Balloon.swift
//  AWSClmChatApplication
//
//  Created by Igor Clemente on 27/03/20.
//  Copyright © 2020 Igor Clemente. All rights reserved.
//

import Foundation

class Balloon: UIView {
    
    var leftArrow:Bool = true {
        didSet{ setNeedsDisplay() }
    }
    
    var color:UIColor? {
        didSet{ setNeedsDisplay() }
    }

    override func didMoveToSuperview() {
        self.backgroundColor = UIColor.clear
        self.clipsToBounds = true
    }
    
    override func draw(_ rect: CGRect) {
        
        (self.color ?? UIColor.gray).setFill()
        
        var bubbleRect:CGRect = rect
        bubbleRect.size.height = rect.height - 5
        
        let frufru = UIBezierPath(roundedRect: bubbleRect, cornerRadius: 5.0)
        
        if leftArrow {
            
            let size:CGFloat = 20.0
            let bot:CGFloat  = frame.maxY - 10
            
            frufru.move(to: CGPoint(x: 0, y: bot))
            
            frufru.addCurve(to: CGPoint(x: size/2, y: bot-size),
                            controlPoint1: CGPoint(x:size/2, y:bot-size/3),
                            controlPoint2: CGPoint(x:size/2, y:bot-(size/3)*2))
            
            frufru.addLine(to: CGPoint(x: size, y: bot-size))

            frufru.addCurve(to: CGPoint(x: 0, y: bot),
                            controlPoint1: CGPoint(x:size, y:bot-size/3),
                            controlPoint2: CGPoint(x:size/2, y:bot))
        }
        
        frufru.fill()
        
    }
    
    func changeColor(withSeed seed: Int){
        let random = CGFloat(seed % 10) / 10.0
        
        self.color = UIColor.init(hue: random, saturation: 0.9,
                                  brightness: 0.9, alpha: 1.0);
        setNeedsDisplay()
    }

}
