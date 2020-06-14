//
//  MainMenuScene.swift
//  O'Balloon
//
//  Created by Rayhan Martiza Faluda on 13/06/20.
//  Copyright © 2020 Rayhan Martiza Faluda. All rights reserved.
//

import SpriteKit
import GameplayKit

class MainMenuScene: SKScene {
    
    var tapAnywhereLabel: SKLabelNode!
    
    override func didMove(to view: SKView) {
        // Create & configure the engine before doing anything else, since the user may touch a pad immediately.
        tapAnywhereLabel = (childNode(withName: "//TapAnywhereLabel") as! SKLabelNode)
        
        animateNodes([tapAnywhereLabel])
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let gameScene = GameScene(fileNamed: "GameScene")
        gameScene?.scaleMode = scaleMode
        view?.presentScene(gameScene)
    }
    
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
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
