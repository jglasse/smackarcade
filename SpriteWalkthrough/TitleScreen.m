//
//  TitleScreen.m
//  SMACK ARCADE
//
//  Created by Jeffery Glasse on 8/30/13.
//  Copyright (c) 2017 Jeffery Glasse. All rights reserved.
//

#import "TitleScreen.h"
#import "Nostalgiaroids.h"
static const int screenYOffset = 50;


@interface TitleScreen ()

@property BOOL contentCreated;


@end

@implementation TitleScreen


- (void)didMoveToView: (SKView *) view {
    if (!self.contentCreated)
    {
        [self createSceneContents];
        SKAction *NostalgiaroidsSound =  [ SKAction playSoundFileNamed:@"Nostalgiaroids.m4a" waitForCompletion: NO];
        [self runAction:NostalgiaroidsSound];
        
        
        
        
        self.contentCreated = YES;
    }
}


- (void)createSceneContents {
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    [self addChild: [self newHelloNode]];
    [self addChild: [self newSubtitleNode]];
    
    SKLabelNode *directionNode =[self newDirectionNode];
    [self addChild: directionNode];
    
    
    SKAction *blinkSequence = [SKAction sequence:@[
                                                   [SKAction fadeAlphaTo:1.0 duration:0.1],
                                                   [SKAction waitForDuration:.75],
                                                   [SKAction fadeAlphaTo:0.0 duration:0.1],
                                                   [SKAction waitForDuration:.75]
                                                   ]];
    [directionNode runAction:[SKAction repeatActionForever:blinkSequence ]];
   
}





- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event {
    SKNode *helloNode = [self childNodeWithName:@"helloNode"];
    SKNode *subTitleNode = [self childNodeWithName:@"subtitleNode"];
    SKNode *directionNode = [self childNodeWithName:@"directionNode"];


    if (helloNode != nil)
    {
        helloNode.name = nil;
        subTitleNode.name = nil;
        directionNode.name= nil;
        SKAction *fadeAway = [SKAction fadeOutWithDuration: 0.55];
        SKAction *remove = [SKAction removeFromParent];
        SKAction *moveSequence = [SKAction sequence:@[fadeAway, remove]];
        [directionNode runAction:moveSequence];
        [subTitleNode runAction:moveSequence];
        [helloNode runAction: moveSequence completion:^{
            SKScene *spaceshipScene  = [[Nostalgiaroids alloc] initWithSize:self.size];

            SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.25];

            [self.view presentScene:spaceshipScene transition:doors];
        }];    }
    
}

- (SKLabelNode *)newHelloNode {
    SKLabelNode *helloNode = [SKLabelNode labelNodeWithFontNamed:@"Hyperspace"];
    helloNode.text = @"Smack Arcade presents ";
    helloNode.fontSize = 50;
    helloNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)+screenYOffset);
    helloNode.name = @"helloNode";

    return helloNode;
}

- (SKLabelNode *)newSubtitleNode {
    SKLabelNode *subtitleNode = [SKLabelNode labelNodeWithFontNamed:@"Hyperspace"];
    subtitleNode.text = @"Nostalgiaroids!";
    subtitleNode.fontSize = 70;
    subtitleNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-70+screenYOffset);
    subtitleNode.name = @"subtitleNode";
    
    return subtitleNode;
}

- (SKLabelNode *)newDirectionNode {
    SKLabelNode *directionNode = [SKLabelNode labelNodeWithFontNamed:@"Hyperspace"];
    directionNode.text = @"Tap screen to begin";
    directionNode.fontSize = 45;
    directionNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-190+screenYOffset);
    directionNode.name = @"directionNode";
    directionNode.alpha = 1.0;

    
    return directionNode;
}




@end
