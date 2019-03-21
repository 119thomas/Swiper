//
//  ViewController.swift
//  Swiper
//
//  Created by William Thomas on 2/24/19.
//  Copyright © 2019 William Thomas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var swiperNewGamePause: UIStackView!
    @IBOutlet weak var gameDisplay: arrowDisplay!
    @IBOutlet weak var scorePoints: UIStackView!
    let game = gameSwiper()
    let highscoreController = HighscoreController()
    var chances = 3
    var workItem: DispatchWorkItem?
    var safeMode = true
    
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
        
        // button initializations
        var stackView = swiperNewGamePause.subviews[1] as! UIStackView
        
        // new game button
        let newGameButton = stackView.subviews[0] as! UIButton
        newGameButton.titleLabel?.textAlignment = .center
        newGameButton.titleLabel?.adjustsFontSizeToFitWidth = true
        
        // pause button
        let pauseButton = stackView.subviews[1] as! UIButton
        pauseButton.titleLabel?.textAlignment = .center
        pauseButton.titleLabel?.adjustsFontSizeToFitWidth = true
        

        // label initializations
        stackView = scorePoints.subviews[0] as! UIStackView
        
        // score label
        let score = stackView.subviews[0] as! UILabel
        score.textAlignment = .center
        score.adjustsFontSizeToFitWidth = true
        
        // level label
        let level = stackView.subviews[0] as! UILabel
        level.textAlignment = .center
        level.adjustsFontSizeToFitWidth = true
        
        stackView = scorePoints.subviews[1] as! UIStackView
        
        // score counter
        let scoreCounter = stackView.subviews[0] as! UILabel
        scoreCounter.textAlignment = .center
        scoreCounter.adjustsFontSizeToFitWidth = true
        
        // point counter
        let pointCounter = stackView.subviews[1] as! UILabel
        pointCounter.textAlignment = .center
        pointCounter.adjustsFontSizeToFitWidth = true
        
        // swiper label
        let swiperLabel = swiperNewGamePause.subviews[0] as! UILabel
        swiperLabel.textAlignment = .center
        swiperLabel.adjustsFontSizeToFitWidth = true
    }
    
    // Pressing New Game button will prompt a new game to begin
    @IBAction func newGameButton(_ sender: UIButton) {
        safeMode = false
        newGame()
    }
    
    @IBAction func pauseGameButton(_ sender: UIButton) {
     //   if(safeMode) { return }
        pauseGame()
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

        // add the button to subviews so it can be animated (so we can see it)
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
    
    func pauseGame() {
        // darken the view for everything except our 'pause menu'
        self.view.backgroundColor = UIColor(white: 1, alpha: 0.2)
        gameDisplay.alpha = 0.2
        scorePoints.alpha = 0.2
        swiperNewGamePause.alpha = 0.2
        safeMode = true
        
        // game paused text frame will start at the top of the screen
        var width = CGFloat(gameDisplay.bounds.maxX / 2)
        var height = CGFloat(gameDisplay.bounds.maxY / 3)
        var xCoord = CGFloat(view.bounds.midX) - (width / 2)
        var yCoord = CGFloat(gameDisplay.bounds.minY)
        var fromHere = CGRect(x: xCoord, y: yCoord, width: width, height: height)
        
        // create a button to display 'game paused' text
        let buttonText = UIButton(frame: fromHere)
        buttonText.setTitle("Game Paused", for: .normal)
        buttonText.setTitleColor(UIColor.white, for: .normal)
        buttonText.titleLabel?.font = UIFont(name: "splatch", size: 64)
        buttonText.titleLabel?.textAlignment = .center
        buttonText.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.view.addSubview(buttonText)
        
        // slide the new game text to the top of the gameDisplay
        yCoord = CGFloat(gameDisplay.bounds.maxY / 2)
        let toHere = CGRect(x: xCoord, y: yCoord, width: width, height: height)
        UIView.transition(with: UIView(frame: fromHere), duration: 0.25, options: UIView.AnimationOptions.curveLinear, animations: {
            buttonText.frame = toHere
        }, completion: nil)
        
        // the continue button frame will stay in the center of the screen
        width = CGFloat(gameDisplay.bounds.maxX / 3)
        height = CGFloat(gameDisplay.bounds.maxY / 7)
        xCoord = CGFloat(view.bounds.midX) - (width / 2)
        yCoord = CGFloat(view.bounds.midY) - (height / 2)
        fromHere = CGRect(x: xCoord, y: yCoord, width: width, height: height)
        
        // create the continue button and add text attributes
        let buttonContinue = UIButton(frame: fromHere)
        buttonContinue.backgroundColor = UIColor.black
        buttonContinue.layer.cornerRadius = 10
        buttonContinue.setTitle("Continue", for: .normal)
        buttonContinue.setTitleColor(UIColor.white, for: .normal)
        buttonContinue.titleLabel?.font = UIFont(name: "splatch", size: 24)
        buttonContinue.titleLabel?.textAlignment = .center
        buttonContinue.titleLabel?.adjustsFontSizeToFitWidth = true
        
        self.view.addSubview(buttonContinue)
        
        // fade in the continue button
        buttonContinue.alpha = 0
        UIView.animate(withDuration: 0.25, animations:{
            buttonContinue.alpha = 1
        })
        
        // add a button action to our continue button
        buttonContinue.addTarget(self, action: #selector(continueButtonAction), for: .touchUpInside)
        
        
        
//        buttonContinue.removeFromSuperview()
//        buttonText.removeFromSuperview()
    }
    
    @IBAction func continueButtonAction(sender: UIButton!) {
        self.view.backgroundColor = UIColor(white: 1, alpha: 1)
        gameDisplay.alpha = 1
        scorePoints.alpha = 1
        swiperNewGamePause.alpha = 1
        safeMode = false
    }
}

