//
//  ViewController.swift
//  MarriedInRed
//
//  Created by YuriTheGodOfProgram on 11/13/25.
//

import Cocoa
import SpriteKit
import GameplayKit
import SwiftUI

class ViewController: NSViewController {
    
    @IBOutlet var skView: SKView!
    
    //    I think I'm supposed to add a on click here, so the UIs work.
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let view = self.skView {
            // Load the SKScene from 'GameScene.sks'
            if let scene = SKScene(fileNamed: "GameScene") {
                // Set the scale mode to scale to fit the window
                
                scene.scaleMode = .aspectFit
                
                //                scene.scaleMode = .resizeFill
                
                // Present the scene
                view.presentScene(scene)
            }
            
            view.ignoresSiblingOrder = true
            view.showsFPS = false
            view.showsNodeCount = false
            
        }
    }
}
