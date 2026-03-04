//
//  BlackMirror.swift
//  MarriedInRed

import SpriteKit
import Foundation
import MediaPlayer
import Cocoa
import GameplayKit

struct BlackBox{
    let style: DialogueStyle
}

struct Line{
    let text: String
}

final class BlackMirror: SKNode {

    static let shared = BlackMirror()

    private let background = SKSpriteNode(color: .black, size: .zero)
    private let textLabel = SKLabelNode(fontNamed: "HBIOS-SYS")

    private var lines: [String] = []
    private var currentIndex = 0
    private(set) var isActive = false

    private override init() {
        super.init()

        zPosition = 10_000
        isUserInteractionEnabled = true

        // Background setup
        background.alpha = 0
        addChild(background)

        // Text setup (centered like reference)
        textLabel.fontSize = 22
        textLabel.fontColor = .white
        textLabel.horizontalAlignmentMode = .center
        textLabel.verticalAlignmentMode = .center
        textLabel.numberOfLines = 0
        textLabel.alpha = 0

        addChild(textLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func attach(to scene: SKScene) {
        removeFromParent()
        scene.addChild(self)

        background.size = scene.size
        background.position = CGPoint(
            x: scene.size.width / 2,
            y: scene.size.height / 2
        )

        textLabel.position = CGPoint(
            x: scene.size.width / 2,
            y: scene.size.height / 2
        )

        textLabel.preferredMaxLayoutWidth = scene.size.width * 0.7
    }

    func present(lines: [String]) {
        guard !isActive else { return }

        self.lines = lines
        self.currentIndex = 0
        self.isActive = true

        background.alpha = 1
        textLabel.alpha = 1
        textLabel.text = lines.first
    }

    override func mouseDown(with event: NSEvent) {
        guard isActive else { return }

        if currentIndex < lines.count - 1 {
            currentIndex += 1
            textLabel.text = lines[currentIndex]
        } else {
            dismiss()
        }
    }
    
    override func keyDown(with event: NSEvent) {
        guard isActive else { return }

        if event.charactersIgnoringModifiers?.lowercased() == "z" {
            if currentIndex < lines.count - 1 {
                currentIndex += 1
                textLabel.text = lines[currentIndex]
            } else {
                dismiss()
            }
        }
    }

    private func dismiss() {
        background.alpha = 0
        textLabel.alpha = 0
        lines.removeAll()
        currentIndex = 0
        isActive = false
    }
}
