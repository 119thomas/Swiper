//
//  model.swift
//  Swiper
//
//  Created by William Thomas on 3/17/19.
//  Copyright © 2019 William Thomas. All rights reserved.
//

import Foundation
import UIKit

class gameSwiper {
    private var level: Int
    private var points: Int
    private var swipes: Int
    
    init() {
        self.level = 1
        self.points = 0
        self.swipes = 0
    }
    
    // Return a random direction
    func getRandomDirection() -> direction {
        let randomNumber = Int.random(in: 0 ..< 4)
        var result = direction.NO_DIRECTION
        
        switch randomNumber {
            case 0: result = direction.LEFT
            case 1: result = direction.RIGHT
            case 2: result = direction.UP
            case 3: result = direction.DOWN
            default:
                print("random number malfunction")
        }
        return result
    }
    
    // Increase points by one
    func increasePoints() {
        points += 1
    }
    
    // return current amount of points
    func getPoints() -> Int {
        return points
    }
    
    // Reset the level to 1; points become 0
    func resetGame() {
        level = 1
        points = 0
    }
    
    // Level up the player if applicable; return true if level up occured
    func adjustLevel() -> Bool {
        if(levelUp()) {
            level += 1
            return true
        }
        return false
    }
    
    // Increase swipe count by 1
    func increaseSwipes() {
        swipes += 1
        print("swipes are now: \(swipes)")
    }
    
    // Return a color based on the players current progress in the game (their level)
    func levelColor() -> UIColor {
        var color: UIColor
        
        // color is decided based on level: (1-10)
        switch level {
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
    
    // Returns true if the player has achieved a new level
    private func levelUp() -> Bool {
        var result: Bool
        
        switch swipes {
            case 5: result = true   // level 2
            case 15: result = true  // level 3
            case 30: result = true  // level 4
            case 50: result = true  // level 5
            case 75: result = true  // level 6
            case 105: result = true // level 7
            case 140: result = true // level 8
            case 180: result = true // level 9
            case 225: result = true // level 10
            default: result = false
        }
        return result
    }
}
