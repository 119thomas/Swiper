//
//  ViewController.swift
//  Swiper
//
//  Created by William Thomas on 2/24/19.
//  Copyright © 2019 William Thomas. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var top: UIStackView!
    @IBOutlet weak var gameDisplay: arrowDisplay!
    @IBOutlet weak var scorePoints: UIStackView!
    let game = gameSwiper()
    let highscore = highController()
    var chances = 3
    var workItem: DispatchWorkItem?
    var safeMode = true, shouldPrompt = false, paused = false, playing = false
    
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
        if(top != nil) {
            var stackView = top.subviews[1] as? UIStackView
            
            // swiper label
            let swiperLabel = top.subviews[0] as! UILabel
            swiperLabel.textAlignment = .center
            swiperLabel.adjustsFontSizeToFitWidth = true
            
            // new game button
            let newGameButton = stackView!.subviews[0] as! UIButton
            newGameButton.titleLabel?.textAlignment = .center
            newGameButton.titleLabel?.adjustsFontSizeToFitWidth = true
            
            // pause button
            let pauseButton = stackView!.subviews[1] as! UIButton
            pauseButton.titleLabel?.textAlignment = .center
            pauseButton.titleLabel?.adjustsFontSizeToFitWidth = true
            
            // label initializations
            stackView = (scorePoints.subviews[0] as! UIStackView)
            
            // score label
            let score = stackView!.subviews[0] as! UILabel
            score.textAlignment = .center
            score.adjustsFontSizeToFitWidth = true
            
            // level label
            let level = stackView!.subviews[0] as! UILabel
            level.textAlignment = .center
            level.adjustsFontSizeToFitWidth = true
            
            stackView = (scorePoints.subviews[1] as! UIStackView)
            
            // score counter
            let scoreCounter = stackView!.subviews[0] as! UILabel
            scoreCounter.textAlignment = .center
            scoreCounter.adjustsFontSizeToFitWidth = true
            
            // level counter
            let levelCounter = stackView!.subviews[1] as! UILabel
            levelCounter.textAlignment = .center
            levelCounter.adjustsFontSizeToFitWidth = true
        }
    }
    
    // Pressing New Game button will prompt a new game to begin
    @IBAction func newGameButton(_ sender: UIButton) {
        // don't allow new game to be pressed when paused
        if(paused) { return }
        
        safeMode = true
        workItem?.cancel()
        
        if(!gameDisplay.subviews.isEmpty) {
            let arrowView = gameDisplay.subviews[0]
            arrowView.removeFromSuperview()
        }
        
        shouldPrompt ? promptNewGame() : generateNewGame()
    }
    
    @IBAction func pauseGameButton(_ sender: UIButton) {
        if(safeMode) { return }
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
                updateCounters()
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
            updateCounters()
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
    
    // prompt the user about starting a new game
    func promptNewGame() {
        safeMode = true
        
        // cancel the current work and remove the arrow from the superview
        workItem?.cancel()
        if(!gameDisplay.subviews.isEmpty) {
            let arrowView = gameDisplay.subviews[0]
            arrowView.removeFromSuperview()
        }
        
        let alertController = UIAlertController(title: "New Game?", message:
            "All data will be lost.", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: {
            (action: UIAlertAction) in
            self.countDownAnimation()
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                self.safeMode = false
                self.update()
            }
        }))
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: {
            (action: UIAlertAction) in self.generateNewGame()
        }))
        self.present(alertController, animated: true, completion: nil)
    }
    
    // generate the new game
    func generateNewGame() {
        chances = 3
        safeMode = false
        shouldPrompt = true
        game.resetGame()
        update()
    }
    
    // update counters accordingly
    func updateCounters() {
        let stackView = scorePoints.subviews[1] as! UIStackView
        let pointCounter = stackView.subviews[0] as! UILabel
        pointCounter.text = "\(game.getPoints())"
        let levelCounter = stackView.subviews[1] as! UILabel
        levelCounter.text = "\(game.getLevel())"
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
        highscores table (if the player makes the top 15 scores only) */
    func gameOver() {
        workItem?.cancel()
        let arrowView = gameDisplay.subviews[0]
        arrowView.removeFromSuperview()
        let score = game.getPoints()
        
        self.tabBarController?.selectedIndex = 1
        
        // alert that the game is over
        let alertController = UIAlertController(title: "Game is Over!", message:
            "Your score: \(score)", preferredStyle: .alert)
        
        alertController.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: {
            (action: UIAlertAction) in
            
            /* on completion, check if player recieved a new high score. If new highscore
                was reached, prompt the user for a name and add it to the Leaderboards */
            if(self.highscore.isNewHighscore(score: score)) {
                
                let alert = UIAlertController(title: "New High Score!", message: "Score: \(score)", preferredStyle: .alert)
                
                let action = UIAlertAction(title: "Enter", style: .default) { (alertAction) in
                    let playerName = alert.textFields![0] as UITextField
                    self.highscore.addNewHighscore(score: self.game.getPoints(), name: playerName.text!)
                    self.game.resetGame()
                    self.highscore.view.setNeedsDisplay()
                    
                    // update the view for our player :)
                    self.tabBarController?.selectedIndex = 0
                    self.tabBarController?.selectedIndex = 1
                }
                
                alert.addTextField { (textField) in
                    textField.placeholder = "Name"
                }
                
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            else {
                self.game.resetGame()
            }
        }))
        self.present(alertController, animated: true, completion: nil)
        shouldPrompt = false
        safeMode = true
        updateCounters()
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
        
        // create a button with 'level up text' that we will animate onto the screen
        let button = UIButton(frame: fromHere)
        let textSize = (button.bounds.maxX / 2) / 4
        button.setTitle("Level up!", for: .normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont(name: "splatch", size: textSize)
        
        // add the 'level up' button to subviews so it can be animated (so we can see it)
        self.view.addSubview(button)
        
        // slide the 'level up' button to the center of the screen from the right
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
                    button.removeFromSuperview()    // remove the button from subviews!
                })
            }
        })
    }
    
    func pauseGame() {
        safeMode = true
        paused = true
        
        // cancel the current work and remove the arrow from the superview
        workItem?.cancel()
        let arrowView = gameDisplay.subviews[0]
        arrowView.removeFromSuperview()
        
        // darken the view for everything except our 'pause menu'
        self.view.backgroundColor = UIColor(white: 1, alpha: 0.2)
        gameDisplay.alpha = 0.2
        scorePoints.alpha = 0.2
        top.alpha = 0.2
        
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
    }
    
    // reset alpha settings for the view and play countdown animation
    @IBAction func continueButtonAction(sender: UIButton!) {
        // remove the text and continue buttons from the view
        for view in self.view.subviews {
            if(view is UIButton) {
                view.removeFromSuperview()
            }
        }
        
        countDownAnimation()
        
        // countdown animation takes 3 seconds to perform
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            self.view.backgroundColor = UIColor(white: 1, alpha: 1)
            self.gameDisplay.alpha = 1
            self.scorePoints.alpha = 1
            self.top.alpha = 1
            self.safeMode = false
            self.paused = false
            self.update()
        }
    }
    
    func countDownAnimation() {
        // countdown will be in the center of the display
        let width = CGFloat(gameDisplay.bounds.maxX / 3)
        let height = CGFloat(gameDisplay.bounds.maxY / 7)
        let xCoord = CGFloat(view.bounds.midX) - (width / 2)
        let yCoord = CGFloat(view.bounds.midY) - (height / 2)
        let fromHere = CGRect(x: xCoord, y: yCoord, width: width, height: height)
        
        // set attributes for the countdown button
        let countDown = UIButton(frame: fromHere)
        
        self.view.addSubview(countDown)
        countDown.setTitle("3", for: .normal)
        countDown.setTitleColor(UIColor.white, for: .normal)
        countDown.titleLabel?.font = UIFont(name: "splatch", size: 24)
        countDown.titleLabel?.textAlignment = .center
        countDown.titleLabel?.adjustsFontSizeToFitWidth = true
        
        // countdown animation 3..2..1
        countDown.alpha = 0
        UIView.animate(withDuration: 1, animations:{
            countDown.alpha = 1
        }, completion: { (value: Bool) in
            countDown.alpha = 0
            countDown.setTitle("2", for: .normal)
            UIView.animate(withDuration: 1, animations:{
                countDown.alpha = 1
            }, completion: { (value: Bool) in
                countDown.alpha = 0
                countDown.setTitle("1", for: .normal)
                UIView.animate(withDuration: 1, animations:{
                    countDown.alpha = 1
                }, completion: { (value: Bool) in
                    countDown.removeFromSuperview()
                })
            })
        })
    }
}

