//
//  buttonArrow.swift
//  Swiper
//
//  Created by William Thomas on 3/17/19.
//  Copyright © 2019 William Thomas. All rights reserved.
//

import Foundation
import UIKit

/* This buttonArrow class will serve as a UIButton that will
    be drawn in our arrowDisplay view */
class ButtonArrow: UIButton {
    private var currDirection: direction
    private var color: UIColor
    
    // every button arrow has a direction and a color
    init(dir: direction, color: UIColor) {
        self.currDirection = dir
        self.color = color
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // return the current direction of the arrow (LEFT, RIGHT, UP, DOWN, NO-DIRECTION)
    func getDirection() -> direction {
        return currDirection
    }
    
    // return the current color of the arrow (level based)
    func getColor() -> UIColor {
        return color
    }
    
    // TESTING PURPOSES ONLY
    func setDirection(d: direction) {
        currDirection = d
    }
    
    // draw an arrow facing RIGHT in our button
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        
        // draw the arrow using UIBezierPath (we take up 90% of the button)
        path.move(to: CGPoint(x: bounds.minX + (bounds.maxY * 0.1),
                              y: bounds.minY + (bounds.maxX * 0.1)))
        path.addLine(to: CGPoint(x: bounds.maxX - (bounds.maxX * 0.1),
                                 y: bounds.maxY / 2))
        path.addLine(to: CGPoint(x: bounds.minX + (bounds.maxY * 0.1),
                                 y: bounds.maxY - (bounds.maxX * 0.1)))
        
        // set the details and stroke the arrow
        color.setStroke()
        path.lineWidth = 12
        path.lineCapStyle = .round
        path.stroke()
    }
}
