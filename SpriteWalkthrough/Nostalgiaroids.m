//
//  Nostalgiaroids.m
//  SMACK ARCADE
//
//  Created by Jeffery Glasse on 8/30/13.
//  Copyright (c) 2017 Jeffery Glasse. All rights reserved.
//

@import AVFoundation;
#import "Nostalgiaroids.h"
#import "UFO.h"
#import "SKButton.h"

// set constants

static const CGFloat missileLaunchDistance = 40;
static const CGFloat missileVelocity = 800;
static const int maxShots = 3;
static const int numberOfLives = 3;
static const int shieldStrength = 0;
static const double shotDelay = .20;
static const int bigRockMass = 10;
static const int mediumRockMass = 4;
static const int smallRockMass = 1;
static const int UFOThreshhold = 20;

static const int rockminspeed = 30;
static const int rockmaxspeed = 130;

enum{rockhit, death,gameover,ufohit,ufocrash,shotbyufo};



@interface Nostalgiaroids () <SKPhysicsContactDelegate>



@property BOOL contentCreated;
@property (nonatomic)  SKSpriteNode* mySpaceship;
@property (nonatomic)  UFO* myUFO;
@property SKSpriteNode *missile;
@property int currentShipNumber;
@property NSArray *shipThrustImages;
@property int currentNumberOfLives;



//AVAudio PLayers
@property (nonatomic)AVAudioPlayer *theBGAudio;
@property (nonatomic)AVAudioPlayer *theBGAudioFaster;
@property (nonatomic)AVAudioPlayer *theBGAudioFastest;






//state of game propperties
@property BOOL shipIsExploding;
@property BOOL transitioningToNextLevel;
@property double timeLastFired;
@property int rockMassOnScreen;
@property int numberOfRocks;
@property BOOL shipAlive;
@property NSInteger shipCollisions;
@property int currentScore;
@property int highScore;
@property int thresholdForNextFreeShip;





//readouts
@property SKLabelNode *scoreNode;
@property SKLabelNode *hiScoreNode;
@property SKLabelNode *pausedNode;



//buttons
@property SKSpriteNode *leftButton;
@property SKSpriteNode *rightButton;
@property SKSpriteNode *thrustButton;
@property SKSpriteNode *settingsButton;
@property SKSpriteNode *hyperspaceButton;
@property SKButton *fireButton;


//actions

@property SKAction *repeatThrustanimation;
@property SKAction *bonusShipSound;
@property SKAction *controllerConnected;
@property SKAction *controllerDisconnected;



//gameover items
@property SKLabelNode *gameOverNode;
@property SKSpriteNode *restartGameButton;

//sounds
@property SKAction* owSound;
@property SKAction* crashSound;
@property SKAction* crashSound2;

@property SKAction *pewSound;
@property SKAction* insultSound;

@property BOOL insult_playing;





typedef NS_OPTIONS(NSUInteger, AsteroidsCollionsMask) {
    missileCategory =  0x1 << 0,
    shipCategory=  0x1 << 1,
    asteroidCategory  =  0x1 << 2,
    ufoCategory = 0x1 << 3,
    ufoMissileCategory = 0x1 << 4
};
@end




@implementation Nostalgiaroids

#pragma mark - Initialization




- (void)didMoveToView:(SKView *)view
{
    if (!self.contentCreated)
    {
        [self createSceneContents];
        self.contentCreated = YES;
    }

}

- (void)createSceneContents
{
    
   //  [[JCRGameControllerManager sharedInstance] setDelegate:self];
    
    //subscribe to moving to background notifications
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(pauseGame)
     name:UIApplicationWillResignActiveNotification
     object:nil];
    
//including controller
    
    
    [self setInitialConditions];
    [self makeButtons];
    _scoreNode = [self newScoreNode];
    _scoreNode.zPosition=3;
    [self addChild: _scoreNode];

    // add high score
    
    _hiScoreNode= [self newHighscoreNode];
    [self addChild: _hiScoreNode];
    
    _pausedNode=[self pauseTextNode];
    _pausedNode.alpha=0;
    [self addChild: _pausedNode];
    
    
    
    
    // add sounds
    SKAction *crashSound =  [ SKAction playSoundFileNamed:@"crashsound2.m4a" waitForCompletion: NO];
    _crashSound=crashSound;
    SKAction *crashSound2 =  [ SKAction playSoundFileNamed:@"explosion2.m4a" waitForCompletion: NO];
    _crashSound2=crashSound2;
    
    
    _pewSound =  [ SKAction playSoundFileNamed:@"pew.m4a" waitForCompletion: NO];
    SKAction *owSound =  [ SKAction playSoundFileNamed:@"ow.m4a" waitForCompletion: NO];
    _owSound=owSound;
    
    
    
    // add ship
    self.mySpaceship= [self newSpaceship];
    [self createNewShip];
    
    
    
    //add rocks
    _numberOfRocks=4;
    
    [self addRocks:_numberOfRocks];
    
    self.shipThrustImages = [[NSArray alloc ]initWithObjects:[SKTexture textureWithImageNamed:@"ship.png"],[SKTexture textureWithImageNamed:@"shipThrust1.png"], nil];
    
    
    self.hiScoreNode.text=[NSString stringWithFormat:@"%d", _currentNumberOfLives];
    
    
    //create BG beat sound players and start slow one
    [self configureSoundAssetActions];
    [self startBGSound];
    
}

/*

- (void)gameControllerManager:(JCRGameControllerManager *)manager
      gameControllerConnected:(JCRGameController *)gameController {
    
    NSInteger playerIndex = [[gameController controller] playerIndex];
    [self __logMessage:[NSString stringWithFormat:@"+ Gamecontroller connected with index: %ld", (long)playerIndex]];
    [ self runAction:_controllerConnected];
    [self hideButtons];

    
    [gameController setPauseButtonBlock:^(GCController *controller) {
        [self pauseGame];
    }];
    
    [gameController setAButtonBlock:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        [self __logMessage:@"A"];
        if (pressed) [self fire]; else [self endFire];
    }];
    
    [gameController setBButtonBlock:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        [self __logMessage:@"B"];
        if (pressed) [self thrust]; else [self endThrust];
    }];
    
    [gameController setXButtonBlock:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        [self __logMessage:@"X"];
        [self hyper];
    }];
    
    [gameController setYButtonBlock:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        [self __logMessage:@"Y"];
    }];
    
    [gameController setLeftShoulderButtonBlock:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        [self __logMessage:@"Left shoulder"];
        if (pressed) [self fire]; else [self endFire];
        
    }];
    
    [gameController setRightShoulderButtonBlock:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        [self __logMessage:@"Right shoulder"];
        if (pressed) [self fire]; else [self endFire];
    }];
    
    [gameController setLeftTriggerButtonBlock:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        [self __logMessage:@"Left trigger"];
        if (pressed) [self fire]; else [self endFire];
    }];
    
    [gameController setRightTriggerButtonBlock:^(GCControllerButtonInput *button, float value, BOOL pressed) {
        [self __logMessage:@"Right trigger"];
        if (pressed) [self fire]; else [self endFire];
    }];
    
    [gameController setLeftThumbstickBlock:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
        [self __logMessage:[NSString stringWithFormat:@"Left Thumbstick -- X: %f || F: %f", xValue, yValue]];
    }];
    
    [gameController setRightThumbstickBlock:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
        [self __logMessage:[NSString stringWithFormat:@"Right Thumbstick -- X: %f || F: %f", xValue, yValue]];
    }];
    
    [gameController setDPadBlock:^(GCControllerDirectionPad *dpad, float xValue, float yValue) {
        [self __logMessage:[NSString stringWithFormat:@"Dpad -- X: %f || F: %f", xValue, yValue]];
        if (xValue < 0)
            [self left];
        else
            if (xValue >0)
            [self right];
            else {
                [self endLeft];
                [self endRight];
            }
        
    }];
}

- (void)gameControllerManagerGameControllerDisconnected:(JCRGameControllerManager *)manager {
    [self runAction:_controllerDisconnected];
    [self showButtons];

}
*/

- (void)__logMessage:(NSString*)message {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSLog(@"%@",message);
    });
}




-(void)configureSoundAssetActions
{
    
    //thrustsound & Animation
    SKAction *thrustAnimation = [SKAction animateWithTextures:self.shipThrustImages timePerFrame:0.07];
    SKAction *thrustSound =  [ SKAction playSoundFileNamed:@"thrust.m4a" waitForCompletion: NO];
    SKAction *group = [SKAction group:@[thrustAnimation, thrustSound]];
    _repeatThrustanimation = [SKAction repeatActionForever:group];
    
    
    _bonusShipSound = [SKAction playSoundFileNamed:@"newshipsound.m4a" waitForCompletion: NO];
    _controllerConnected= [SKAction playSoundFileNamed:@"controllerconnected.m4a" waitForCompletion: NO];
    _controllerDisconnected= [SKAction playSoundFileNamed:@"controllerdisconnected.m4a" waitForCompletion: NO];

    
}


-(void) CheckScoreThenAwardExtraShipEveryOneThousandPoints
{
    if (_currentScore>_thresholdForNextFreeShip)
    {
        [self runAction:_bonusShipSound];
        _currentNumberOfLives+=1;
        _thresholdForNextFreeShip+=10000;
        _hiScoreNode.text=[NSString stringWithFormat:@"%d", _currentNumberOfLives];
        
    }
}


- (SKLabelNode *)newGameOverNode
{
    SKLabelNode *gameOverNode = [SKLabelNode labelNodeWithFontNamed:@"Hyperspace"];
    gameOverNode.text = @"GAME OVER";
    gameOverNode.fontSize = 60;
    gameOverNode.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    gameOverNode.name = @"gameOverNode";
    return gameOverNode;
}


-(void)decideIfTimeForUFOAttack
{
    if ((_rockMassOnScreen<UFOThreshhold) &(!_myUFO.alive) & _currentNumberOfLives>0)

    {
        u_int32_t rnd = arc4random_uniform(290002);
        if (rnd>289500)
        {
   
            if (_currentScore>40000)
            {
                rnd=289801;
            }
            
            if (rnd<289800)
                [self launchUFO:NO];  //launch big UFO
            else
                [self launchUFO:YES];  // launch small UFO
        }

    }
}

-(void)launchUFO: (BOOL)small
{
    _myUFO = [self newUFO];
    _myUFO.alive=YES;
    _myUFO.timeOnScreen=0;
    
    u_int32_t randomYvalue = 50+arc4random_uniform((u_int32_t) CGRectGetMaxY(self.frame)-100);
    int UFODirection = -150;
    
    
    _myUFO.position = CGPointMake(CGRectGetMaxX(self.frame),randomYvalue);
    _myUFO.name=@"UFO";
    _myUFO.physicsBody.affectedByGravity = NO;
    _myUFO.physicsBody.categoryBitMask = ufoCategory;
    _myUFO.physicsBody.contactTestBitMask = asteroidCategory | missileCategory| shipCategory;
    _myUFO.physicsBody.collisionBitMask = 0;

    if (small)
    {
        CGSize smallsize = {40,40};
        _myUFO.size=smallsize;
        [_myUFO playSmallUFOSound];

    
    }
    else
    {
        [_myUFO playUFOSound];

    }
    
        [self addChild:  _myUFO];
    _myUFO.physicsBody.velocity =CGVectorMake(UFODirection,0);

}
- (UFO*)newUFO
{
    UFO *ufo = [UFO spriteNodeWithImageNamed:@"UFO.png"];
    ufo.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:ufo.size];
    ufo.physicsBody.categoryBitMask=ufoCategory;
    ufo.physicsBody.contactTestBitMask=asteroidCategory | shipCategory;
    self.physicsBody.collisionBitMask = 0 ;
    ufo.physicsBody.angularDamping=0;
    return ufo;
}


-(SKSpriteNode*) mySpaceship
{
    if (!_mySpaceship)
    {
        _mySpaceship = [[SKSpriteNode alloc] init];
    
    }
    return _mySpaceship;
    
}

-(SKSpriteNode*) myUFO
{
    if (!_myUFO)
    {
        _myUFO = [[UFO alloc] init];
        
    }
    return _myUFO;
    
}



-(void)startBGSound

{
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"lowtonehightone" ofType:@"m4a"];
    self.theBGAudio = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    path = [[NSBundle mainBundle] pathForResource:@"lowtonehightone_medium" ofType:@"m4a"];
    self.theBGAudioFaster= [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    path = [[NSBundle mainBundle] pathForResource:@"lowtonehightone_fast" ofType:@"m4a"];
    
      self.theBGAudioFastest= [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    
    self.theBGAudio.numberOfLoops=-1;
    self.theBGAudioFaster.numberOfLoops=-1;
    self.theBGAudioFastest.numberOfLoops=-1;
    self.theBGAudio.volume=.5;
    self.theBGAudioFaster.volume=.5;
    self.theBGAudioFastest.volume=.4;
    [self.theBGAudio prepareToPlay];
    [self.theBGAudioFaster prepareToPlay];
    [self.theBGAudioFastest prepareToPlay];
    
    [self.theBGAudio play];
    
}



-(void)checkBGSound
{
    
    if (_rockMassOnScreen>30)
    {
        [self.theBGAudio play];
        [self.theBGAudioFaster stop];
        [self.theBGAudioFastest stop];

    }
    else
    {
    

        if (_rockMassOnScreen>5)
            {
                [self.theBGAudio stop];
                [self.theBGAudioFaster play];
                [self.theBGAudioFastest stop];
                
        
            }
        else
            if (!_transitioningToNextLevel)
            
            {
                [self.theBGAudio stop];
                [self.theBGAudioFaster stop];
                [self.theBGAudioFastest play];
            }
    
        }
    
        
    

    
}





-(void) createNewShip
{
    self.mySpaceship.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    self.mySpaceship.physicsBody.affectedByGravity = NO;
    [self addChild:  self.mySpaceship];
    


}

-(void) setmySpaceship: (SKSpriteNode*) ship
{
    _mySpaceship=ship;
    
}



-(void) setInitialConditions

{
    _lPress=NO;
    _rPress=NO;
    _thrustPress=NO;
    _firePress=NO;
    
    _rockMassOnScreen=0;
    
    _insult_playing=0;

    // set constants
    self.backgroundColor = [SKColor blackColor];
    self.scaleMode = SKSceneScaleModeAspectFit;
    self.physicsWorld.contactDelegate=self;
    
    _currentNumberOfLives=numberOfLives;
    _thresholdForNextFreeShip=10000;

}


-(void) makeButtons
{
    
    _fireButton=[self makeButtonWithImageNamed:@"fire" DownAction:@"fire" UpAction:@"endFire" atPosition:CGPointMake(CGRectGetMidX(self.frame)-270, 280)];
    _thrustButton=[self makeButtonWithImageNamed:@"thrust" DownAction:@"thrust" UpAction:@"endThrust" atPosition: CGPointMake(CGRectGetMidX(self.frame)+270, 280)];
    _leftButton=[self makeButtonWithImageNamed:@"left" DownAction:@"left" UpAction:@"endLeft" atPosition:CGPointMake(CGRectGetMidX(self.frame)-270, 80)];
    _rightButton=[self makeButtonWithImageNamed:@"right" DownAction:@"right" UpAction:@"endRight" atPosition:CGPointMake(CGRectGetMidX(self.frame)+270, 80)];
    _hyperspaceButton=[self makeButtonWithImageNamed:@"hyperspace" DownAction:@"hyper" UpAction:@"endHyper" atPosition:CGPointMake(CGRectGetMidX(self.frame), 180)];
    _settingsButton=[self makeButtonWithImageNamed:@"pause" DownAction:@"settings" UpAction:@"endSettings" atPosition: CGPointMake(CGRectGetMidX(self.frame)+300, 1250)];
    _settingsButton.xScale=.750;
    _settingsButton.yScale=.750;
    
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
-(void) hideButtons
{
    _fireButton.alpha=0;
    _thrustButton.alpha=0;
    _leftButton.alpha=0;
    _rightButton.alpha=0;
    _hyperspaceButton.alpha=0;
    _settingsButton.alpha=0;
    
}

-(void) showButtons
{
    _fireButton.alpha=1;
    _thrustButton.alpha=1;
    _leftButton.alpha=1;
    _rightButton.alpha=1;
    _hyperspaceButton.alpha=1;
    _settingsButton.alpha=1;
    
}





#pragma mark - Simulation


-(void)didSimulatePhysics

{
    
    //reset all sprite positions to wrap screen
    for(SKNode *node in self.children)
    
  {

        float x= node.position.x;
        float y=node.position.y;
        float maxY =CGRectGetMaxY(self.frame);
        float maxX =CGRectGetMaxX(self.frame);
        if (node.position.y < 0)
        {
            node.position = CGPointMake(x, maxY);
        }
        if (node.position.y > maxY)
        {
            node.position = CGPointMake(x, 0);
        }
        if (node.position.x < 0)
        {
            if ([node.name  isEqual: @"UFO"])
              [_myUFO removeWithoutExplosion];
                else
            node.position = CGPointMake(maxX, y);
        }
        if (node.position.x > maxX)
        {
           
            node.position = CGPointMake(0, y);
            
        }
      
     }
    
    
    __block int numberOfrocks=0;
    [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop) {
        numberOfrocks++;
    }];

    if ((numberOfrocks==0) & (!_transitioningToNextLevel))
    {
        [self delaythenGoToNextLevel];
        
    }
    
    
}







-(void)didBeginContact:(SKPhysicsContact *) contact {

    
if (contact.bodyA.node == self.mySpaceship  || contact.bodyB.node == self.mySpaceship)
{
    
    if (self.shipCollisions<shieldStrength)
    {
        [self runAction: self.owSound];
        _shipCollisions++;
    }
    else
        
    {

        [self destroyShip];
        if (_currentNumberOfLives>0)
        {
            if ([contact.bodyA.node.name  isEqual: @"UFOmissile"] |[contact.bodyA.node.name  isEqual: @"UFOmissile"])
                
            [self smack:shotbyufo];
            else
                [self smack:death];
        }
    }
    
    
if ([contact.bodyA.node.name  isEqual: @"rock"] )
    {
        [self destroyRock:  contact.bodyA.node];
    }
    
    else
        if ([contact.bodyB.node.name  isEqual: @"rock"] )
        {
            [self destroyRock:  contact.bodyB.node];

        }
        
    }
else
{
    // if missile hits asteroid, destroy both
    
    
  if (([contact.bodyA.node.name  isEqual: @"missile"] |[contact.bodyA.node.name  isEqual: @"UFOmissile"])  & ([contact.bodyB.node.name  isEqual: @"rock"])  )

  {
      SKNode *body1=contact.bodyA.node;
      
      SKNode *body2=contact.bodyB.node;
      [body1 removeFromParent];
      [self destroyRock:  body2];

      [self smack:rockhit];
      
  }
   
    else
        
        if (([contact.bodyB.node.name  isEqual: @"missile"]|[contact.bodyB.node.name  isEqual: @"UFOmissile"]) & [contact.bodyA.node.name  isEqual: @"rock"])
            
        {
            SKNode *body1=contact.bodyA.node;
            
            SKNode *body2=contact.bodyB.node;
            [body2 removeFromParent];
            [self destroyRock:  body1];
            
            [self smack:rockhit];
        }
      }
    
    if (([contact.bodyA.node.name  isEqual: @"UFO"] ) | ([contact.bodyB.node.name  isEqual: @"UFO"] ))
    {
        BOOL smackStatus=NO;
        if (([contact.bodyA.node.name  isEqual: @"missile"] ) | ([contact.bodyB.node.name  isEqual: @"missile"]))
        {
                     smackStatus=YES;
        }
        [self destroyUFO:smackStatus];
        
        
        
    }
    

    
}








-(void)didEndContact: (SKPhysicsContact *) contact

{


}



-(void)update:(NSTimeInterval)currentTime

{
    [self decideIfTimeForUFOAttack];
    [self CheckScoreThenAwardExtraShipEveryOneThousandPoints];
    if ((_shipAlive)&(!_shipIsExploding))
        
    {
        if(_lPress==YES)
            
            self.mySpaceship.zRotation=self.mySpaceship.zRotation+.075;
        
        
        else
            if(_rPress==YES)
                self.mySpaceship.zRotation=self.mySpaceship.zRotation-.075;
        
        
        if(_thrustPress==YES)
        {
            [_mySpaceship.physicsBody applyImpulse:CGVectorMake(.5*cosf(self.mySpaceship.zRotation+M_PI_2), .5*sinf(self.mySpaceship.zRotation+M_PI_2))];
        }
        
        if(_firePress==YES)  [self fireMissile];
        
    }
    else
        
        [self respawnShip];
    
    if (_myUFO.alive)
    {
        _myUFO.timeOnScreen++;
        [self UFOdecideToFireOrMove];
    }
}




#pragma mark - Game Status Functions

-(void) resetGame

{
    if (self.scene.view.paused)
        
    {
        self.scene.view.paused = !self.scene.view.paused;
        _pausedNode.alpha=0;
    }
    _rockMassOnScreen=0;
    [_restartGameButton removeFromParent];
    [_gameOverNode removeFromParent];
    [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop) {
        [node removeFromParent];
    }];
    _numberOfRocks=4;
    [self addRocks:_numberOfRocks];
    
    _shipAlive=false;
    _shipIsExploding=false;
    
    _currentNumberOfLives=3;
    self.hiScoreNode.text=[NSString stringWithFormat:@"%d", _currentNumberOfLives];
    _currentScore=0;
    _thresholdForNextFreeShip=10000;
    [self updateScore:0];
    [self startBGSound];
    
    

    
    
}

-(void)delaythenGoToNextLevel
{
    _transitioningToNextLevel=TRUE;
    [self stopBGSounds];
    SKAction *wait = [SKAction waitForDuration: 2];
    [self runAction:wait completion:^{
        [self nextLevel];
        _transitioningToNextLevel=false;
    }];
    


}



- (void) nextLevel

{
    
    
    
    
    _numberOfRocks=_numberOfRocks+1;

    [self addRocks:_numberOfRocks];
        [self checkBGSound];


}

-(void)removeUFOWithoutExplosion
{
    
    [_myUFO removeFromParent];
    _myUFO.alive=false;
    [_myUFO.UFOSound stop];
    
}



#pragma mark - Create and Destroy Functions
-(void) destroyRock: (SKNode *) rock
{
    [rock removeFromParent];
    
    [self explosionAtLocation: rock.position];

    
    // add explosion
    
    
    
    // if big rock, add medium rocks, give 20 points

    if ([[rock.userData objectForKey:@"size"] isEqualToString:@"large"])
    {
        [self runAction: _crashSound2];

        _rockMassOnScreen=_rockMassOnScreen-bigRockMass;
        [self addMediumRockAt:rock.position];
        [self addMediumRockAt:rock.position];
        [self updateScore:20];

    
    }
    else
    {
    //  if medium rock, add small rocks, give 50 points
  
    if ([[rock.userData objectForKey:@"size"] isEqualToString:@"medium"])
    {
        [self runAction: _crashSound];

        _rockMassOnScreen=_rockMassOnScreen-mediumRockMass;

        [self addSmallRockAt:rock.position];
        [self addSmallRockAt:rock.position];
        [self updateScore:50];
    }
   // and if small rock (only remaining option),  give 100 points, spawining no fragments
    else
    {
        _rockMassOnScreen=_rockMassOnScreen-smallRockMass;
        [self runAction: _crashSound];

        [self updateScore:100];
    }
    }
    
    //now check to see if tempo needs to be updated
    [self checkBGSound];

}

-(void)destroyShip
{
    
    _currentNumberOfLives--;
    [self runAction: self.crashSound];
    SKSpriteNode *explodingShip = [SKSpriteNode spriteNodeWithImageNamed:@"explosion01.png"];
    SKTextureAtlas *explosionAtlas = [SKTextureAtlas atlasNamed:@"explosion"];
    SKTexture *ex1 = [explosionAtlas textureNamed:@"explosion01.png"];
    SKTexture *ex2 = [explosionAtlas textureNamed:@"explosion02.png"];
    SKTexture *ex3 = [explosionAtlas textureNamed:@"explosion03.png"];
    SKTexture *ex4 = [explosionAtlas textureNamed:@"explosion04.png"];
    SKTexture *ex5 = [explosionAtlas textureNamed:@"explosion05.png"];
    SKTexture *ex6 = [explosionAtlas textureNamed:@"explosion06.png"];
    SKTexture *ex7 = [explosionAtlas textureNamed:@"explosion07.png"];
    SKTexture *ex8 = [explosionAtlas textureNamed:@"explosion08.png"];
    SKTexture *ex9 = [explosionAtlas textureNamed:@"explosion09.png"];
    SKTexture *ex10 = [explosionAtlas textureNamed:@"explosion10.png"];
    SKTexture *ex11 = [explosionAtlas textureNamed:@"explosion11.png"];
    SKTexture *ex12 = [explosionAtlas textureNamed:@"explosion12.png"];
    
    NSArray *explosionTextures = @[ex1,ex2,ex3,ex4,ex5,ex6,ex7,ex8,ex9,ex10,ex11,ex12];
    SKAction *explosionAnimation = [SKAction animateWithTextures:explosionTextures timePerFrame:0.15];
    explodingShip.position=self.mySpaceship.position;
    [self.mySpaceship removeFromParent];
    self.mySpaceship=nil;
    [self addChild: explodingShip ];
    
    
    [explodingShip runAction:explosionAnimation completion:^{[explodingShip      removeFromParent];[self removeShip];  }];
    
    
}
-(void)explosionAtLocation: (CGPoint)  explosionLocation
{

    NSString *myParticlePath = [[NSBundle mainBundle] pathForResource:@"ExplosionParticle" ofType:@"sks"];
    SKEmitterNode *explosionEmitter = [NSKeyedUnarchiver unarchiveObjectWithFile:myParticlePath];
    explosionEmitter.particlePosition= explosionLocation;
    [self addChild:explosionEmitter];

}

-(void)removeShip
{
    self.hiScoreNode.text=[NSString stringWithFormat:@"%d", _currentNumberOfLives];
    
    
    if (_currentNumberOfLives>0)
    {
        _shipAlive=0;
        _shipCollisions=0;
        
    }
    
    else
        
        [self gameOver];
}



-(void)destroyUFO:(BOOL)smackStatus
{
    
    [_myUFO explode];
    [self explosionAtLocation: _myUFO.position];
    [self runAction: _crashSound];
    if (smackStatus) [self smack:ufohit];
    else [self smack:ufocrash];
    _myUFO.alive=false;
    
}



- (SKLabelNode *)newScoreNode
{
    SKLabelNode *scoreNode = [SKLabelNode labelNodeWithFontNamed:@"Hyperspace"];
    scoreNode.text = @"00";
    scoreNode.fontSize = 40;
    scoreNode.position = CGPointMake(90,CGRectGetMaxY(self.frame)-50);
    
    return scoreNode;
}


- (SKLabelNode *)newHighscoreNode
{
    SKLabelNode *highScoreNode = [SKLabelNode labelNodeWithFontNamed:@"Hyperspace"];
    highScoreNode.text = @"00";
    highScoreNode.fontSize = 40;
    highScoreNode.position = CGPointMake(CGRectGetMaxX(self.frame)/2,CGRectGetMaxY(self.frame)-50);
    
    return highScoreNode;
}

- (SKLabelNode *)pauseTextNode
{
    SKLabelNode *pauseNode = [SKLabelNode labelNodeWithFontNamed:@"Hyperspace"];
    pauseNode.text = @"GAME PAUSED";
    pauseNode.fontSize = 50;
    pauseNode.zPosition=5;
    pauseNode.position =  CGPointMake(CGRectGetMaxX(self.frame)/2,CGRectGetMaxY(self.frame)/2+75);
    return pauseNode;
    
}




-(void) addRocks: (int)numberOfRocksToAdd
{
    
    for (int i = 0; i < numberOfRocksToAdd; i++) {
        
        [self addRock];
        
    }
    
}

- (void)addRock
{
    
    CGFloat xDirection =1;
    CGFloat yDirection =1;
    
    // choose random rock graphic
    NSArray *BigRocks = [self rocknames];
    u_int32_t rnd = arc4random_uniform((u_int32_t)[BigRocks count]);
    NSString *rockName = [BigRocks objectAtIndex:rnd];
    
    
    SKSpriteNode *rock = [SKSpriteNode spriteNodeWithImageNamed:rockName];
    
    int minimumSafeDistance = 120;
    
    CGPoint centerSpot= CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));

    CGFloat rockSafeXdistance = skRand(minimumSafeDistance, (self.size.width/2));
    CGFloat rockSafeYdistance = skRand(minimumSafeDistance, (self.size.height/2));
    BOOL coinflip = rand()%2 ;
    BOOL coinflip2 = rand()%2;
    
    if (coinflip)
    {
            xDirection =1;
    }
        else
        {
             xDirection =-1;
        }
    if (coinflip2)
    {
         yDirection =1;
    }
    else
    {
         yDirection =-1;
    }

    
    
    
    
    
    
    //rock.position = CGPointMake(skRand(0, self.size.width),skRand(0, self.size.height) );
    rock.position = CGPointMake(centerSpot.x+xDirection*rockSafeXdistance,centerSpot.y+yDirection*rockSafeYdistance);
    
        
    rock.name = @"rock";
    rock.userData= [NSMutableDictionary
                    dictionaryWithDictionary:@{@"size": @"large" }];
    
    rock.physicsBody=[SKPhysicsBody bodyWithCircleOfRadius:60];
    rock.physicsBody.usesPreciseCollisionDetection = NO;
    rock.physicsBody.allowsRotation=NO;
    rock.physicsBody.categoryBitMask = asteroidCategory;
    rock.physicsBody.contactTestBitMask = asteroidCategory | missileCategory | ufoCategory;
    rock.physicsBody.collisionBitMask = shipCategory;
    rock.physicsBody.affectedByGravity = NO;
    
    
    
    coinflip = rand()%2 ;
    coinflip2 = rand()%2;
    
    if (coinflip)
    {
        xDirection =1;
    }
    else
    {
        xDirection =-1;
    }
    if (coinflip2)
    {
        yDirection =1;
    }
    else
    {
        yDirection =-1;
    }
    


    
    rock.physicsBody.velocity =CGVectorMake(xDirection*skRand(rockminspeed, rockmaxspeed),yDirection*skRand(rockminspeed, rockmaxspeed));
    rock.physicsBody.friction=0;
    rock.physicsBody.linearDamping=0;
    [self addChild:rock];
    [self updateMass:bigRockMass];
    
}

- (void)addMediumRockAt:(CGPoint) rockLocation
{
    CGFloat xDirection =1;
    CGFloat yDirection =1;
    NSArray *MediumRocks = [self mediumRocknames];
    NSUInteger rnd = arc4random_uniform((u_int32_t)[MediumRocks count]);
    NSString *rockName = [MediumRocks objectAtIndex:rnd];
    SKSpriteNode *rock = [SKSpriteNode spriteNodeWithImageNamed:rockName];
    
    int rockX=rockLocation.x+skRand(-5, 5);
    int rockY=rockLocation.y+skRand(-5, 5);
    
    
    
    rock.position = CGPointMake(rockX,rockY );
    rock.name = @"rock";
    rock.userData= [NSMutableDictionary
                    dictionaryWithDictionary:@{@"size": @"medium" }];
    rock.physicsBody=[SKPhysicsBody bodyWithCircleOfRadius:40];
    rock.physicsBody.usesPreciseCollisionDetection = NO;
    rock.physicsBody.allowsRotation=NO;
    rock.physicsBody.categoryBitMask = asteroidCategory;
    rock.physicsBody.contactTestBitMask = asteroidCategory | missileCategory;
    rock.physicsBody.collisionBitMask = shipCategory;
    rock.physicsBody.affectedByGravity = NO;
    
    BOOL coinflip = rand()%2 ;
    BOOL coinflip2 = rand()%2;
    
    
    if (coinflip)
    {
        xDirection =1;
    }
    else
    {
        xDirection =-1;
    }
    if (coinflip2)
    {
        yDirection =1;
    }
    else
    {
        yDirection =-1;
    }
        
        
    rock.physicsBody.velocity =CGVectorMake(xDirection*skRand(15, 100),yDirection*skRand(15, 100));  rock.physicsBody.friction=0;
    rock.physicsBody.linearDamping=0;
    [self addChild:rock];
    
    
    
    [self updateMass:mediumRockMass];
    
}

- (void)addSmallRockAt:(CGPoint) rockLocation
{
    CGFloat xDirection =1;
    CGFloat yDirection =1;
    NSArray *SmallRocks = [self smallRocknames];
    uint32_t rnd = arc4random_uniform((u_int32_t)[SmallRocks count]);
    NSString *rockName = [SmallRocks objectAtIndex:rnd];
    SKSpriteNode *rock = [SKSpriteNode spriteNodeWithImageNamed:rockName];
    
    int rockX=rockLocation.x+skRand(-5, 5);
    int rockY=rockLocation.y+skRand(-5, 5);
    
    
    
    rock.position = CGPointMake(rockX,rockY );
    rock.name = @"rock";
    rock.userData= [NSMutableDictionary
                    dictionaryWithDictionary:@{@"size": @"small" }];
    rock.physicsBody=[SKPhysicsBody bodyWithCircleOfRadius:40];
    rock.physicsBody.usesPreciseCollisionDetection = NO;
    rock.physicsBody.allowsRotation=NO;
    rock.physicsBody.categoryBitMask = asteroidCategory;
    rock.physicsBody.contactTestBitMask = asteroidCategory | missileCategory;
    rock.physicsBody.collisionBitMask = shipCategory;
    rock.physicsBody.affectedByGravity = NO;
    
    //flip a coin for each axis to decide direction
    
    BOOL coinflip = rand()%2 ;
    BOOL coinflip2 = rand()%2;
    
    if (coinflip)
    {
        xDirection =1;
    }
    else
    {
        xDirection =-1;
    }
    if (coinflip2)
    {
        yDirection =1;
    }
    else
    {
        yDirection =-1;
    }
    
    rock.physicsBody.velocity =CGVectorMake(xDirection*skRand(20, 120),yDirection*skRand(20, 120));
    rock.physicsBody.friction=0;
    rock.physicsBody.linearDamping=0;
    [self addChild:rock];
    [self updateMass:smallRockMass];
    
    
}



- (SKSpriteNode *)newSpaceship
{
    
    
    SKSpriteNode *hull = [SKSpriteNode spriteNodeWithImageNamed:@"ship.png"];
    hull.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:hull.size];
    hull.physicsBody.categoryBitMask=shipCategory;
    hull.physicsBody.contactTestBitMask=asteroidCategory;
    
    self.physicsBody.collisionBitMask = asteroidCategory;
    
    
    hull.physicsBody.angularDamping=1;
    self.shipAlive=1;
    return hull;
    
}


#pragma mark - Utility Functions

- (void) smack:(int) event

{
    static NSArray *_smacknames;
    static NSString *lastSmack;

    
    if (_insult_playing ==false)
    {
    _insult_playing =true;
        
     if (event== ufohit)
     {
                _smacknames = @[@"cancer.m4a",
                                @"diplomat.m4a",
                                @"et.m4a",
                                @"indigenous.m4a",
                                                                @"klatu.m4a",
                                                                @"rooting.m4a",
                                                                @"shotface.m4a",
                                @"xenophobic.m4a"];
     }
        
        else if (event== shotbyufo)
        {
            _smacknames = @[@"force.m4a",
                            @"hjerk.m4a",
                            @"captgenius.m4a",
                            @"stupidhumans.m4a",
                            @"suck.m4a",
                            @"flyinto.m4a"];
        }
        
        
        else if (event== ufocrash)
        {
            _smacknames = @[@"worseatthis.m4a",
                            @"clumsy.m4a",
                            @"insurance.m4a"];
        }

        else if (event==  gameover)
        {
        _smacknames = @[@"12yearolds.m4a",
                        @"80suck.m4a",
                        @"actualcar.m4a",
                        @"cat.m4a",
                        @"coma.m4a",
                        @"girlfriend.m4a",
                        @"insecurity.m4a",
                        @"livingpersonification.m4a",
                        @"metaphor.m4a",
                        @"middleschool.m4a",
                        @"nickleback.m4a",
                        @"nohope.m4a",
                        @"nolove.m4a",
                        @"parents.m4a",
                        @"playlikeliz.m4a",
                        @"shock.m4a",
                        @"spoiler.m4a",
                        @"suckateverything.m4a",
                        @"passengers.m4a",
                        @"terriblyugly.m4a",
                        @"thumbs.m4a",
                        @"worstperson.m4a"];
        }
 
  else if (event== death)
  {
        _smacknames = @[@"outsmarted.m4a",
                        @"gotlame.m4a",
                        @"moron.m4a",
                        @"sister2.m4a",
                        @"boohoo.m4a",
                        @"depressing.m4a",
                        @"putdown.m4a",
                        @"ow.m4a",
                        @"rockswinning.m4a",
                        @"actualrocks.m4a",
                        @"tryingtohit.m4a",
                        @"expensive.m4a",
                        @"pally.m4a",
                        @"avoid.m4a",
                        @"shootrocks.m4a",
                        @"redshirt.m4a",
                        @"actualrocks.m4a",
                        @"suck.m4a",
                        @"deathmethaphor.m4a",
                        @"proud.m4a"];
        
  }
        else if (event==rockhit)
        {
        _smacknames = @[@"pitiful.m4a",
                        @"better.m4a",
                        @"soeasy.m4a",
                        @"awful.m4a",
                        @"pathetic.m4a",
                        @"lame.m4a",
                        @"dork.m4a",
                        @"loser.m4a",
                        @"seriously.m4a",
                        @"embarassing.m4a",
                        @"incompetent.m4a",
                        @"smell.m4a",
                        @"stupidusmax.m4a",
                        @"suckage.m4a",
                        @"whoops.m4a",
                        @"greatshot.m4a"];
        
        }

    
    u_int32_t rnd = arc4random_uniform((u_int32_t)[_smacknames count]);
    if ([[_smacknames objectAtIndex:rnd] isEqualToString:lastSmack])
    {
    if (rnd > ([_smacknames count]-2))
            rnd=1;
        else
            rnd=rnd+1;
    
    }

        
        
    SKAction *insultSound =  [ SKAction playSoundFileNamed:[_smacknames objectAtIndex:rnd] waitForCompletion: YES];
        lastSmack=[_smacknames objectAtIndex:rnd];
    [self runAction: insultSound completion:^{ _insult_playing=false; }];
    }
    
}







- (NSArray *)rocknames
{
    static NSArray *_rocknames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _rocknames = @[@"bigrock_1",
                    @"bigrock_2",
                    @"bigrock_3",
                    @"bigrock_4",
                    @"bigrock_5"];
    });
    return _rocknames;
    
}

- (NSArray *)mediumRocknames
{
    static NSArray *_rocknames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _rocknames = @[@"midrock_1",
                       @"midrock_2",
                       @"midrock_3",
                       @"midrock_4",
                       @"midrock_5"];
    });
    return _rocknames;
    
}

- (NSArray *)smallRocknames
{
    static NSArray *_rocknames;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _rocknames = @[@"smallrock_1",
                       @"smallrock_2",
                       @"smallrock_3",
                       @"smallrock_4",
                       @"smallrock_5"];
    });
    return _rocknames;
    
}


-(void)gameOver
{

     [self stopBGSounds];
   
    [self smack:gameover];

    
    _gameOverNode=[self newGameOverNode];
    _restartGameButton = [SKSpriteNode spriteNodeWithImageNamed:@"restart.png"];
    _restartGameButton.name=@"restart";
    _restartGameButton.position = CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame)-100);

    
    [self addChild: _gameOverNode ];
    [self addChild:_restartGameButton];

}



-(void)respawnShip
{
    CGPoint centerSpot= CGPointMake(CGRectGetMidX(self.frame),CGRectGetMidY(self.frame));
    if ([self areaIsSafeForRespawning: centerSpot])
        {
            self.mySpaceship = [self newSpaceship];
            self.mySpaceship.position = CGPointMake(centerSpot.x,centerSpot.y);
            self.mySpaceship.physicsBody.affectedByGravity = NO;
            [self addChild:  self.mySpaceship];
        
        }
    
    
}

-(BOOL)areaIsSafeForRespawning: (CGPoint) respawnLocation
{
    CGFloat acceptableXandYDistance= 160;
    __block bool acceptablXandYDelta= true;
    

    
    [self enumerateChildNodesWithName:@"rock" usingBlock:^(SKNode *node, BOOL *stop) {
        
        
        if ((node.position.x-respawnLocation.x<acceptableXandYDistance) & (node.position.x-respawnLocation.x>-acceptableXandYDistance) &(node.position.y-respawnLocation.y<acceptableXandYDistance) & (node.position.y-respawnLocation.y>-acceptableXandYDistance))
        {
            acceptablXandYDelta=false;
        }
        

        
    }];
    

        return acceptablXandYDelta;


}


-(void)makeExplosion: (CGPoint) boomLocation
{
    SKSpriteNode *particle = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake( 2, 2 ) ];
    particle.name=@"missile";
    
    
    
}



-(void) fireMissile

{
    
    double timeFiring = [[NSDate date] timeIntervalSince1970];
    

    if (([self numberofShotsOnscreen] < maxShots) & (timeFiring-_timeLastFired>shotDelay))
        
        
        
    {
        _timeLastFired = [[NSDate date] timeIntervalSince1970];
        [self runAction: self.pewSound];

        
        SKSpriteNode *missile = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake( 3, 3 ) ];
        
        missile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:missile.size];
        missile.name=@"missile";
        missile.physicsBody.categoryBitMask=missileCategory;
        missile.physicsBody.contactTestBitMask=missileCategory;
        missile.physicsBody.dynamic = YES;
        missile.physicsBody.contactTestBitMask=missileCategory;
        missile.physicsBody.collisionBitMask = missileCategory;
        missile.physicsBody.angularDamping=1;
        missile.zRotation=self.mySpaceship.zRotation;
        
        CGPoint misslePlacer = CGPointMake (self.mySpaceship.position.x +missileLaunchDistance*.1*cosf(self.mySpaceship.zRotation), self.mySpaceship.position.y + .1*missileLaunchDistance*sinf(self.mySpaceship.zRotation));
        
        missile.position = misslePlacer;
        
        missile.physicsBody.affectedByGravity = NO;
        
        
        
        missile.zPosition=3;
        missile.name=@"missile";
        [self addChild:missile];
        
        missile.physicsBody.velocity=CGVectorMake(missileVelocity*cosf(missile.zRotation+M_PI_2), missileVelocity*sinf(missile.zRotation+M_PI_2));
        [self removeMissileAfterDelay: missile];
        _firePress=NO;
    }
    
    
}



-(void)UFOdecideToFireOrMove
{
    
    if (_myUFO.timeOnScreen % 60==0)
        [self fireUFOMissile];
    
    
    
    
}


-(void) fireUFOMissile

{
    [self runAction: self.pewSound];
    SKSpriteNode *missile = [SKSpriteNode spriteNodeWithColor:[SKColor whiteColor] size:CGSizeMake( 3, 3 ) ];
    missile.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:missile.size];
    missile.name=@"UFOmissile";
    missile.physicsBody.categoryBitMask=0;
    missile.physicsBody.contactTestBitMask=asteroidCategory | shipCategory;
    missile.physicsBody.dynamic = YES;
    missile.physicsBody.collisionBitMask = 0;
    missile.physicsBody.angularDamping=0;
    missile.zRotation=skRand(0, 360);
    missile.position = _myUFO.position;
    missile.physicsBody.affectedByGravity = NO;
    missile.zPosition=3;
    [self addChild:missile];
    missile.physicsBody.velocity=CGVectorMake(missileVelocity*cosf(missile.zRotation+M_PI_2), missileVelocity*sinf(missile.zRotation+M_PI_2));
    [self removeMissileAfterDelay: missile];
    
    
    
    
    
}


-(void) updateScore: (int) amount
{
    
    _currentScore=_currentScore+amount;
    self.scoreNode.text=[NSString stringWithFormat:@"%d", _currentScore];
        
    
}

-(void) updateMass: (int) amount
{
    
    _rockMassOnScreen=_rockMassOnScreen+amount;
    
    
}

- (int)numberofShotsOnscreen
{
    __block int numberOfShots = 0;
  [self enumerateChildNodesWithName:@"missile" usingBlock:^(SKNode *node, BOOL *stop) {
      
      numberOfShots++;
  }];
    
    return numberOfShots;


}


- (void) removeMissileAfterDelay: (SKSpriteNode*) missile

{
    SKAction *wait = [SKAction waitForDuration: .75];
    SKAction *removeNode = [SKAction removeFromParent];
    SKAction *sequence = [SKAction sequence:@[wait, removeNode]];
    [missile runAction:sequence];
    
   
    
}


- (void) removeMissile: (SKSpriteNode*) missile

{
    [missile removeFromParent];

    
    
    
    
    
}

-(void) stopBGSounds
{
    [self.theBGAudio stop];
    [self.theBGAudioFaster stop];
    [self.theBGAudioFastest stop];
    if (_myUFO.alive) [_myUFO pauseUFOSound];
    

}


-(void) pauseGame
{
    if ((int)_pausedNode.alpha==0)
    {
    _pausedNode.alpha=1;
        [self stopBGSounds];
    }
    else
    {
        
    _pausedNode.alpha=0;
        [self checkBGSound];
        if (_myUFO.alive) [_myUFO unpauseUFOSound];
    }

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.scene.view.paused = !self.scene.view.paused;
    });

}


-(void) rapidPauseGame
{

        _pausedNode.alpha=1;
        [self stopBGSounds];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, .05 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
        self.scene.view.paused = YES;
    });
    
}





#pragma mark - Touch Control


-(void)left
{
    _lPress=YES;

}

-(void)endLeft
{
    _lPress=NO;

}

-(void)right
{
    _rPress=YES;

}

-(void)endRight
{
    _rPress=NO;

    
}


-(void)thrust
{
    
    _thrustPress=YES;
    [self.mySpaceship runAction:_repeatThrustanimation withKey:@"thrusting"];
}

-(void)endThrust
{
    self.thrustPress=NO;
    [_mySpaceship removeActionForKey:@"thrusting"];
    [_mySpaceship setTexture:self.shipThrustImages[0]];
    
}


-(void)fire
{
   if (!_fireButton.justPressed)
   {
       _firePress=YES;
       _fireButton.justPressed = YES;
   }
    
}

-(void)endFire

{
    
    _firePress=NO;
    _fireButton.justPressed = NO;
}




-(void)hyper
{
    static BOOL hypering;
    
    if (!hypering)
    {
        hypering=TRUE;
        [self.mySpaceship removeFromParent];
        
        
        self.mySpaceship.position = CGPointMake(skRand(0, self.size.width),skRand(0, self.size.height) );
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
            [self addChild:self.mySpaceship];
            hypering = false;
        });
    }
    
}

-(void)endHyper
{
    
    
    
}


-(void)settings
{
    [self pauseGame];
   
}
-(void)endSettings
{
    
}




-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInNode:self];
    SKNode *node = [self nodeAtPoint:location];
    
        if  ([node.name isEqualToString:@"restart"])
    
    {
        [self resetGame];
        
    
    }
    
    
    
    
}




-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event

{

}


-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{

}






#pragma mark - Random Number generator for random Rock generation


static inline CGFloat skRandf() {
    return rand() / (CGFloat) RAND_MAX;
}

static inline CGFloat skRand(CGFloat low, CGFloat high) {
    return skRandf() * (high - low) + low;
}













@end
