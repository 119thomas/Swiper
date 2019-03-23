//
//  highscoreController.swift
//  Swiper
//
//  Created by William Thomas on 3/17/19.
//  Copyright © 2019 William Thomas. All rights reserved.
//

import Foundation
import UIKit

/* highController will control everything related to the high scores tab;
 highController's basic functionality consists of saving and retrieving
 an array of Int : String (the high scores) to and from UserDefaults.
 Scores will be displayed and formatted in a UITextView.  */
class highController: UIViewController {

    private var scores = [highScore]()
    @IBOutlet weak var Leaderboard: UITextView!
    
    private struct highScore: Codable {
        var score: Int
        var name: String
    }
    
    override func viewWillAppear(_ animated: Bool) {
        update()
    }
    
    /* update our view with the current leaderboard */
    func update() {
        var result = "", index = 1
        
        if let data = UserDefaults.standard.value(forKey: "scores") as? Data {
            let retrievedScores = try? PropertyListDecoder().decode(Array<highScore>.self, from: data)
            for score in retrievedScores! {
                result += "\(index)) \(score.name): \(score.score)\n"
                index += 1
            }
        }
        
        // set text and adjust font
        Leaderboard.font = UIFont(name: "splatch", size: 18)
        Leaderboard.text = result
        Leaderboard.adjustsFontForContentSizeCategory = true
        Leaderboard.textAlignment = .center
    }
    
    @IBAction func reset(_ sender: Any) {
        clearHighscores()
    }
    
    // Add a new high score to our leaderboard; save to user deault
    func addNewHighscore(score: Int, name: String) {
        
        // retrieve previous high scores, create new high score; re-encode & save data
        let newHighScore = highScore(score: score, name: name)
        let retrievedScores = UserDefaults.standard.value(forKey: "scores") as? Data
        if(retrievedScores != nil) {
            var mutableScores = try? PropertyListDecoder().decode(Array<highScore>.self, from: retrievedScores!)
            print("\((mutableScores?.count)!) > 15 && \(score) > \((mutableScores?.last!.score)!)")
            mutableScores?.append(newHighScore)
            mutableScores?.sort(by: {$0.score > $1.score})
            UserDefaults.standard.set(try? PropertyListEncoder().encode(mutableScores), forKey:"scores")
        }
        else {
            UserDefaults.standard.set(try? PropertyListEncoder().encode([newHighScore]), forKey:"scores")
        }
    }
    
    // Clear the array in user defaults, effectively 'clearing' the high score table
    func clearHighscores() {
        let alertController = UIAlertController(title: "Are you sure?", message:
            "highscores will be permanently deleted", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Confirm", style: .default, handler: {
            (action: UIAlertAction) in
            let retrievedScores = UserDefaults.standard.value(forKey: "scores") as? Data
            if(retrievedScores != nil) {
                print("reseting")
                UserDefaults.standard.removeObject(forKey: "scores")
                UserDefaults.standard.synchronize()
                super.tabBarController?.selectedIndex = 0
                super.tabBarController?.selectedIndex = 1
            }
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    /* Check user defaults to see if the given score is larger than the last
     score on the list (user defaults is stored in order: large -> small) */
    func isNewHighscore(score: Int) -> Bool {
        // grab our scores from UserDefaults
        let retrievedScores = UserDefaults.standard.value(forKey: "scores") as? Data
        
        // !nil means retrieved scores is empty, aka no leaderboard yet
        if(retrievedScores != nil) {
            
            // leaderboards is stored as an array, so we decode it accordingly
            let mutableScores = try? PropertyListDecoder().decode(Array<highScore>.self, from: retrievedScores!)
            
            print("count of mutable scores: \(mutableScores!.count)")
            
            // if we have less than 15 entries, it will always be a new highscore
            if((mutableScores?.count)! < 15) {
                return true
            }
            
            // is the given score > than the lowest value in our array (last index)?
            if((mutableScores?.count)! > 15 && score > (mutableScores?.last!.score)!) {
                return true
            }
            else {
                return false
            }
        }
        return true
    }
}
