//
//  GameScene.swift
//  O'Balloon
//
//  Created by Rayhan Martiza Faluda on 13/06/20.
//  Copyright © 2020 Rayhan Martiza Faluda. All rights reserved.
//

import SpriteKit
import GameplayKit
import AVFoundation
import CoreAudio
import Speech
import CoreHaptics

class GameScene: SKScene, SFSpeechRecognizerDelegate, HapticFeedback {
    
    // MARK: Properties
    // Haptic Engine & Player State:
    let impactFeedbackgenerator = UIImpactFeedbackGenerator()
    var engine: CHHapticEngine!
    var engineNeedsStart = true
    var continuousPlayer: CHHapticAdvancedPatternPlayer!
    var supportsHaptics: Bool = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.supportsHaptics
    }()
    
    // Tokens to track whether app is in the foreground or the background:
    var foregroundToken: NSObjectProtocol?
    var backgroundToken: NSObjectProtocol?
    
    // Constants
    let initialIntensity: Float = 0.0
    let initialSharpness: Float = 0.0
    
    var timerLabel: SKLabelNode!
    var scoreLabel: SKLabelNode!
    var balloonCounterLabel: SKLabelNode!
    var balloon: SKSpriteNode!
    var scoreBar: SKSpriteNode!
    var pop: SKSpriteNode!
    var ohNo: SKSpriteNode!
    
    var gameTimer = Timer()
    var gameDuration: Int = 60
    var hour: Int = 0
    var min: Int = 0
    var sec: Int = 0
    
    var score: CGFloat = 0
    var balloonCounter: Int = 0
    
    var isBalloonALive = true
    
    var recorder: AVAudioRecorder!
    var levelTimer = Timer()
    let LEVEL_THRESHOLD: Float = -12.0
    
    override func didMove(to view: SKView) {
        // Create & configure the engine before doing anything else, since the user may touch a pad immediately.
        if supportsHaptics {
            createAndStartHapticEngine()
            createContinuousHapticPlayer()
            impactFeedbackgenerator.prepare()
        }
        
        setupBlowDetection()
        setupTimer()
        addObservers()
        
        timerLabel = (childNode(withName: "//TimerLabel") as! SKLabelNode)
        scoreLabel = (childNode(withName: "//Score") as! SKLabelNode)
        balloonCounterLabel = (childNode(withName: "//BalloonCounterLabel") as! SKLabelNode)
        balloon = (childNode(withName: "//Balloon") as! SKSpriteNode)
        scoreBar = (childNode(withName: "//ScoreBar") as! SKSpriteNode)
        
        
        pop = SKSpriteNode(imageNamed: "dapet skor")
        ohNo = SKSpriteNode(imageNamed: "MELETUS")
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        
        if isBalloonALive == false { return }
        
        if let node = self.nodes(at: touch.location(in: self)).first as? SKSpriteNode {
            if node == balloon {
                if score >= 90 && score <= 100 {
                    setupPopAction()
                }
            }
        }
    }
    
   
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
    }
    
   
    override func update(_ currentTime: TimeInterval) {
        // Called before each frame is rendered
        
    }
    
    
    // MARK: Setup Action
    func setupTimer() {
        gameTimer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { [weak self](_) in
            guard let strongSelf = self else {return}
            
            strongSelf.gameDuration -= 1
            
            strongSelf.min = (strongSelf.gameDuration % 3600)/60
            strongSelf.sec = strongSelf.gameDuration % 60
            
            if (strongSelf.min < 10) {
                if strongSelf.sec < 10 {
                    strongSelf.timerLabel.text = "0\(strongSelf.min):0\(strongSelf.sec)"
                }
                else {
                    strongSelf.timerLabel.text = "0\(strongSelf.min):\(strongSelf.sec)"
                }
            }
            else if (strongSelf.gameDuration < 10) {
                strongSelf.timerLabel.text = "0\(strongSelf.min):0\(strongSelf.sec)"
            }
            
            if strongSelf.gameDuration == 0 {
                strongSelf.gameTimer.invalidate()
                strongSelf.setupDurationRunOut()
            }
        })
    }
    
    func setupPopAction() {
        let balloonTexture = SKTexture.init(imageNamed: "Group 4")
        
        impactFeedbackgenerator.impactOccurred(intensity: score / 100)
        
        isBalloonALive = false
        
        balloonCounter += 1
        balloonCounterLabel.text = "\(balloonCounter)"
        
        balloon.run(SKAction.setTexture(pop.texture!, resize: true))
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1),
            SKAction.run {
                self.isBalloonALive = true
                
                self.balloon.xScale = 0.5
                self.balloon.yScale = 0.5
                
                self.scoreBar.yScale = 0
                
                self.score = 0
                
                self.scoreLabel.text = "0"
                
                self.balloon.run(SKAction.setTexture(balloonTexture, resize: true))
            }
        ]))
    }
    
    func setupDurationRunOut() {
        isBalloonALive = false
        
        if supportsHaptics {
            // Stop playing the haptic pattern.
            do {
                try continuousPlayer.stop(atTime: CHHapticTimeImmediate)
            } catch let error {
                print("Error stopping the continuous haptic player: \(error)")
            }
            
            // The background color returns to normal in the player's completion handler.
        }
        
        balloon.setScale(2.5)
        balloon.run(SKAction.setTexture(pop.texture!, resize: true))
        
        // Code for Transition
        let gameOverScene = GameOverScene(fileNamed: "GameOverScene")
        gameOverScene?.scaleMode = scaleMode
        gameOverScene?.score = score
        gameOverScene?.balloonCounter = balloonCounter
        
        let transition = SKTransition.fade(with: .red, duration: 1)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1),
            SKAction.run {
                self.view?.presentScene(gameOverScene!, transition: transition)
            }
        ]))
    }
    
    func setupDeadAction() {
        isBalloonALive = false
        
        if supportsHaptics {
            // Stop playing the haptic pattern.
            do {
                try continuousPlayer.stop(atTime: CHHapticTimeImmediate)
            } catch let error {
                print("Error stopping the continuous haptic player: \(error)")
            }
            
            // The background color returns to normal in the player's completion handler.
        }
        
        impactFeedbackgenerator.impactOccurred(intensity: score / 100)
        
        balloon.run(SKAction.setTexture(ohNo.texture!, resize: true))
        
        // Code for Transition
        let gameOverScene = GameOverScene(fileNamed: "GameOverScene")
        gameOverScene?.scaleMode = scaleMode
        gameOverScene?.score = score
        gameOverScene?.balloonCounter = balloonCounter
        
        let transition = SKTransition.fade(with: .red, duration: 1)
        
        run(SKAction.sequence([
            SKAction.wait(forDuration: 1),
            SKAction.run {
                self.view?.presentScene(gameOverScene!, transition: transition)
            }
        ]))
    }
    
    
    // MARK: Blow Detection
    func setupBlowDetection() {
        // set up the URL for the audio file
        let documents = URL(fileURLWithPath: NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)[0])
        let url = documents.appendingPathComponent("record.caf")

        // make a dictionary to hold the recording settings so we can instantiate our AVAudioRecorder
        let recordSettings: [String: Any] = [
            AVFormatIDKey:              kAudioFormatAppleIMA4,
            AVSampleRateKey:            44100.0,
            AVNumberOfChannelsKey:      2,
            AVEncoderBitRateKey:        12800,
            AVLinearPCMBitDepthKey:     16,
            AVEncoderAudioQualityKey:   AVAudioQuality.max.rawValue
        ]

        // make an AudioSession, set it to PlayAndRecord and make it active
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(AVAudioSession.Category.playAndRecord)
            try audioSession.setActive(true)
            
            // Instantiate an AVAudioRecorder
            try recorder = AVAudioRecorder(url:url, settings: recordSettings)

        } catch {
            return
        }

        recorder.prepareToRecord()
        recorder.isMeteringEnabled = true
        
        // start recording
        recorder.record()

        // instantiate a timer to be called with whatever frequency we want to grab metering values
        levelTimer = Timer.scheduledTimer(timeInterval: 0.02, target: self, selector: #selector(levelTimerCallback), userInfo: nil, repeats: true)
    }
    
    // This selector/function is called every time our timer (levelTime) fires
    @objc func levelTimerCallback() {
        // we have to update meters before we can get the metering values
        recorder.updateMeters()

        let level = recorder.averagePower(forChannel: 0)
        let isLoud = level > LEVEL_THRESHOLD
        
        // The intensity should be highest at the top, opposite of the iOS y-axis direction, so subtract.
        let dynamicIntensity: Float = Float(score) / 100
        print("Dynamic Intensity: \(dynamicIntensity)")
        
        // Dynamic parameters range from -0.5 to 0.5 to map the final sharpness to the [0,1] range.
        let dynamicSharpness: Float = Float(score) / 100
        print("Sharpness Intensity: \(dynamicSharpness)")
        
        if supportsHaptics {
            // Create dynamic parameters for the updated intensity & sharpness.
            let intensityParameter = CHHapticDynamicParameter(parameterID: .hapticIntensityControl,
                                                              value: dynamicIntensity,
                                                              relativeTime: 0)
            
            let sharpnessParameter = CHHapticDynamicParameter(parameterID: .hapticSharpnessControl,
                                                              value: dynamicSharpness,
                                                              relativeTime: 0)
            
            // Send dynamic parameters to the haptic player.
            do {
                try continuousPlayer.sendParameters([intensityParameter, sharpnessParameter],
                                                    atTime: 0)
            } catch let error {
                print("Dynamic Parameter Error: \(error)")
            }
        }

        // do whatever you want with isLoud
        if isLoud {
            /* print("Dis be da level I'm hearin' you in dat mic ")
            print(recorder.averagePower(forChannel: 0))
            print("Do the thing I want, mofo") */
            
            if isBalloonALive == false { return }
            
            balloon.xScale += 0.01
            balloon.yScale += 0.01
            
            // Proceed if and only if the device supports haptics.
            if supportsHaptics {
                // Warm engine.
                do {
                    // Begin playing continuous pattern.
                    try continuousPlayer.start(atTime: CHHapticTimeImmediate)
                    print("Continuous Playback Rate: \(continuousPlayer.playbackRate)")
                } catch let error {
                    print("Error starting the continuous haptic player: \(error)")
                }
            }
            
            if balloon.xScale < 2.5 && balloon.yScale < 2.5 {
                score = (balloon.xScale - 0.5) * 50
                let scoreFormat = String(format: "%.0f", score)
                /* let dinoyScaleFormat = String(format: "%.2f", dino.yScale)
                print("xScale: \(dinoxScaleFormat), yScale: \(dinoyScaleFormat)") */
                //print("Score: \(scoreFormat)")
                scoreLabel.text = scoreFormat
                scoreBar.yScale = score / 100
                
                /* dino.removeAction(forKey: "idleAnimation")
                dino.run(runningAction, withKey: "runningAnimation")
                dinoDirection = 1 */
            }
            else if balloon.xScale >= 2.5 && balloon.yScale >= 2.5 {
                setupDeadAction()
                print("Balloon Modar")
            }
        }
        else if !isLoud {
            if isBalloonALive == false { return }
            
            // Proceed if and only if the device supports haptics.
            if supportsHaptics {
                
                // Warm engine.
                do {
                    // Begin playing continuous pattern.
                    try continuousPlayer.start(atTime: CHHapticTimeImmediate)
                } catch let error {
                    print("Error starting the continuous haptic player: \(error)")
                }
            }
            
            if balloon.xScale > 0.5 && balloon.yScale > 0.5 {
                balloon.xScale -= 0.01
                balloon.yScale -= 0.01
                
                score = (balloon.xScale - 0.5) * 50
                let scoreFormat = String(format: "%.0f", score)
                /* let dinoyScaleFormat = String(format: "%.2f", dino.yScale)
                print("xScale: \(dinoxScaleFormat), yScale: \(dinoyScaleFormat)") */
                //print("Score: \(scoreFormat)")
                scoreLabel.text = scoreFormat
                scoreBar.yScale = score / 100
            }
            
            /* dino.removeAction(forKey: "idleAnimation")
            dino.run(runningAction, withKey: "runningAnimation")
            dinoDirection = -1 */
        }
    }
}
