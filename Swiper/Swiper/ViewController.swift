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
    let highscoreController = HighscoreController()
    var chances = 3
    var workItem: DispatchWorkItem?
    
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
    }
    
    @IBAction func newGameButton(_ sender: UIButton) {
        newGame()
    }
    
    @IBAction func gestures(_ sender: UISwipeGestureRecognizer) {
        let arrowView = gameDisplay.subviews[0]
        let arrowButton = arrowView as! ButtonArrow
        workItem?.cancel()
        
        // check if the player swiped in the correct direction
        switch sender.direction {
            case .right:
                if(arrowButton.getDirection() == direction.RIGHT) {
                    arrowView.layer.removeAllAnimations()
                    update()
                }
                else {
                    wrongSwipe(); update()
                }
            case .left:
                if(arrowButton.getDirection() == direction.LEFT) {
                    arrowView.layer.removeAllAnimations()
                    update()
                }
                else {
                    wrongSwipe(); update()
                }
            case .up:
                if(arrowButton.getDirection() == direction.UP) {
                    arrowView.layer.removeAllAnimations()
                    update()
                }
                else {
                    wrongSwipe(); update()
                }
            case .down:
                if(arrowButton.getDirection() == direction.DOWN) {
                    arrowView.layer.removeAllAnimations()
                    update()
                }
                else {
                    wrongSwipe(); update()
                }
            default: break
        }
    }
    
    func update() {
        if(chances > 0) {
            displayNextArrow()
            gameDisplay.setNeedsLayout()
            workItem = DispatchWorkItem { print("working.."); self.wrongSwipe(); self.update() }
            DispatchQueue.main.asyncAfter(deadline: .now() + threshold(), execute: workItem!)
        }
    }
    
    func displayNextArrow() {
        // clear out the old button(direction) from subviews
        for view in gameDisplay.subviews {
            view.removeFromSuperview()
        }
        
        // get a direction and level based color for the next arrow
        let direction = game.getRandomDirection()
        let color = levelColor()
        
        // add the new arrow as a subview of gameDisplay
        let arrow = ButtonArrow(dir: direction, color: color)
        gameDisplay.addSubview(arrow)
    }
    
    func newGame() {
        chances = 3
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
            default: color = UIColor.clear
        }
        return color
    }
    
    // called when the player swipes in the wrong direction;
    // returns true if the game is over (3 wrong swipes)
    func wrongSwipe() {
        chances -= 1
        if(chances == 0) {
            gameOver()
        }
    }
    
    func gameOver() {
        highscoreController.addPoints(points: game.getPoints())
//        self.tabBarController?.selectedIndex = 1
        let alertController = UIAlertController(title: "Game is Over!", message:
            "Your score: \(game.getPoints())", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func threshold() -> Double {
        return 5.0 * gameDisplay.speedModifier(color: levelColor())
    }
}

