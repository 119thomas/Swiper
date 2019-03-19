//
//  ViewController.swift
//  Swiper
//
//  Created by William Thomas on 2/24/19.
//  Copyright © 2019 William Thomas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var swiperLabel: UILabel!
    @IBOutlet weak var gameDisplay: arrowDisplay!
    let game = gameSwiper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       // swiperLabel.font = UIFont(name: "splatch", size: 40)
        
        // set our gestures
        let left = UISwipeGestureRecognizer(target: self, action: #selector(gestures))
        left.direction = .left
        self.view.addGestureRecognizer(left)
        
        let right = UISwipeGestureRecognizer(target: self, action: #selector(gestures))
        right.direction = .right
        self.view.addGestureRecognizer(right)
        
        let up = UISwipeGestureRecognizer(target: self, action: #selector(gestures))
        up.direction = .up
        self.view.addGestureRecognizer(up)
        
        let down = UISwipeGestureRecognizer(target: self, action: #selector(gestures))
        down.direction = .down
        self.view.addGestureRecognizer(down)
        
        // start a new game
        newGame()
    }
    
    @IBAction func gestures(_ sender: UISwipeGestureRecognizer) {
        switch sender.direction {
            case .right: print("right")
            case .left: print("left")
            case .up: print("up")
            case .down: print("down")
            default: print("unrecognized gesture")
        }
        gameDisplay.setNeedsLayout()
    }
    
    func update() {
        displayNextArrow()
        gameDisplay.setNeedsLayout()
    }
    
    func displayNextArrow() {
        // clear out the current button(direction) from subviews
    //   gameDisplay.removeFromSuperview()
        
        // get the direction and color for the next arrow
        let direction = game.getRandomDirection()
        let color = levelColor()
        
        // add the new arrow as a subview of gameDisplay
        let arrow = ButtonArrow(dir: direction, color: color)
        gameDisplay.addSubview(arrow)
    }
    
    func newGame() {
        update()
    }
    
    // return a color based on the players current progress in the game (their level)
    func levelColor() -> UIColor {
        var color: UIColor

        // color is decided based on level: (1-10)
        switch game.getLevel() {
            case 1: color = UIColor.yellow
            case 2: color = UIColor.orange
            case 3: color = UIColor.red
            case 4: color = UIColor.purple
            case 5: color = UIColor.blue
            case 6: color = UIColor.cyan
            case 7: color = UIColor.green
            case 8: color = UIColor.black
            case 9: color = UIColor.white
            case 10: color = UIColor.magenta
            default: color = UIColor.white
        }
        return color
    }
}

