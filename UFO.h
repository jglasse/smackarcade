//
//  UFO.h
//  smack arcade
//
//  Created by Jeffery Glasse on 5/20/14.
//  Copyright (c) 2014 Jeffery Glasse. All rights reserved.
//

#import <SpriteKit/SpriteKit.h>
#import <AVFoundation/AVFoundation.h>



@interface UFO : SKSpriteNode
@property int timeOnScreen;
@property (nonatomic)AVAudioPlayer *UFOSound;
@property BOOL alive;


-(void) explode;
-(void)playUFOSound;
-(void)pauseUFOSound;
-(void)unpauseUFOSound;


-(void)playSmallUFOSound;
-(void)removeWithoutExplosion;




@end

