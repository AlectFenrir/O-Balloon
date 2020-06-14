//
//  GameOverScene.swift
//  O'Balloon
//
//  Created by Rayhan Martiza Faluda on 13/06/20.
//  Copyright © 2020 Rayhan Martiza Faluda. All rights reserved.
//

import SpriteKit
import GameplayKit

class GameOverScene: SKScene {
    
    var finalScoreLabel: SKLabelNode!
    var balloonCounterLabel: SKLabelNode!
    
    var score: CGFloat = 0
    var finalScore: Int = 0
    var balloonCounter: Int = 0
    
    override func didMove(to view: SKView) {
        finalScoreLabel = (childNode(withName: "//FinalScoreLabel") as! SKLabelNode)
        balloonCounterLabel = (childNode(withName: "//BalloonCounterLabel") as! SKLabelNode)
        
        finalScore = Int(score) * balloonCounter
        print(finalScore)
        
        /* let scoreFormat = String(format: "%.0f", finalScore)
        let dinoyScaleFormat = String(format: "%.2f", dino.yScale)
        print("xScale: \(dinoxScaleFormat), yScale: \(dinoyScaleFormat)")
        print("Score: \(scoreFormat)") */
        
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
}
