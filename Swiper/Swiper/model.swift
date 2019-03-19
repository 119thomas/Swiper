//
//  model.swift
//  Swiper
//
//  Created by William Thomas on 3/17/19.
//  Copyright © 2019 William Thomas. All rights reserved.
//

import Foundation

class gameSwiper {
    private var level: Int
    private var points: Int
    
    init() {
        level = 1
        points = 0
    }
    
    // return a random direction
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
    
    // increase the current level by one
    func increaseLevel() {
        level += 1
    }
    
    // return the current level of progress
    func getLevel() -> Int {
        return level
    }
    
    // increase points by one
    func increasePoints() {
        points += 1
    }
    
    // return the current amount of points a player has
    func getPoints() -> Int {
        return points
    }
    
    // reset the level to 1; points become 0
    func resetGame() {
        level = 1
        points = 0
    }
}
