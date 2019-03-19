//
//  arrowDisplay.swift
//  Swiper
//
//  Created by William Thomas on 3/17/19.
//  Copyright © 2019 William Thomas. All rights reserved.
//

import UIKit

class arrowDisplay: UIView {
    
    /* super function */
    override func layoutSubviews() {
        
        // turn our subviews into buttonArrows
        layoutButtonArrows(bArrows: subviews.map {$0 as! ButtonArrow})
    }

    /* handle the frame position and animation of our arrows */
    func layoutButtonArrows(bArrows: [ButtonArrow]) {
        let arrow = bArrows[0]
        
        // rotate the button accordingly. (UP means the arrow faces up etc.)
        switch arrow.getDirection() {
            case direction.LEFT:
                arrow.transform = arrow.transform.rotated(by: CGFloat(Double.pi / 2))
            case direction.UP:
                arrow.transform = arrow.transform.rotated(by: CGFloat(Double.pi / 2))
            case direction.DOWN:
                arrow.transform = arrow.transform.rotated(by: CGFloat(Double.pi / 2))
            default: break
        }
        
        let top = bounds.maxY / 3
//        let bottom = (2 / 3) * bounds.maxY
//        let middle = ((bounds.maxY / 3) * (1/2)) + (bounds.maxY / 3)
        let arrowSize = bounds.maxX / 5
        
        // set the frame for the button
        let fromHere = CGRect(x: 0, y: top, width: arrowSize, height: top)
        arrow.frame = fromHere
        
        // we will send the arrow to here (other side of the display)
        let toHere = CGRect(x: bounds.maxX, y: top, width: arrowSize, height: top)
        
        // transition the button across the screen
        UIView.transition(with: UIView(frame: fromHere), duration: 5, options: UIView.AnimationOptions.curveLinear, animations: {
            arrow.frame = toHere
        }, completion: nil)
    }
}
