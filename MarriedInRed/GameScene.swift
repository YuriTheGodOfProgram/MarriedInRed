import SpriteKit
import GameplayKit
import Cocoa
//import SwifterSwift
import MediaPlayer

// This is a comment, to test

/*
 Don't push broken code
 Commit and push after each feature or refactor
 */

class GameScene: SKScene{
    
    var canTransition = false
    
    override func didMove(to view: SKView) {
        
//        Change this so when canTransition = true, then it goes to map scene
        
//        Incorporate a system for a UI scene in GameScene, and for a textbox with instructions to display
        
        goToMapScene(after: 20)
        
    }
    
    func goToMapScene(after delay: TimeInterval){
        
        AudioManager.shared.stopMusic()
        let wait = SKAction.wait(forDuration: delay)
        let transitionAction = SKAction.run { [weak self] in
            guard let self = self else{
                return
            }
            
            if let mapScene = MapScene(fileNamed: "MapScene"){
                
                AudioManager.shared.stopMusic()
                
                mapScene.size = self.size
                mapScene.scaleMode = .aspectFit
                
                let transition = SKTransition.fade(withDuration: 1.0)
                
                self.view?.presentScene(mapScene, transition: transition)
                
            } else {
                print("Unable to present scene")
            }
        }
        run(SKAction.sequence([wait, transitionAction]))
    }
    override func keyDown(with event: NSEvent){
        
        switch event.keyCode{
        case 6:
            goToMapScene(after: 0)
            print("Z")
            canTransition = true
        default:
            print("Awaiting a command sir!")
        }
    }
}
