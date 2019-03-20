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
    var chances = 3, swipes = 0
    var workItem: DispatchWorkItem?
    var safeMode = false
    
    // Prepare the screen for gesture recognition
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    // Pressing New Game button will prompt a new game to begin
    @IBAction func newGameButton(_ sender: UIButton) {
        newGame()
    }
    
    /* Handle our gestures accordingly; correct swipes update & increase swipe count;
        Incorrect swipes will deduct chances only; cancel workItem before it finishes */
    @IBAction func gestures(_ sender: UISwipeGestureRecognizer) {
        
        // don't recognize any gestures while in safeMode
        if(safeMode) { return }
        
        let arrowView = gameDisplay.subviews[0]
        let arrowButton = arrowView as! ButtonArrow
        var swipedCorrect = false
        workItem?.cancel()
        
        // check if the player swiped in the correct direction
        switch sender.direction {
            case .right:
                if(arrowButton.getDirection() == direction.RIGHT) {
                    swipedCorrect = true
                }
            case .left:
                if(arrowButton.getDirection() == direction.LEFT) {
                    swipedCorrect = true
                }
            case .up:
                if(arrowButton.getDirection() == direction.UP) {
                    swipedCorrect = true
                }
            case .down:
                if(arrowButton.getDirection() == direction.DOWN) {
                    swipedCorrect = true
                }
            default: break
        }
        
        if(swipedCorrect) {
            game.increaseSwipes(); game.increasePoints()
            arrowView.layer.removeAllAnimations()
            
            /* if adjustLevel returns true (leveled up) -> clear screen;
                level up button requires 2 seconds to display */
            if(game.adjustLevel()) {
                safeMode = true
                levelUpAnimation()
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    self.safeMode = false
                    self.update()
                }
            }
            else {
                update()
            }
        }
        else {
            print("fail!")
            wrongSwipe()
            update()
        }
    }
    
    /* Only if we have chances remaining will we display the next arrow for play,
        and then execute our workItem. workItem will wait threshold() amount of time
        before it finishes execution. If the player does not cancel workItem before it
        finishes execution, then they will recieve a 'wrongSwipe()'. i.e. The player
        must swipe before the arrow crosses the screen */
    func update() {
        if(chances > 0) {
            displayNextArrow()
            gameDisplay.setNeedsLayout()
            workItem = DispatchWorkItem { print("gotta be quicker than that"); self.wrongSwipe(); self.update() }
            DispatchQueue.main.asyncAfter(deadline: .now() + threshold(), execute: workItem!)
        }
    }
    
    /* When displaying the next arrow, we will clear the current subviews, and
        add a new ButtonArrow (with different direction & color) to subviews */
    func displayNextArrow() {
        
        // clear out the old button(direction) from subviews
        for view in gameDisplay.subviews {
            view.removeFromSuperview()
        }
        
        // get a direction and level based color for the next arrow
        let direction = game.getRandomDirection()
        let color = game.levelColor()
        
        // add the new arrow as a subview of gameDisplay
        let arrow = ButtonArrow(dir: direction, color: color)
        gameDisplay.addSubview(arrow)
    }
    
    // A new game will reset chances and update the display for a new game
    func newGame() {
        chances = 3
        update()
    }
    
    /* Called when the player swipes in the wrong direction;
        returns true if the game is over (3 wrong swipes) */
    func wrongSwipe() {
        chances -= 1
        if(chances == 0) {
            gameOver()
        }
    }
    
    /* When the game is over we switch to the highscores tab and allow entry into the
        highscores table (if the player makes the top 10 scores only) */
    func gameOver() {
        highscoreController.addPoints(points: game.getPoints())
 //       self.tabBarController?.selectedIndex = 1
        let alertController = UIAlertController(title: "Game is Over!", message:
            "Your score: \(game.getPoints())", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /* The threshold will be the current amount of time allowed to pass
         before the player must swipe. (if threshold amount of time passes,
         we will count this turn as a miss) */
    func threshold() -> Double {
        print("threshold is: \(5.0 * gameDisplay.speedModifier(color: game.levelColor()))")
        return 5.0 * gameDisplay.speedModifier(color: game.levelColor())
    }
    
    /* When a player levels up, we will call this function which animates a button
        onto and off the screen with text reading 'Level Up!' */
    func levelUpAnimation() {
        
        // we want to start off screen initially
        var xCoord = CGFloat(gameDisplay.frame.maxX)
        let yCoord = CGFloat(gameDisplay.frame.maxY / 2)
        let width = CGFloat(gameDisplay.bounds.maxX / 2)
        let height = CGFloat(gameDisplay.bounds.maxY / 3)
        var fromHere = CGRect(x: xCoord, y: yCoord, width: width, height: height)
        
        // create a button that we will animate
        let button = UIButton(frame: fromHere)
        let textSize = (button.bounds.maxX / 2) / 4
        button.setTitle("Level up!", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "splatch", size: textSize)

        // add the button to subviews so it can be animated
        self.view.addSubview(button)
        
        // slide the level up text to the center of the screen from the right
        xCoord = CGFloat(self.view.bounds.maxX / 2 - (width / 2))
        var toHere = CGRect(x: xCoord, y: yCoord, width: width, height: height)
        UIView.transition(with: UIView(frame: fromHere), duration: 0.5, options: UIView.AnimationOptions.curveLinear, animations: {
            button.frame = toHere
        }, completion: { complete in
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                
                // wait 1/2 second then slide the level up text off screen to the left
                fromHere = toHere
                xCoord = CGFloat(self.view.bounds.minX - width)
                toHere = CGRect(x: xCoord, y: yCoord, width: width, height: height)
                UIView.transition(with: UIView(frame: fromHere), duration: 0.5, options: UIView.AnimationOptions.curveLinear, animations: {
                    button.frame = toHere
                }, completion: {(value: Bool) in
                    button.removeFromSuperview()    // remove button from subviews!
                })
            }
        })
    }
}

