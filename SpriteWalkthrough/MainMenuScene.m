//
//  MainMenuScene.m
//  smackarcade
//
//  Created by Jeff Glasse on 7/15/14.
//  Copyright (c) 2014 Jeffery Glasse. All rights reserved.
//

#import "MainMenuScene.h"
#import "SKButton.h"
#import "TitleScreenScene.h"
#import "MoonPatrollerScene.h"

@interface MainMenuScene ()

@property BOOL menuCreated;
@property SKButton* nostalgiaroidsButton;
@property SKButton* moonBuggyButton;
@property  SKSpriteNode *titleNode;
@property (nonatomic)AVAudioPlayer *BGMusic;

@end


@implementation MainMenuScene

- (void)didMoveToView:(SKView *)view
{
    if (!self.menuCreated)
    {
        [self makeMenu];
        
    }
    
    
}


-(void)startBGMusic
{
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"diz" ofType:@"m4a"];
    self.BGMusic = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    path = [[NSBundle mainBundle] pathForResource:@"diz" ofType:@"m4a"];
    self.BGMusic.numberOfLoops=1;
    self.BGMusic.volume=.2;
    [self.BGMusic prepareToPlay];
    [self.BGMusic play];
    
}


- (void)makeMenu
{
    
    self.menuCreated = YES;
    [self startBGMusic];
    
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    
    _titleNode = [SKSpriteNode spriteNodeWithImageNamed:@"mainmenutitle"];
    _titleNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMaxY(self.frame)-100);
    _titleNode.name = @"titleNode";
    [self addChild:self.titleNode];
    
    
    _nostalgiaroidsButton=[self makeButtonWithImageNamed:@"nostalgiaroids_button" DownAction:@"gotoNostalgiaroids" UpAction:@"endButton" atPosition:CGPointMake(CGRectGetMidX(self.frame), 780)];
    _moonBuggyButton=[self makeButtonWithImageNamed:@"patroller_button" DownAction:@"gotoPatroller" UpAction:@"endButton" atPosition:CGPointMake(CGRectGetMidX(self.frame), 580)];
    

   }


-(void) gotoNostalgiaroids
{
    SKScene *titleScene  = [[TitleScreenScene alloc] initWithSize:self.size];
    SKTransition *colorfade = [SKTransition fadeWithColor:[SKColor blackColor] duration:1.25];
    [self.view presentScene:titleScene transition:colorfade];
    

}


-(void) gotoPatroller
{
    SKScene *patrollerScene  = [[MoonPatrollerScene alloc] initWithSize:self.size];
    SKTransition *colorfade = [SKTransition fadeWithColor:[SKColor blackColor] duration:1.25];
    [self.view presentScene:patrollerScene transition:colorfade];

}

-(SKButton *)makeButtonWithImageNamed:(NSString*)buttonImage DownAction:(NSString*) action UpAction:(NSString*) endAction atPosition:(CGPoint)buttonPosition
{
    NSString *buttonPress= [buttonImage stringByAppendingString:@"Pressed"];
    SKButton *button = [[SKButton alloc] initWithImageNamedNormal:buttonImage selected:buttonPress];
    [button setTouchUpInsideTarget:self action:NSSelectorFromString(endAction)];
    [button setTouchUpTarget:self action:NSSelectorFromString(endAction)];
    [button setTouchDownTarget:self action:NSSelectorFromString(action)];
    button.zPosition=3;
    button.position=buttonPosition;
    [self addChild:button];
    
    return button;
}

@end
