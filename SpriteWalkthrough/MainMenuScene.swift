//
//  MainMenuScene.swift
//  smackarcade
//
//  Created by Jeffery Glasse on 1/13/17.
//  Copyright © 2017 Jeffery Glasse. All rights reserved.
//

import UIKit
import SpriteKit

class MainMenuScene_swift: SKScene {
    
    
    var menuCreated = false
    
    let nostalgiaroidsButton  = SKButtonNode(
    let moonBuggyButton = UIButton()
    let moonBuggyButton;
    @property  SKSpriteNode *titleNode;
    let BGMusic = AVAudiopl

}



func newButtonWithImageNamed(buttonImage:String, DownAction:String,  UpAction: String, endAction:String, atPosition:CGPoint) ->SKSpriteNode
    
{
    let buttonPress = buttonImage+"Pressed"
    
    let button = SKButtonNode(normalTexture: buttonImage, selectedTexture: buttonPress, disabledTexture: nil)
    
    
    
 
    [button setTouchUpInsideTarget:self action:NSSelectorFromString(endAction)];
    [button setTouchUpTarget:self action:NSSelectorFromString(endAction)];
    [button setTouchDownTarget:self action:NSSelectorFromString(action)];
    button.zPosition=3;
    button.position=buttonPosition;
    [self addChild:button];
    
    return button;
    
}
