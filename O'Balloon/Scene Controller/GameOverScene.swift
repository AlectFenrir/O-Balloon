//
//  GameOverScene.swift
//  O'Balloon
//
//  Created by Rayhan Martiza Faluda on 13/06/20.
//  Copyright © 2020 Rayhan Martiza Faluda. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

class GameOverScene: SKScene {
    
    var finalScoreLabel: SKLabelNode!
    var balloonCounterLabel: SKLabelNode!
    
    var score: CGFloat = 0
    var finalScore: Int = 0
    var balloonCounter: Int = 0
    
    let LEADERBOARD_ID = "com.rayhanfaluda.O_Balloon"
    
    override func didMove(to view: SKView) {
        setupGameOverAudio()
        
        finalScoreLabel = (childNode(withName: "//FinalScoreLabel") as! SKLabelNode)
        balloonCounterLabel = (childNode(withName: "//BalloonCounterLabel") as! SKLabelNode)
        
        finalScore = Int(score) * balloonCounter
        print(finalScore)
        
        /* let scoreFormat = String(format: "%.0f", finalScore)
        let dinoyScaleFormat = String(format: "%.2f", dino.yScale)
        print("xScale: \(dinoxScaleFormat), yScale: \(dinoyScaleFormat)")
        print("Score: \(scoreFormat)") */
        
        // Submit score to GC leaderboard
        let bestScoreInt = GKScore(leaderboardIdentifier: LEADERBOARD_ID)
        bestScoreInt.value = Int64(finalScore)
        GKScore.report([bestScoreInt]) { (error) in
            if error != nil {
                print(error!.localizedDescription)
            } else {
                print("Best Score submitted to your Leaderboard!")
            }
        }
        
        finalScoreLabel.text = "\(finalScore)"
        balloonCounterLabel.text = "\(balloonCounter)"
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        /* let node = nodes(at: touch.location(in: self)).first */
        
        let buttonNode = childNode(withName: "//HomeButton")
        
        if buttonNode!.frame.contains(touch.location(in: self)) {
            let mainMenuScene = MainMenuScene(fileNamed: "MainMenuScene")
            mainMenuScene?.scaleMode = scaleMode
            view?.presentScene(mainMenuScene)
        }
    }
    
    func setupGameOverAudio() {
        let soundNode = SKAudioNode(fileNamed: "O'balloon_Gameover.m4a")
        soundNode.autoplayLooped = false
        addChild(soundNode)

        let volumeAction = SKAction.changeVolume(to: 1, duration: 0)
        soundNode.run(SKAction.group([volumeAction, SKAction.play()]))
    }
}
