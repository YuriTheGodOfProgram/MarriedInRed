import Foundation
import SpriteKit
import GameplayKit
import Cocoa
//import SwifterSwift
import WebKit
import MediaPlayer

enum MoveDirection: String {
    case foward
    case down
    case left
    case right
}

private enum UIMode {
    case gameplay
    case dialogue
    case cutscene
}

struct PhysicsCategory {
    static let none: UInt32 = 0 // 0
    static let player: UInt32 = 0b1 // 1
    static let NPC: UInt32 = 0b10 // 
    static let obstacle: UInt32 = 0b100 // 4
    static let trigger: UInt32 = 0b1000 // 8?
}
struct Room {
    let node: SKSpriteNode
    let frame: CGRect
}

let worldNode = SKNode()

class MapScene: SKScene, SKPhysicsContactDelegate {
    
    var chloeAlpha: CGFloat = 1
    var RoomAlpha: CGFloat = 1
    var BobbyAlpha: CGFloat = 1
    
    var player: SKSpriteNode = SKSpriteNode()
    var Guest1: SKSpriteNode = SKSpriteNode()
    var Chloe: SKSpriteNode = SKSpriteNode()
    var Bobby: SKSpriteNode = SKSpriteNode()
    var Mother: SKSpriteNode = SKSpriteNode()
    var cameraNode: SKCameraNode = SKCameraNode()
    
    var Hide: Bool = false
    
    private let cropNode = SKCropNode()
    private let uiFrame = SKSpriteNode(imageNamed: "UI.png")
    private let windowMask = SKSpriteNode(color: .white, size: .zero)
    
    private let gameplayLayer = SKNode()
    private let worldEffect = SKEffectNode()
    private let colorControls = CIFilter(name: "CIColorControls")!
    
    private var dimmableNodes: [SKSpriteNode] = []
    
    var graphs = [String : GKGraph]()
    var isMoving = false
    var movingDirection: MoveDirection?
    var animateAction: SKAction?
    var slow = SKAction.wait(forDuration: 0.19)
    var sprint = false
        
    var rooms: [Room] = []
    var currentRoom: Room?
    
    var roomNames: [String] = []
    
    var teleportationLinks: [String : String] = [
        "WeddingDoor" : "OutsideDoor",
        "OutsideDoor" : "WeddingDoor",
        "BedroomBathroomDoor" : "BathroomDoor",
        "BathroomDoor" : "BedroomBathroomDoor"
    ]
    var teleportionCooldown = false
    
    var fireplaceRoom: SKSpriteNode = SKSpriteNode()
    var bathroom: SKSpriteNode = SKSpriteNode()
    var bedroom: SKSpriteNode = SKSpriteNode()
    var npc: [SKSpriteNode] = []
    var lobby: SKSpriteNode = SKSpriteNode()
    var catering: SKSpriteNode = SKSpriteNode()
    var garden: SKSpriteNode = SKSpriteNode()
    var wedding: SKSpriteNode = SKSpriteNode()
    var kitchen: SKSpriteNode = SKSpriteNode()
    
    var teleportCooldown = false
    
    var LobbyNPCs: SKSpriteNode = SKSpriteNode()
    
    var weddingDoor = SKSpriteNode()
    var outsideDoor = SKSpriteNode()
    var bedroomDoor = SKSpriteNode()
    var bathroomDoor = SKSpriteNode()
    var Fridge = SKSpriteNode()
    
    var depthSortableNodes: [SKSpriteNode] = []
    
    var Paused = SKSpriteNode(imageNamed: "Paused")
    var UI_TO_DO_1 = SKSpriteNode(imageNamed: "RealToDo")
    var TODO = SKSpriteNode(imageNamed: "UI-TO-DO")
    
    let browser = Webpage()
    
    private var lastDetectedRoom: Room?
    
    override func didMove(to view: SKView) {
        
        physicsWorld.contactDelegate = self
        physicsWorld.gravity = .zero
        physicsBody?.contactTestBitMask =
        
        PhysicsCategory.obstacle | PhysicsCategory.trigger
        
        AudioManager.shared.stopMusic()
        AudioManager.shared.playMenuMusic(named: "Wedding")
        
        roomNames = [
            "fireplaceRoom",
            "bathroom",
            "lobby",
            "catering",
            "garden",
            "wedding",
            "kitchen",
            "bedroom",
        ]
        
        for name in roomNames {
            if let node = childNode(withName: name) as? SKSpriteNode {
                node.zPosition = 2
                let room = Room(node: node, frame: node.frame)
                rooms.append(room)
                
                for room in rooms {
                    for child in room.node.children{
                        if let objectNode = child as? SKSpriteNode{
                            depthSortableNodes.append(objectNode)
                        }
                    }
                }
            }
        }
        
        for node in children {
            if let colorNode = node as? SKSpriteNode,
               let name = colorNode.name,
               teleportationLinks.keys.contains(name){
               
            }
        }
        
        for room in rooms {
            dimmableNodes.append(room.node)

            for child in room.node.children {
                if let sprite = child as? SKSpriteNode {
                    dimmableNodes.append(sprite)
                }
            }
        }

        
        self.anchorPoint = .zero
        
        addChild(worldEffect)
        
            player = SKSpriteNode(imageNamed: "Innocent Back Walk 2")
            player.name = "player"
            player.position = CGPoint(x: 1107, y: 37)
            player.zPosition = 5
            player.anchorPoint = CGPoint(x: 0.5, y: 0)
            player.physicsBody = SKPhysicsBody(circleOfRadius: player.size.width/2.82)
            player.physicsBody?.allowsRotation = false
            player.physicsBody?.categoryBitMask = PhysicsCategory.player
            player.physicsBody?.collisionBitMask = PhysicsCategory.obstacle
            player.physicsBody?.contactTestBitMask = PhysicsCategory.obstacle | PhysicsCategory.trigger
            
            player.physicsBody?.affectedByGravity = false
        
            addChild(player)
//        worldNode.addChild(player)
//        worldEffect.addChild(player)
        
        self.camera = cameraNode
        print(cameraNode.frame)
        addChild(cameraNode)
        
        Chloe = SKSpriteNode(imageNamed: "Foward Facing")
        Chloe.position = CGPoint(x: 1107, y: 360)
        Chloe.zPosition = 5
        Chloe.anchorPoint = CGPoint(x: 0.5, y: 0)
        Chloe.physicsBody = SKPhysicsBody(circleOfRadius: Chloe.size.width/2.82)
        Chloe.physicsBody?.allowsRotation = false
        Chloe.physicsBody?.isDynamic = true
        Chloe.physicsBody?.categoryBitMask = PhysicsCategory.NPC
        Chloe.physicsBody?.collisionBitMask = PhysicsCategory.player
        Chloe.physicsBody?.contactTestBitMask = PhysicsCategory.player
        Chloe.physicsBody?.affectedByGravity = false
        
        addChild(Chloe)
//        worldNode.addChild(Chloe)
//        worldEffect.addChild(Chloe)
        
        Bobby = SKSpriteNode(imageNamed: "BobbyFront")
        Bobby.position = CGPoint(x: 1641.378, y: 356.039)
        Bobby.zPosition = 5
        Bobby.anchorPoint = CGPoint(x: 0.5, y: 0)
        Bobby.physicsBody = SKPhysicsBody(circleOfRadius: Bobby.size.width/2.82)
        Bobby.physicsBody?.allowsRotation = false
        Bobby.physicsBody?.isDynamic = true
        Bobby.physicsBody?.categoryBitMask = PhysicsCategory.NPC
        Bobby.physicsBody?.contactTestBitMask = PhysicsCategory.player
        Bobby.physicsBody?.collisionBitMask = PhysicsCategory.player
        Bobby.physicsBody?.affectedByGravity = false
        
        addChild(Bobby)
//        worldNode.addChild(Bobby)
//        worldEffect.addChild(Bobby)
        
        Mother = SKSpriteNode(imageNamed: "Mother Happy")
        Mother.zPosition = 5
        Mother.anchorPoint = CGPoint(x: 0.5, y: 0)
        Mother.position = CGPoint(x: 1530.896, y: 427.742)
        
//        addChild(worldNode)
        
        dimmableNodes.append(player)
        dimmableNodes.append(Chloe)
        dimmableNodes.append(Bobby)
        dimmableNodes.append(Mother)
        
        let lobby = childNode(withName: "lobby") as? SKSpriteNode
        if let door = lobby?.childNode(withName: "WeddingDoor") as? SKSpriteNode {
            weddingDoor = door
        } else {
            print("cannot find wedding door")
        }
        
        let outside = childNode(withName: "wedding") as? SKSpriteNode
        if let door = outside?.childNode(withName: "OutsideDoor") as? SKSpriteNode {
            outsideDoor = door
        } else {
            print("cannot find outside door")
        }
        
        let kitchen = childNode(withName: "kitchen") as? SKSpriteNode
        if let FoodStorage = kitchen?.childNode(withName: "Fridge") as? SKSpriteNode{
            Fridge = FoodStorage
        } else {
            print("'Fridges don't exist yet! Its 1824!' 'Its 1824 how do you know what a fridge is?!'")
        }
        
        // SET UP ALL TELEPORT DOORS
        for (source, _) in teleportationLinks {
            if let door = self.childNode(withName: "//\(source)") as? SKSpriteNode {
                
                if door.physicsBody == nil {
                    door.physicsBody = SKPhysicsBody(rectangleOf: door.size)
                }
                
                door.physicsBody?.isDynamic = false
                door.physicsBody?.affectedByGravity = false
                door.physicsBody?.allowsRotation = false
                
                door.physicsBody?.categoryBitMask = PhysicsCategory.trigger
                door.physicsBody?.contactTestBitMask = PhysicsCategory.player
                door.physicsBody?.collisionBitMask = PhysicsCategory.none
            }
        }
        
        
        func linkDoors(_ a: String, _ b: String) {
            teleportationLinks[a] = b
            teleportationLinks[b] = a
        }
        
        linkDoors("WeddingDoor", "OutsideDoor")
        linkDoors("BathroomDoor", "BedroomBathroomDoor")
        
        depthSortableNodes.append(Mother)
        
        depthSortableNodes.append(Chloe)
        
        depthSortableNodes.append(Bobby)
        
        print(depthSortableNodes.count)
        for node in depthSortableNodes {
            print(node.name ?? "no name")
        }
        
//    buildGameplayLayer()
    setupFramedUI()
        
    }
    
    func didBegin(_ contact: SKPhysicsContact) {
        
        guard let A = contact.bodyA.node,
              let B = contact.bodyB.node else { return }
        
        let nodes = [A, B]
        
        for n in nodes {
            guard let doorName = n.name else { continue }
            
            if let destinationName = teleportationLinks[doorName],
               let destinationDoor = self.childNode(withName: "//\(destinationName)") {
                
                let otherNode = (n == A ? B : A)
                if otherNode.name != "player" { continue }
                
                let targetPos = CGPoint(
                    x: destinationDoor.position.x,
                    y: destinationDoor.position.y
                )
                
                teleportPlayer(player: otherNode, to: targetPos)
                
                print("TELEPORT: \(doorName) -> \(destinationName)")
            }
        }
    }
    
    func teleportPlayer(player: SKNode, to position: CGPoint) {
        
        if teleportCooldown { return }
        teleportCooldown = true
        
        let fadeOut = SKAction.fadeOut(withDuration: 0.12)
        let move = SKAction.run { player.position = position }
        let fadeIn = SKAction.fadeIn(withDuration: 0.12)
        
        player.run(SKAction.sequence([fadeOut, move, fadeIn,]))
        
        let coolDown = SKAction.sequence([
            SKAction.wait(forDuration: 0.25),
            SKAction.run { self.teleportCooldown = false }
        ])
        self.run(coolDown)
    }
    
    func animatePlayer(with images: [String]) {
        
        let textures = images.map { SKTexture(imageNamed: $0) }
        
        // Create an array of actions for each texture combined with a delay
        var actions: [SKAction] = []
        
        for texture in textures {
            actions.append(SKAction.setTexture(texture))
            actions.append(slow) // Add the wait duration after setting the texture
        }
        
        // Create the sequence of actions
        let sequence = SKAction.sequence(actions)
        let repeatAction = SKAction.repeatForever(sequence)
        
        // Stop any current actions before starting a new one
        
        player.removeAllActions()
        player.run(repeatAction)
    }
    
    func moveRight() {
        
        let images = ["Innocent Right Walk 1", "Innocent Right Walk 2", "Innocent Right Walk 3", "Innocent Right Walk 4", "Innocent Right Walk 5"]
        
        animatePlayer(with: images)
        
        var Movement = SKAction.move(by: CGVector(dx: 10, dy: 0), duration: 0.1)
        let Constant = SKAction.repeatForever(Movement)
        player.run(Constant)
        
        if sprint == true{
            Movement = SKAction.move(by: CGVector(dx: 30, dy: 0), duration: 0.1)
            player.run(Constant)
        }
    }
    func moveLeft(){
        
        let images = ["Innocent Left Walk 1", "Innocent Left Walk 2", "Innocent Left Walk 3", "Innocent Left Walk 4", "Innocent Left Walk 5"]
        
        animatePlayer(with: images)
        
        var Movement = SKAction.move(by: CGVector(dx: -10, dy: 0), duration: 0.1)
        let Constant = SKAction.repeatForever(Movement)
        player.run(Constant)
        
        if sprint == true{
            Movement = SKAction.move(by: CGVector(dx: -30, dy: 0), duration: 0.1)
            player.run(Constant)
        }
    }
    func moveFoward(){
        let images = ["Innocent Back Walk 1", "Innocent Back Walk 2", "Innocent Back Walk 3", "Innocent Back Walk 4", "Innocent Back Walk 5"]
        
        animatePlayer(with: images)
        
        var Movement = SKAction.move(by: CGVector(dx: 0, dy: 10), duration: 0.1)
        let Constant = SKAction.repeatForever(Movement)
        player.run(Constant)
        
        if sprint == true{
            Movement = SKAction.move(by: CGVector(dx: 0, dy: 30), duration: 0.1)
            player.run(Constant)
        }
    }
    func moveBackward(){
        let images = ["Innocent Front Walk 1", "Innocent Front Walk 2", "Innocent Front Walk 3", "Innocent Front Walk 4", "Innocent Front Walk 5"]
        
        animatePlayer(with: images)
        
        var Movement = SKAction.move(by: CGVector(dx: 0, dy: -10), duration: 0.1)
        let Constant = SKAction.repeatForever(Movement)
        player.run(Constant)
        
        if sprint == true{
            Movement = SKAction.move(by: CGVector(dx: 0, dy: -30), duration: 0.1)
            player.run(Constant)
        }
    }
    
    
    override func keyDown(with event: NSEvent){
        sprint = event.modifierFlags.contains(.shift)
        switch event.keyCode{
            
        case 0124:
            
            if !isMoving{
                isMoving = true
                print("Right!")
                moveRight()
            }; if ((0124 & 36) != 0){
                sprint = true
            }
            
        case 0123:
            
            if !isMoving{
                isMoving = true
                print("Left!")
                moveLeft()
            }; if ((0123 & 36) != 0){
                sprint = true
            }
            
        case 126:
            
            if !isMoving{
                isMoving = true
                print("Foward!!")
                moveFoward()
            }; if ((126 & 36) != 0){
                sprint = true
            }
            
        case 125:
            
            if !isMoving{
                isMoving = true
                print("Down at will commander!")
                moveBackward()
            }; if ((125 & 36) != 0){
                sprint = true
            }
            
//        case 48:
//            
//            pause(name: Paused)
            
//            Make it more interactive
            
        case 17:
            
            pause(name: UI_TO_DO_1)
//            Make it more interactive
            
        case 25:
            
            if browser.isOpen{
                browser.close()
                self.view?.window?.makeFirstResponder(self.view)
                self.isPaused = false
                print("Browser Closed")
            } else {
                if let gameView = self.view {
                    self.isPaused = true
                    browser.open(url: "https://shop.app/m/darktiger?dynamicFilterVAvailability=%7B%22available%22%3Atrue%7D&sortBy=MOST_SALES", in: gameView)
                    print("Browser Opened")
                    AudioManager.shared.stopMusic()
                }
            }
            
        case 28:
            
            if browser.isOpen{
                browser.close()
                self.view?.window?.makeFirstResponder(self.view)
                self.isPaused = false
                print("Broswer Closed")
            } else {
                if let gameView = self.view {
                    self.isPaused = true
                    browser.open(url: "https://music.apple.com/us/playlist/stan-assassination-classroom/pl.u-vxy697juWKepqGx", in: gameView)
                    print("Browser Opened")
                    AudioManager.shared.stopMusic()
                }
            }
            
        case 26:
            
            if browser.isOpen{
                browser.close()
                self.view?.window?.makeFirstResponder(self.view)
                self.isPaused = false
                print("Broswer Closed")
            } else {
                if let gameView = self.view {
                    self.isPaused = true
                    browser.open(url: "https://nick088official.github.io/Married-in-Red-Web-Port/www/", in: gameView)
                    print("Case 26 tapped")
                    AudioManager.shared.stopMusic()
                }
            }
            
        case 22:
            
            if browser.isOpen{
                browser.close()
                self.view?.window?.makeFirstResponder(self.view)
                self.isPaused = false
                print("Broswer Closed")
            } else {
                if let gameView = self.view {
                    self.isPaused = true
                    browser.open(url: "https://youtu.be/rvskMHn0sqQ?si=44kpe7S9NgwD7UNh", in: gameView)
                    print("Browser Opened")
                    AudioManager.shared.stopMusic()
                }
            }
            
        case 23:
            
            if browser.isOpen{
                browser.close()
                self.view?.window?.makeFirstResponder(self.view)
                self.isPaused = false
                print("Broswer Closed")
            } else {
                if let gameView = self.view {
                    self.isPaused = true
                    browser.open(url: "https://soundcloud.com/billieeilish", in: gameView)
                    print("Browser Opened")
                    AudioManager.shared.stopMusic()
                }
            }
            
        case 21:
            
            if browser.isOpen{
                browser.close()
                self.view?.window?.makeFirstResponder(self.view)
                self.isPaused = false
                print("Broswer Closed")
            } else {
                if let gameView = self.view {
                    self.isPaused = true
                    browser.open(url: "https://www.desmos.com/calculator", in: gameView)
                    print("Browser Opened")
                    AudioManager.shared.stopMusic()
                }
            }
            
        case 29:
            
            if browser.isOpen{
                browser.close()
                self.view?.window?.makeFirstResponder(self.view)
                self.isPaused = false
                print("Broswer Closed")
            } else {
                if let gameView = self.view {
                    self.isPaused = true
                    browser.open(url: "https://uquiz.com/quiz/kb7WUM/do-you-support-palestine-or-israel", in: gameView)
                    print("Browser Opened")
                    AudioManager.shared.stopMusic()
                }
            }
            
        case 20:
            
            if browser.isOpen{
                browser.close()
                self.view?.window?.makeFirstResponder(self.view)
                self.isPaused = false
                print("Broswer Closed")
            } else {
                if let gameView = self.view {
                    self.isPaused = true
                    browser.open(url: "https://www.cfr.org/report/conflicts-watch-2026", in: gameView)
                    print("Browser Opened")
                    AudioManager.shared.stopMusic()
                }
            }
            
        case 19:
            
            if browser.isOpen{
                browser.close()
                self.view?.window?.makeFirstResponder(self.view)
                self.isPaused = false
                print("Broswer Closed")
            } else {
                if let gameView = self.view {
                    self.isPaused = true
                    browser.open(url: "https://youtu.be/Ub-gsF1zFTE?si=BwSnrmoG4ZajHhuv", in: gameView)
                    print("Browser Opened")
                    AudioManager.shared.stopMusic()
                }
            }
            
        case 18:
            
            if browser.isOpen{
                browser.close()
                self.view?.window?.makeFirstResponder(self.view)
                self.isPaused = false
                print("Broswer Closed")
            } else {
                if let gameView = self.view {
                    self.isPaused = true
                    browser.open(url: "https://www.buzzfeed.com/angelicaamartinez/soul-aesthetic-personality-quiz?utm_source=dynamic&utm_campaign=bfsharecopy", in: gameView)
                    print("Browser Opened")
                    AudioManager.shared.stopMusic()
                }
            }
            
//            Change a whole bunch of links, and add buttons for them.
            
        case 7:
            
            self.removeAction(forKey: "DialogueSequence")
            DialogueManager.shared.stop()
            browser.close()
            self.view?.window?.makeFirstResponder(self.view)
            self.isPaused = false
            print("Browser Closed")
            
            setUIMode(.gameplay)

            clearSceneDim()
            
        case 6:
            
            let HoldUp = SKAction.wait(forDuration: 4)
            
            if player.frame.intersects(Chloe.frame){
                player.removeAllActions()
                isMoving = false
                
                setUIMode(.dialogue)
                
                animateSceneDim(to: 0.45)

                if DialogueManager.shared.parent == nil {
                    cameraNode.addChild(DialogueManager.shared)
                }
                
                let seq = SKAction.sequence([
                    SKAction.run {
                        DialogueManager.shared.setupUI(text: "Oh...you really...dressed up", speakerName: "Chloe", Left: "Ashamed", Right: "Anxious", )
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "Anything for my old...friend. \nOn such a special day its easy to forget", speakerName: "Rachel", Left: "Cringe", Right: "Focused")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "Forget...?", speakerName: "Chloe", Left: "Suprised", Right: "Startled")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "", speakerName: "No one", Left: "Frown", Right: "Scared")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "Rachel don't do anyhting bad", speakerName: "Chloe", Left: "Smirk", Right: "Arguing")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "Why would you assume its me?", speakerName: "Rachel", Left: "Suprised", Right: "Drained")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "", speakerName: "No one", Left: "Cringe", Right: "Focused")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "Fine, I won't do anyhting...too bad", speakerName: "Rachel", Left: "Interest", Right: "Focused")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "Well...I must attend to other guests\n...but I'll introduce you to Bobby first...", speakerName: "Chloe", Left: "Smirk", Right: "Anxious")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "Bobby!", speakerName: "Chloe", Left: "Flustered", Right: "Startled")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "In the flesh", speakerName: "Bobby", Left: "Bored", Right: "Neutral")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "I'd like you more in a stew", speakerName: "Rachel", Left: "Glaring", Right: "Shocked")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "Bobby...why is she here?", speakerName: "Chloe", Left: "Glaring", Right: "Scared")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "I invited Rachel.\nYou spoke about her all of the time", speakerName: "Bobby", Left: "Suprised", Right: "Dicussing")
                    },
                    HoldUp,
                    SKAction.run {
                        DialogueManager.shared.setupUI(text: "I took over the invites since you got suspended\nFor giving a newborn a horse tranqulizer", speakerName: "Bobby", Left: "Suprised", Right: "Dicussing")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "I'm going to check on the BridesMaid...\nSpeak with her, laugh, get a bunker...", speakerName: "Chloe", Left: "Frown", Right: "Overwhelmed")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "Was it something I said?\nOh I must've forgotten to say hello", speakerName: "Rachel", Left: "Suprised", Right: "")
                    }
                ])
                
                self.run(seq)
                
                self.removeAction(forKey: "DialogueSequence")
                
                self.run(seq, withKey: "DialogueSequence")
                                
            }
            if player.frame.intersects(Bobby.frame){
                player.removeAllActions()
                isMoving = false
                
                animateSceneDim(to: 0.45)
                
                setUIMode(.dialogue)

                if DialogueManager.shared.parent == nil{
                    cameraNode.addChild(DialogueManager.shared)
                }
                
                let seq = SKAction.sequence([
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "", speakerName: "", Left: "Suprised", Right: "Dicussing")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "", speakerName: "", Left: "Cringe", Right: "Nervous")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "", speakerName: "", Left: "Cringe", Right: "Neutral")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "", speakerName: "", Left: "Smirk", Right: "Shocked")
                    },
                    HoldUp,
                    SKAction.run{
                        DialogueManager.shared.setupUI(text: "", speakerName: "", Left: "Bored", Right: "Smiling")
                    }
            ])
                
                self.run(seq)
                
                self.removeAction(forKey: "DialogueSequence")
                
                self.run(seq, withKey: "DialogueSequence")
                
            }
            if player.frame.intersects(Mother.frame){
//                I hope this shows up in the other computer. This is a test.
//                Add the mother. 
            }
        default:
            print("keydown: \(event.characters!) keycode: \(event.keyCode)")
        }
    }
    
    override func keyUp(with event: NSEvent){
        isMoving = false
        sprint = false
        player.removeAllActions()
    }
    
    func Dark(ShadowIndex: Int){
//            This is supposed to be a flexible function to dim everything. Not alpha.
    }
    
    func setTodoImage(_ imageName: String) {
        TODO.texture = SKTexture(imageNamed: imageName)
    }
    
    func setPaused(_ imageName: String) {
        Paused.texture = SKTexture(imageNamed: imageName)
    }
        
    func pause(name: SKSpriteNode) {
            
            if self.isPaused {
                
                self.isPaused = false
                
                setTodoImage("UI-TO-DO")

                if let overlay = cameraNode.childNode(withName: "OverlayID") {
                    overlay.removeFromParent()
                }
                
                player.alpha = 1.0
                Chloe.alpha = 1.0
                Bobby.alpha = 1.0
                currentRoom?.node.alpha = 1.0
                TODO.alpha = 1.0

            } else {
// Add the scratch marks on the TODOLIST to track progress, and allow for the list to change to the second list when complete.
                name.name = "OverlayID"
                name.zPosition = 1000
                name.setScale(1.0)
                name.position = CGPoint.zero
                
                if name.parent == nil {
                    cameraNode.addChild(name)
                }
                
                for room in rooms {
                    room.node.alpha = 0.0
                }
                Chloe.alpha = 0.0
                player.alpha = 0.0
                Bobby.alpha = 0.0
                
                setTodoImage("UI-TO-DO-3")
                
                self.isPaused = true
            }
        }
    
    func animateCamera(room: SKSpriteNode){
        
        for room in rooms {
            room.node.alpha = 0.0
        }

        if room.frame.contains(player.position){
            cameraNode.position = room.position
            cameraNode.setScale(0.82)
        }
    }
    
    override func update(_ currentTime: TimeInterval) {
        
        let lerpFactor: CGFloat = 0.125
        
        var foundRoom = false
                
//        cameraNode.position.x += (player.position.x - cameraNode.position.x) * lerpFactor
        
//        updateCameraSmart()
        
        for room in rooms {
//            cameraNode.position.x += (room.node.frame.minX - cameraNode.position.x) * lerpFactor
            cameraNode.position.y += (player.position.y - cameraNode.position.y) * lerpFactor
            let stableMinX = room.node.position.x - room.node.size.width * room.node.anchorPoint.x
            cameraNode.position.x += (stableMinX - cameraNode.position.x) * lerpFactor
            }
        
        for room in rooms {
            animateCamera(room: room.node)
            cameraNode.position.y += (player.position.y - cameraNode.position.y) * lerpFactor
//            let stableMinY = room.node.position.y - room.node.size.height * room.node.anchorPoint.y
//            cameraNode.position.y += (stableMinY - cameraNode.position.y) * lerpFactor
        }
        
        if let currentRoom = currentRoom {
            Chloe.alpha = currentRoom.frame.contains(Chloe.position) ? chloeAlpha : 0.0
            Bobby.alpha = currentRoom.frame.contains(Bobby.position) ? BobbyAlpha : 0.0
        }
        
        for room in rooms {
            if room.frame.contains(player.position) {
                currentRoom = room
                lastDetectedRoom = currentRoom
                foundRoom = true
                break
            }
            else {
            foundRoom = false
            }
        }
        
//        currentRoom?.node.alpha = 1
        currentRoom?.node.alpha = RoomAlpha
        
        updatePlayerzPosition()
        
        if !foundRoom {
            cameraNode.position = player.position
        }
    }
    
    func updatePlayerzPosition() {
        
//        Make it work for NPCs including Chloe, and depthSortableNodes
        
        let playerZ: CGFloat = 5.0
        player.zPosition = playerZ
        
        let frontZ: CGFloat = 6.0
        let backZ: CGFloat = 2.1
        
        for node in depthSortableNodes{
            
            if node == player {continue}
            
            guard let scene = node.scene, let parent = node.parent else { continue }
                        
            let nodeBottomLeft = CGPoint(x: node.frame.minX, y: node.frame.minY)
            let ARES = scene.convert(nodeBottomLeft, from: parent)
            
            let TRON = ARES.y
            
            _ = scene.convert(node.position, from: parent)
            
            if player.position.y > TRON{
                node.zPosition = frontZ
            } else {
                node.zPosition = backZ
            }
        }
    }
    
    private func setupFramedUI() {
        
        cropNode.removeFromParent()
        uiFrame.removeFromParent()
        TODO.removeFromParent()
        
        self.camera = cameraNode
        if cameraNode.parent == nil { addChild(cameraNode) }
        
        cropNode.zPosition = 10
        cameraNode.addChild(cropNode)
        
        windowMask.position = CGPoint(x: 0, y: 0)
        windowMask.position = .zero
        cropNode.maskNode = windowMask
        
        cropNode.addChild(worldNode)
        
        uiFrame.zPosition = 2000
        uiFrame.position = .zero
        cameraNode.addChild(uiFrame)
                
        let sx = size.width / uiFrame.size.width
        let sy = size.height / uiFrame.size.height
        let uiScale = min(sx, sy)
        uiFrame.setScale(uiScale)
        
        TODO.removeFromParent()
        TODO.zPosition = 2009
        TODO.setScale(uiScale)
        
        let bottomY = -(size.height * 0.5) + (TODO.size.height * TODO.xScale * 0.5) - 90
        
        TODO.position = CGPoint(x: 0, y: bottomY)
        
        cameraNode.addChild(TODO)
        
        setUIMode(.gameplay)
    }
    
    private var uiMode: UIMode = .gameplay
    
    private func setUIMode(_ mode: UIMode) {
        guard uiMode != mode else { return }
        uiMode = mode

        switch mode {
        case .gameplay:
            uiFrame.texture = SKTexture(imageNamed: "UI.png")
            TODO.isHidden = false

        case .dialogue:
            uiFrame.texture = SKTexture(imageNamed: "UI-DIALOGUE.png")
            TODO.isHidden = true

        case .cutscene:
            uiFrame.texture = SKTexture(imageNamed: "UI-CG.png")
            TODO.isHidden = true
        }
    }

    
    private let dimColor = SKColor(white: 0.0, alpha: 1.0) // true black

    func dimRoom(_ room: SKSpriteNode, amount: CGFloat) {
        room.color = dimColor
        room.colorBlendFactor = amount
    }

    func dimAllRooms(amount: CGFloat) {
        for r in rooms {
            r.node.colorBlendFactor = 0.0
            r.node.color = .white
//            dimRoom(r.node, amount: amount)
        }
    }
    
    func clearSceneDim() {
        for node in dimmableNodes {
            node.removeAction(forKey: "Dim")
            node.colorBlendFactor = 0.0
        }
    }

    func animateSceneDim(to amount: CGFloat, duration: TimeInterval = 0.25) {
        for node in dimmableNodes {
            node.color = dimColor
            node.removeAction(forKey: "DimAction")

            node.run(
                .customAction(withDuration: duration) { n, t in
                    let p = CGFloat(t) / CGFloat(duration)
                    (n as! SKSpriteNode).colorBlendFactor = amount * p
                },
                withKey: "DimAction"
            )
        }
    }

    
    func DialogueDemo() {
        
        var rest = SKAction.wait(forDuration: 1.2)
        
        if DialogueManager.shared.parent == nil {
            cameraNode.addChild(DialogueManager.shared)
        }

//        DialogueManager.shared.setupUI(text: "", Left: "Smirk", Right: "Anxious")

        // Slower rest so it doesn’t flash
        DialogueManager.shared.setupUI(
            text: "",
            speakerName: "",
            Left: "Smirk",
            Right: "Anxious",
        )
    }
}
