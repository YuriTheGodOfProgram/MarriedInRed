import SpriteKit
import GameplayKit
import Cocoa
//import SwifterSwift
import MediaPlayer

extension Notification.Name {
    static let BlackMirrorDidFinish = Notification.Name("BlackMirrorDidFinish")
}

private enum BorderControl: CaseIterable {
    case NewGame
    case Continue
    case Quit
}

enum Intro{
    case IntroPage
    case Warnings
    case Controls
    case Humor 
}

private var SKS: Intro = .IntroPage
private var IntroSprite = SKSpriteNode(imageNamed: "IntroPage")
private var MainMenu = SKSpriteNode(imageNamed: "Married_in_red_title_screen.webp")


// This is a comment, to test

/*
 Don't push broken code
 Commit and push after each feature or refactor
 */

class GameScene: SKScene{
    
    var canTransition = false
    private var canProceedAfterBlackMirror = false
    override func didMove(to view: SKView) {
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleBlackMirrorFinished), name: .BlackMirrorDidFinish, object: nil)
        
//        Incorporate a system for a UI scene in GameScene, and for a textbox with instructions to display
//        Things should pop up, textboxes. Likely utilizing thought dialogue.
        
        MainMenu.position = CGPoint(x: size.width/2, y: size.height/2)
        MainMenu.zPosition = 100
        addChild(MainMenu)
        Sequence = 1
        setTitle(.Continue)
        
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
        case 6: // Z
            if canProceedAfterBlackMirror {
                goToMapScene(after: 0)
            } else {
                print("Z")
                canTransition = true
            }
        case 126:
            print("UP-titlescreen")
            moveTitleSelectionUp()
        case 125:
            moveTitleSelectionDown()
            print("DOWN-titlescreen")
        case 36, 76, 56, 49: // Enter, Numpad Enter, Shift, Space
            if canProceedAfterBlackMirror {
                goToMapScene(after: 0)
                print("Proceeding after BlackMirror")
            } else {
                activateSelection()
                print("Selected")
            }
        default:
            print("Awaiting a command sir!")
        }
    }
    
    override func mouseDown(with event: NSEvent) {
        if canProceedAfterBlackMirror {
            goToMapScene(after: 0)
        } else {
            super.mouseDown(with: event)
        }
    }
    
    @objc private func handleBlackMirrorFinished() {
        // Allow proceeding once BlackMirror indicates completion
        canProceedAfterBlackMirror = true
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
    
    private var RunningMan = false
    private var _2012 = false
    private var VforVandetta = false
    private func activateSelection() {
        
        switch Interact {
        case .NewGame:
            if !RunningMan {
                RunningMan = true
                _1984(node: MainMenu)
            }
        case .Continue:
            goToMapScene(after: 0)
        case .Quit:
            NSApp.terminate(nil)
        }
    }
    
    private func _1984 (node: SKSpriteNode){
//        This should instead only proceed if 'Z' is tapped
        let Gattaca = [
            "IntroPage",
            "Warning",
            "Controls",
        ]
        
        let AnimalFarm = Gattaca.map { SKTexture(imageNamed: $0) }
        
        SKTexture.preload(AnimalFarm) { [weak self] in
            guard let self else {return} }
        
        let Divergant = SKAction.animate(with: AnimalFarm, timePerFrame: 5, resize: false, restore: false)
        
        let Fahrenheit_451 = SKAction.run{
            print("Intro is complete")
//            self.goToMapScene(after: 5)
            self.DeathStranding(after: 5)
        }
        
        node.run(.sequence([Divergant, Fahrenheit_451]), withKey: "IntroSequence")
        
    }
    
    private func DeathStranding(after delay: TimeInterval){
        
        BlackMirror.shared.attach(to: self)
        
        BlackMirror.shared.present(lines: [
            "My friend Chloe from university is getting married.",
            "We were studying to become doctors.",
            "I haven’t seen her in a Long time."
        ])
        
        canProceedAfterBlackMirror = true
        
// self.goToMapScene(after: 999999999999)
// Wait for BlackMirror to finish (notification will set the flag). Optionally, you can still auto-advance after a delay if desired:
        
        run(.wait(forDuration: delay)) { [weak self] in
            guard let self else { return }
            if self.canProceedAfterBlackMirror {
                self.goToMapScene(after: CGFLOAT_MAX)
            } else {
                print("BlackMirror not finished yet; waiting for user input after completion")
            }
        }
    
    }
    
}
