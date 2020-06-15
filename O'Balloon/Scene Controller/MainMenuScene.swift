//
//  MainMenuScene.swift
//  O'Balloon
//
//  Created by Rayhan Martiza Faluda on 13/06/20.
//  Copyright © 2020 Rayhan Martiza Faluda. All rights reserved.
//

import SpriteKit
import GameplayKit
import GameKit

class MainMenuScene: SKScene {
    
    var leaderboardButton: SKSpriteNode!
    var threeBalloon: SKSpriteNode!
    var balloonAction: SKAction!
    var tapAnywhereLabel: SKLabelNode!
    
    var gcEnabled = Bool() // Check if the user has Game Center enabled
    var gcDefaultLeaderBoard = String() // Check the default leaderboardID
    let LEADERBOARD_ID = "com.rayhanfaluda.O_Balloon"
    
    override func didMove(to view: SKView) {
        let soundNode = SKAudioNode(fileNamed: "O'balloon_BGM.aac")
        soundNode.autoplayLooped = true
        addChild(soundNode)
        
        let volumeAction = SKAction.changeVolume(to: 1, duration: 0)
        soundNode.run(SKAction.group([volumeAction, SKAction.play()]))
        
        setupBalloonAction()
        
        threeBalloon = (childNode(withName: "//ThreeBalloon") as! SKSpriteNode)
        tapAnywhereLabel = (childNode(withName: "//TapAnywhereLabel") as! SKLabelNode)
        
        animateNodes([tapAnywhereLabel])
        threeBalloon.run(balloonAction, withKey: "balloonAnimation")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        leaderboardButton = (childNode(withName: "//LeaderboardButton") as! SKSpriteNode)
        
        if leaderboardButton!.frame.contains(touch.location(in: self)) {
            let vc = self.view!.window!.rootViewController! //POINT 2
            let gc = GKGameCenterViewController()
            gc.gameCenterDelegate = self
            gc.viewState = .leaderboards
            vc.present(gc, animated: true, completion: nil)
        }
        else {
            let gameScene = GameScene(fileNamed: "GameScene")
            gameScene?.scaleMode = scaleMode
            view?.presentScene(gameScene)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
    
    func setupBalloonAction() {
        var textures = [SKTexture]()
        for i in 1...150 {
            textures.append(SKTexture(imageNamed: "Comp \(i)"))
        }
        balloonAction = SKAction.repeatForever(SKAction.animate(with: textures, timePerFrame: 1/30))
    }
    
    func animateNodes(_ nodes: [SKNode]) {
        for (index, node) in nodes.enumerated() {
            // Offset each node with a slight delay depending on the index
            let delayAction = SKAction.wait(forDuration: TimeInterval(index) * 0)

            // Fade out and fade in
            let fadeOut = SKAction.fadeOut(withDuration: 1)
            let fadeIn = SKAction.fadeIn(withDuration: 1)

            // Wait for 2 seconds before repeating the action
            let waitAction = SKAction.wait(forDuration: 1)

            // Form a sequence with the scale actions, as well as the wait action
            let scaleActionSequence = SKAction.sequence([fadeOut, fadeIn, waitAction])

            // Form a repeat action with the sequence
            let repeatAction = SKAction.repeatForever(scaleActionSequence)

            // Combine the delay and the repeat actions into another sequence
            let actionSequence = SKAction.sequence([delayAction, repeatAction])

            // Run the action
            node.run(actionSequence)
        }
    }
}


extension MainMenuScene: GKGameCenterControllerDelegate {
    // Delegate to dismiss the GC controller
    func gameCenterViewControllerDidFinish(_ gameCenterViewController: GKGameCenterViewController) {
        gameCenterViewController.dismiss(animated: true, completion: nil)
    }
}
