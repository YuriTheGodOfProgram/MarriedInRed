//
//  AudioManager.swift
//  MarriedInRed

import Foundation
import AVFoundation

class AudioManager: NSObject, AVAudioPlayerDelegate{
    static let shared = AudioManager()
    private var musicplayer: AVAudioPlayer?
    
//    Add SFX sounds for objects, and events
    
    var isPlaying: Bool{
        return musicplayer?.isPlaying ?? false
    }
    
    private override init(){}
    func playMenuMusic(named name: String, fileExtension: String = "ogg" , loops: Int = 0, volume: Float = 0.5) {
           stopMusic()
        
        guard let url = Bundle.main.url(forResource: name, withExtension: fileExtension) else {
            print("Error: Could not find music file")
            return
        }
            do {
                    musicplayer = try AVAudioPlayer(contentsOf: url)
                    musicplayer?.delegate = self
                    musicplayer?.numberOfLoops = loops    // loop forever
                    musicplayer?.volume = volume
                    musicplayer?.prepareToPlay()
                    musicplayer?.play()

                    print("Menu music started.")
                
                } catch {
                    print("ERROR loading music:", error)
                }
       }
    
    func stopMusic(fadeDuration: TimeInterval = 0.5) {
        musicplayer?.stop()
        musicplayer = nil
        print("Music stopped & destroyed.")
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        print("Music finished playing.")
        stopMusic()
    }
}
