//
//  MainMenuScene.swift
//  smackarcade
//
//  Created by Jeffery Glasse on 1/13/17.
//  Copyright © 2017 Jeffery Glasse. All rights reserved.
//
import Foundation
import UIKit
import SpriteKit

class MainMenu: SKScene {
    
    
    var menuCreated = false
    let nostalgiaroidsButton  = SKSpriteNode()
    


}


func createSceneContents()




func createBackgroundStarfield()

var emitterNode = starfieldEmitter(SKColor.lightGray, starSpeedY: 50, starsPerSecond: 1, starScaleFactor: 0.2)
emitterNode.zPosition = -10
self.addChild(emitterNode)

emitterNode = starfieldEmitter(SKColor.gray, starSpeedY: 30, starsPerSecond: 2, starScaleFactor: 0.1)
emitterNode.zPosition = -11
self.addChild(emitterNode)

emitterNode = starfieldEmitter(SKColor.darkGray, starSpeedY: 15, starsPerSecond: 4, starScaleFactor: 0.05)
emitterNode.zPosition = -12
self.addChild(emitterNode)





func startBGMusic()
    {
        let path = mainBundle.pathForResource:@"diz" ofType:@"m4a"
        
        self.BGMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
        path = [[NSBundle mainBundle] pathForResource:@"diz" ofType:@"m4a"];
        self.BGMusic.numberOfLoops=1;
        self.BGMusic.volume=.2;
        [self.BGMusic prepareToPlay];
        [self.BGMusic play];
        
}




// --------------------------
// ---- particle effects ----
// --------------------------
func starfieldEmitter(_ color: SKColor, starSpeedY: CGFloat, starsPerSecond: CGFloat, starScaleFactor: CGFloat) -> SKEmitterNode {
    
    // Determine the time a star is visible on screen
    let lifetime =  frame.size.height * UIScreen.main.scale / starSpeedY
    
    // Create the emitter node
    let emitterNode = SKEmitterNode()
    emitterNode.particleTexture = SKTexture(imageNamed: "StarParticle")
    emitterNode.particleBirthRate = starsPerSecond
    emitterNode.particleColor = SKColor.lightGray
    emitterNode.particleSpeed = starSpeedY * -1
    emitterNode.particleScale = starScaleFactor
    emitterNode.particleColorBlendFactor = 1
    emitterNode.particleLifetime = lifetime
    
    // Position in the middle at top of the screen
    emitterNode.position = CGPoint(x: frame.size.width/2, y: frame.size.height)
    emitterNode.particlePositionRange = CGVector(dx: frame.size.width, dy: 0)
    
    // Fast forward the effect to start with a filled screen
    emitterNode.advanceSimulationTime(TimeInterval(lifetime))
    
    return emitterNode
}
