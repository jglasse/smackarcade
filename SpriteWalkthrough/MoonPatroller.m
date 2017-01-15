//
//  MoonPatrollerScene.m
//  SMACK ARCADE
//
//  Created by Jeff Glasse on 7/16/14.
//  Copyright (c) 2017 Jeffery Glasse. All rights reserved.
//

#define WIDTH(view) view.frame.size.width
#define HEIGHT(view) view.frame.size.height
#define BACK_SCROLLING_SPEED .25
#define BACK2_SCROLLING_SPEED .5
#define FLOOR_SCROLLING_SPEED 1.5


#import "MoonPatroller.h"
#import "SKScrollingNode.h"

//static const uint32_t backBitMask     =  0x1 << 0;
static const uint32_t birdBitMask     =  0x1 << 1;
static const uint32_t floorBitMask    =  0x1 << 2;



static const int screenYOffset = 50;

@interface MoonPatroller ()

@property (nonatomic)AVAudioPlayer *theBGAudio;
@property BOOL contentCreated;




@end


@implementation MoonPatroller
{

    SKScrollingNode * floor;
    SKScrollingNode * back;
    SKScrollingNode * back2;

}


- (void)didMoveToView: (SKView *) view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        
        self.contentCreated = YES;
    }
}


- (void)createSceneContents
{
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    [self addChild: [self newHelloNode]];
    [self addChild: [self newSubtitleNode]];
    SKLabelNode *directionNode =[self newDirectionNode];
    [self addChild: directionNode];
    
    
    [self createBackground];
    [self createBackground2];
    
    [self createFloor];

    
    
    [self startBGSound];
    
    
   SKAction *blinkSequence = [SKAction sequence:@[
                                                   [SKAction fadeAlphaTo:1.0 duration:0.1],
                                                   [SKAction waitForDuration:.75],
                                                   [SKAction fadeAlphaTo:0.0 duration:0.1],
                                                   [SKAction waitForDuration:.75]
                                                   ]];
   [directionNode runAction:[SKAction repeatActionForever:blinkSequence ]];
    
    
}

- (void) createBackground
{
    back = [SKScrollingNode scrollingNodeWithImageNamed:@"MPfarbg1" inContainerWidth:WIDTH(self)];
    [back setScrollingSpeed:BACK_SCROLLING_SPEED];
    [back setAnchorPoint:CGPointZero];
    [back setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
    back.physicsBody.categoryBitMask = 0;
    back.physicsBody.contactTestBitMask = 0;
    
    
    [self addChild:back];
    
}


- (void) createBackground2
{
    back2 = [SKScrollingNode scrollingNodeWithImageNamed:@"MPclosebg" inContainerWidth:WIDTH(self)];
    [back2 setScrollingSpeed:BACK2_SCROLLING_SPEED];
    [back2 setAnchorPoint:CGPointZero];
    [back2 setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
    back2.physicsBody.categoryBitMask = 0;
    back2.physicsBody.contactTestBitMask = 0;
    [self addChild:back2];
    
}

- (void)createFloor
{
    floor = [SKScrollingNode scrollingNodeWithImageNamed:@"floor2" inContainerWidth:WIDTH(self)];
    [floor setScrollingSpeed:FLOOR_SCROLLING_SPEED];
    [floor setAnchorPoint:CGPointZero];
    [floor setName:@"floor"];
    [floor setPhysicsBody:[SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame]];
    floor.physicsBody.categoryBitMask = floorBitMask;
    floor.physicsBody.contactTestBitMask = birdBitMask;
    [self addChild:floor];
}


-(void)startBGSound

{
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"moonpatrol" ofType:@"aif"];
    self.theBGAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    
    
    self.theBGAudio.numberOfLoops=-1;
    self.theBGAudio.volume=.5;
    [self.theBGAudio prepareToPlay];
    [self.theBGAudio play];
    
}



- (SKLabelNode *)newHelloNode
{
    SKLabelNode *helloNode = [SKLabelNode labelNodeWithFontNamed:@"PressStart2P"];
    helloNode.text = @"Smack Arcade presents ";
    helloNode.fontSize = 30;
    helloNode.fontColor = [SKColor blueColor];
    helloNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)+screenYOffset);
    helloNode.name = @"helloNode";
    
    return helloNode;
}

- (SKLabelNode *)newSubtitleNode
{
    SKLabelNode *subtitleNode = [SKLabelNode labelNodeWithFontNamed:@"PressStart2P"];
    subtitleNode.text = @"Moon Patroller!";
    subtitleNode.fontColor = [SKColor blueColor];
    subtitleNode.fontSize = 50;
    subtitleNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-70+screenYOffset);
    subtitleNode.name = @"subtitleNode";
    
    return subtitleNode;
}

- (SKLabelNode *)newDirectionNode
{
    SKLabelNode *directionNode = [SKLabelNode labelNodeWithFontNamed:@"PressStart2P"];
    directionNode.text = @"Coming Soon!";
    directionNode.fontSize = 25;
    directionNode.fontColor = [SKColor redColor];
    directionNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-190+screenYOffset);
    directionNode.name = @"directionNode";
    
    
    return directionNode;
}

- (void)update:(NSTimeInterval)currentTime
{
 
    
    [back update:currentTime];
    [back2 update:currentTime];
 
    
    
    
    
    [floor update:currentTime];
    
 }


- (void)touchesBegan:(NSSet *) touches withEvent:(UIEvent *)event
{
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
            SKScene *mainMenuScene  = [[MainMenu alloc] initWithSize:self.size];
            SKTransition *doors = [SKTransition doorsOpenVerticalWithDuration:0.25];
            [self.view presentScene:mainMenuScene transition:doors];
        }];    }
    
}


@end
