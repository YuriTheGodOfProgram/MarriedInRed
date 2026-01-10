//
//  AppDelegate.swift
//  MarriedInRed
//
//  Created by YuriTheGodOfProgram on 11/13/25.

import Cocoa

@main
class AppDelegate: NSObject, NSApplicationDelegate {
    
//  Intergrate the pause system from MapScene into here, so it can pause the entire application
    
    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        AudioManager.shared.playMenuMusic(named: "(Menu) Time and Silence")
    }
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        AudioManager.shared.stopMusic()
    }
    func applicationDidBecomeActive(_ notification: Notification) {
        
    }
    func applicationDidResignActive(_ notification: Notification) {
        AudioManager.shared.stopMusic()
    }
}
