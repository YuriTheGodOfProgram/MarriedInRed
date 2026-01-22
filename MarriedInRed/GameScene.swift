import SpriteKit
import GameplayKit
import Cocoa
//import SwifterSwift
import MediaPlayer

private enum BorderControl: CaseIterable {
    case NewGame
    case Continue
    case Quit
}

private var MainMenu = SKSpriteNode(imageNamed: "Married_in_red_title_screen.webp")


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
        
        MainMenu.position = CGPoint(x: size.width/2, y: size.height/2)
        MainMenu.zPosition = 100
        addChild(MainMenu)

        Sequence = 1
        setTitle(.Continue)
        
//        goToMapScene(after: 20)
        
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
        case 126:
            print("UP-titlescreen")
            moveTitleSelectionUp()
        case 125:
            moveTitleSelectionDown()
            print("DOWN-titlescreen")
        case 36:
            activateSelection()
            print("Selected")
        default:
            print("Awaiting a command sir!")
        }
    }
    
    private var TitleMode: BorderControl = .Continue
    
    private var Sequence: Int = 1
    private var Interact: BorderControl { BorderControl.allCases[Sequence] }
    
    private func setTitle(_ mode: BorderControl){
        guard TitleMode != mode else { return }
        TitleMode = mode
        
        switch mode{
        case .NewGame:
            print("NewGame")
            MainMenu.texture = SKTexture(imageNamed: "Married_in_red_title_screen.webp")
        case .Continue:
            print("Continue")
            MainMenu.texture = SKTexture(imageNamed: "ContinueScreen.tiff")
        case .Quit:
            print("Quit")
            MainMenu.texture = SKTexture(imageNamed: "QuitScreen.tiff")
//            NSApp.terminate(nil)
        }
    }
    
    private func moveTitleSelectionDown() {
        let count = BorderControl.allCases.count
        Sequence = (Sequence + 1) % count
        setTitle(BorderControl.allCases[Sequence])
    }
    
    private func moveTitleSelectionUp() {
        let count = BorderControl.allCases.count
        Sequence = (Sequence - 1 + count) % count
        setTitle(BorderControl.allCases[Sequence])
    }
    
    private func activateSelection() {
        switch Interact {
        case .NewGame:
            goToMapScene(after: 0)
        case .Continue:
            goToMapScene(after: 0) // later: load save
        case .Quit:
            NSApp.terminate(nil)
        }
    }
}
