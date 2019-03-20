//
//  arrowDisplay.swift
//  Swiper
//
//  Created by William Thomas on 3/17/19.
//  Copyright © 2019 William Thomas. All rights reserved.
//

import UIKit

/* display and animate the arrows on screen in the proper
    direction (right, left, up down) */
class arrowDisplay: UIView {
    private var swipedInTime = false
    
    override func layoutSubviews() {
        // turn our subviews into buttonArrows
        layoutButtonArrows(bArrows: subviews.map {$0 as! ButtonArrow})
    }

    // handle the frame position and animation of our arrows
    func layoutButtonArrows(bArrows: [ButtonArrow]) {
        if(bArrows.isEmpty) { return }
        let arrow = bArrows[0]
        let buttonSide = bounds.maxX / 5
        var modifier = speedModifier(color: arrow.getColor())
        
        modifier = 1
        let animationSpeed = 5.0 * modifier
        
        // rotate the button accordingly. (UP means the arrow faces up etc.);
        // set the frame & animate the button from-to depending on arrow direction
        // ALL ARROWS ARE DEFAULT DRAWN FACING THE RIGHT
        switch arrow.getDirection() {
            case direction.LEFT:

                // left arrows will START from the RIGHT side of the screen; flip 180 degrees
                arrow.transform = arrow.transform.rotated(by: CGFloat(Double.pi))
                let yCoord = (bounds.maxY / 5) + (bounds.maxY / 5)
                let fromHere = CGRect(x: bounds.maxX, y: yCoord, width: buttonSide, height: buttonSide)
                arrow.frame = fromHere

                // left arrows should END on the LEFT side of the screen
                let toHere = CGRect(x: 0 - buttonSide, y: yCoord, width: buttonSide, height: buttonSide)
                UIView.transition(with: UIView(frame: fromHere), duration: animationSpeed, options: UIView.AnimationOptions.curveLinear, animations: {
                    arrow.frame = toHere
                }, completion: nil)

            case direction.RIGHT:

                // right arrows will START from the LEFT side of the screen; NO transformation
                let yCoord = (bounds.maxY / 5) + (bounds.maxY / 5)
                let fromHere = CGRect(x: 0 - buttonSide, y: yCoord, width: buttonSide, height: buttonSide)
                arrow.frame = fromHere
                
                // right arrows should END on the RIGHT side of the screen
                let toHere = CGRect(x: bounds.maxX, y: yCoord, width: buttonSide, height: buttonSide)
                UIView.transition(with: UIView(frame: fromHere), duration: animationSpeed, options: UIView.AnimationOptions.curveLinear, animations: {
                    arrow.frame = toHere
                }, completion: nil)

            case direction.UP:

                // up arrows will START from the BOTTOM of the screen; rotate 90 degrees counter clockwise
                arrow.transform = arrow.transform.rotated(by: -CGFloat(Double.pi) / 2)
                let xCoord = (bounds.maxX / 5) + (bounds.maxX / 5)
                let fromHere = CGRect(x: xCoord, y: bounds.maxX, width: buttonSide, height: buttonSide)
                arrow.frame = fromHere

                // UP arrows should END at the TOP of the screen
                let toHere = CGRect(x: xCoord, y: 0 - buttonSide, width: buttonSide, height: buttonSide)
                UIView.transition(with: UIView(frame: fromHere), duration: animationSpeed, options: UIView.AnimationOptions.curveLinear, animations: {
                    arrow.frame = toHere
                }, completion: nil)

            case direction.DOWN:

                // up arrows will START from the TOP of the screen; rotate 90 degrees clockwise
                arrow.transform = arrow.transform.rotated(by: CGFloat(Double.pi / 2))
                let xCoord = (bounds.maxY / 5) + (bounds.maxY / 5)
                let fromHere = CGRect(x: xCoord, y: 0 - buttonSide, width: buttonSide, height: buttonSide)
                arrow.frame = fromHere

                // UP arrows should END at the BOTTOM of the screen
                let toHere = CGRect(x: xCoord, y: bounds.maxY, width: buttonSide, height: buttonSide)
                UIView.transition(with: UIView(frame: fromHere), duration: animationSpeed, options: UIView.AnimationOptions.curveLinear, animations: {
                    arrow.frame = toHere
                }, completion: nil)
            default: break
        }
    }
    
    // return the proper speed modifier;
    // level 1 will transition from point A to point B with no change in speed; while
    // level 10 will take 10% of the time required to move the same distance
    func speedModifier(color: UIColor) -> Double {
        var modifier: Double?
        
        switch color {
            case UIColor.yellow: modifier = 1
            case UIColor.orange: modifier = 0.9
            case UIColor.red: modifier = 0.8
            case UIColor.purple: modifier = 0.7
            case UIColor.blue: modifier = 0.6
            case UIColor.cyan: modifier = 0.5
            case UIColor.green: modifier = 0.4
            case UIColor.black: modifier = 0.3
            case UIColor.white: modifier = 0.2
            case UIColor.magenta: modifier = 0.1
            default: break
        }
        return modifier ?? -1
    }
}
