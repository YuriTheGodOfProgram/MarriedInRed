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

//This page is for the begining dialogue with the black page.

final class BlackMirror: SKNode {
    
    private var lines: [Line] = []
    private var index: Int = 0
    private let autokey = "BlackMaskAutoDelay"
    
    var isActive: Bool {!lines.isEmpty}
    
//    override init(){
//        super.init()
//    //    This is where the variables go
//    }
    
    static let shared = BlackMirror()
    
    private let Color = SKColor(white: 0.0, alpha: 1.0)
}
