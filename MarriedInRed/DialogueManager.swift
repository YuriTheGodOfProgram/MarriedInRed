import Foundation
import SpriteKit

enum DialogueStyle {
    case dialogue  
    case thought
}

enum SpeakerPosition {
    case left
    case right
    case none
}

struct DialogueFrame {
    let speaker: String
    let text: String
    let name: String
    let leftImage: String?
    let rightImage: String?
    let speakerPosition: SpeakerPosition
    let style: DialogueStyle
}

// This is a weird one, its for weird things.

final class DialogueManager: SKNode {
    
    static let shared = DialogueManager()
    private var dialogueBox: SKSpriteNode!
    private var leftPortrait: SKSpriteNode?
    private var rightPortrait: SKSpriteNode?

    override init() {
        super.init()
        setupUI(text: "")
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupUI(text: "", fileExtension: "")
    }
    
    var slow = SKAction.wait(forDuration: 0.18)
    
    func setupUI(text: String, fileExtension: String = ".png", Left: String = "", Right: String = "") {
        
//       Model the dialogue after this image:  https://img.itch.zone/aW1hZ2UvMjgwMDEwNi8xNjcxNzY3OS5wbmc=/original/PrFcMu.png

        self.removeAllChildren()
        
        dialogueBox = SKSpriteNode(imageNamed: "UI-TEXT-DIALOGUE")
        dialogueBox.zPosition = 2050
        dialogueBox.setScale(1.22)
        dialogueBox.position = CGPoint(
            x: .zero,
            y: .zero - 10,
        )
        
        addChild(dialogueBox)
        
        // figure out which character dialogues to get
        
        let marginX: CGFloat = 180
        let overlapIntoBox: CGFloat = 20
        let portaitsBaseY = -dialogueBox.size.height / 2 + overlapIntoBox
        
        if !Left.isEmpty{
            
            let leftImage = SKSpriteNode(imageNamed: Left)
            leftImage.zPosition = 900
            leftImage.anchorPoint = CGPoint(x: 0.5, y: -0.12)
            
            leftImage.setScale(1.25)
            
            leftImage.position = CGPoint(
                x: -dialogueBox.size.width / 2 + marginX + 100,
                y: portaitsBaseY + 80
                )

            addChild(leftImage)
            leftPortrait = leftImage
        }

//        Exempt Cecilia so she doesn't become 6'7, and alter the posititons for specific characters, and add a default. Applies for both left and right. 
        
        if !Right.isEmpty{
            
            let rightImage = SKSpriteNode(imageNamed: Right)
            rightImage.zPosition = 900
            rightImage.anchorPoint = CGPoint(x: 0.5, y: -0.12)
            
            rightImage.setScale(1.25)
            
            rightImage.position = CGPoint(
                x: dialogueBox.size.width / 2 - marginX - 100,
                y: portaitsBaseY + 80
                )
            
            addChild(rightImage)
            rightPortrait = rightImage
        }
    }
    
    func stop(){
        removeFromParent()
        removeAllChildren()
    }
}
enum GameStatus {
    case level1, level2, level3
}

enum PlayerEmotion {
    case smile, diappointed, ashamed, distraught, cringe, bored, flustered, glaring, interest, raging, suprised, relieved, anxious, angry, aruging, drained, focused, overwhelmed, startled, stunned, tense, scared
    
    var PlayerEmotions: String {
        switch self {
        case .smile:
            return "Smirk"
        case .diappointed:
            return "Frown"
        case .ashamed:
            return "Ashamed"
        case .distraught:
            return "Distraught"
        case .cringe:
            return "Cringe"
        case .bored:
            return "Bored"
        case .flustered:
            return "Flustered"
        case .glaring:
            return "Glaring"
        case .interest:
            return "Interest"
        case .raging:
            return "Raging"
        case .suprised:
            return "Suprised"
        default:
            return "ERROR"
        }
    }
    
    var ChloeEmotions: String {
        switch self {
        case .relieved:
            return "Relieved"
        case .anxious:
            return "Anxious"
        case .angry:
            return "Angry"
        case .aruging:
            return "Arguing"
        case .drained:
            return "Drained"
        case .focused:
            return "Focused"
        case .overwhelmed:
            return "Overwhelmed"
        case .raging:
            return "Rage"
        case .scared:
            return "Scared"
        case .startled:
            return "Startled"
        case .stunned:
            return "Stunned"
        case .tense:
            return "Tense"
        default:
            return "Chloe doesn't work"
        }
    }
}

class Conversation {
    var charater: String
    var isViewed: Bool
    var dialogues: [Dialogue]
    let id: String
    let lines: [DialogueFrame]
    
    init(charater: String, isViewed: Bool, dialogues: [Dialogue], id: String, lines: [DialogueFrame]) {
        self.id = id
        self.lines = lines
        self.charater = charater
        self.isViewed = isViewed
        self.dialogues = dialogues
    }
}

class Dialogue {
    var character: String
    var text: String
    var emotion: PlayerEmotion
    var isViewed: Bool
    var gameStatus: GameStatus
    
    init(character: String, text: String, emotion: PlayerEmotion, isViewed: Bool, gameStatus: GameStatus) {
        self.character = character
        self.text = text
        self.emotion = emotion
        self.isViewed = isViewed
        self.gameStatus = gameStatus
    }
}
class NPCDialogues {
    
    var currentLevel: GameStatus = .level1
    var currentDialogueIndex: Int = 0
    var currentLeftCharacter: String = "Relieved"
    var currentRightCharacter: String = "Ashamed"
    
    static let Talk = NPCDialogues()
    
    static var chloeDialogues: [GameStatus: [String]] = [
        .level1 : ["Hello! I'm Chloe. I'm here to help you.", "how can I help you", "comeon you can do this"],
        .level2 : ["Hello! I'm Chloe. I'm here to help you."],
        .level3 : ["Hello! I'm Chloe. I'm here to help you."]
    ]
}
