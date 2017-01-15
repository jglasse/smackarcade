//
//  Nostalgiaroids.h
//  SMACK ARCADE
//
//  Created by Jeffery Glasse on 8/30/13.
//  Copyright (c) 2017 Jeffery Glasse. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import <SpriteKit/SpriteKit.h>

@interface Nostalgiaroids : SKScene

//control variables are public so buttons can be moved to the view controller if necessary

@property bool lPress;
@property bool rPress;
@property BOOL thrustPress;
@property bool firePress;
@property bool hyperPress;

-(void) fireUFOMissile;


@end
