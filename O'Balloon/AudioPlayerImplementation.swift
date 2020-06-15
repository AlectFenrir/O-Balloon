//
//  AudioPlayerImpl.swift
//  O'Balloon
//
//  Created by Rayhan Martiza Faluda on 15/06/20.
//  Copyright © 2020 Rayhan Martiza Faluda. All rights reserved.
//

import Foundation
import AVKit

public protocol SoundFile {
    var filename: String { get }
    var type: String { get }
}

public struct Music: SoundFile {
    public var filename: String
    public var type: String
}

public struct Effect: SoundFile {
    public var filename: String
    public var type: String
}

protocol AudioPlayer {
    var musicVolume: Float { get set }
    func play(music: Music)
    func pause(music: Music)
    
    var effectsVolume: Float { get set }
    func play(effect: Effect)
}

struct Audio {
    struct MusicFiles {
        static let bgm = Music(filename: "O'balloon_BGM", type: "aac")
    }
    
    struct EffectFiles {
        static let blow = Effect(filename: "O'balloon_blow", type: "m4a")
        static let gameover = Effect(filename: "O'balloon_Gameover", type: "m4a")
        static let dead = Effect(filename: "O'balloon_pop", type: "m4a")
        static let pop = Effect(filename: "O'balloon_success", type: "m4a")
    }
}

class AudioPlayerImplementation {
    private var currentMusicPlayer: AVAudioPlayer?
    private var currentEffectPlayer: AVAudioPlayer?
    var musicVolume: Float = 1.0 {
        didSet { currentMusicPlayer?.volume = musicVolume }
    }
    var effectsVolume: Float = 1.0
}

extension AudioPlayerImplementation: AudioPlayer {
    func play(music: Music) {
        currentMusicPlayer?.stop()
        guard let newPlayer = try? AVAudioPlayer(soundFile: music) else { return }
        newPlayer.volume = musicVolume
        newPlayer.play()
        currentMusicPlayer = newPlayer
    }
    
    func pause(music: Music) {
        currentMusicPlayer?.pause()
    }
    
    func play(effect: Effect) {
        guard let effectPlayer = try? AVAudioPlayer(soundFile: effect) else { return }
        effectPlayer.volume = effectsVolume
        effectPlayer.play()
        currentEffectPlayer = effectPlayer
    }
}

extension AVAudioPlayer {
    public enum AudioPlayerError: Error {
        case fileNotFound
    }
    
    public convenience init(soundFile: SoundFile) throws {
        guard let url = Bundle.main.url(forResource: soundFile.filename, withExtension: soundFile.type) else { throw AudioPlayerError.fileNotFound }
        try self.init(contentsOf: url)
    }
}
