//
//  UFO.m
//  smack arcade
//
//  Created by Jeffery Glasse on 5/20/14.
//  Copyright (c) 2014 Jeffery Glasse. All rights reserved.
//

#import "UFO.h"

@implementation UFO


-(void)explode
{
            [self.UFOSound stop];
            [self removeFromParent];
            _alive=false;
}


-(void)playUFOSound
{
    _alive=true;
NSError *error;
NSString *path = [[NSBundle mainBundle] pathForResource:@"ufosound" ofType:@"m4a"];
self.UFOSound = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    
self.UFOSound.numberOfLoops=-1;
[self.UFOSound prepareToPlay];
[self.UFOSound play];
}


-(void)playSmallUFOSound
{
    _alive=true;
    NSError *error;
    NSString *path = [[NSBundle mainBundle] pathForResource:@"smallufosound" ofType:@"m4a"];
    self.UFOSound = [[AVAudioPlayer alloc] initWithContentsOfURL:[NSURL fileURLWithPath:path] error:&error];
    
    self.UFOSound.numberOfLoops=-1;
    [self.UFOSound prepareToPlay];
    [self.UFOSound play];
}


-(void)removeWithoutExplosion
{
    
    [self  removeFromParent];
    _alive=false;
    [_UFOSound stop];
    
}

-(void)pauseUFOSound;
{
    [_UFOSound stop];


}
-(void)unpauseUFOSound;
{
    [_UFOSound play];
    
    
}




@end
