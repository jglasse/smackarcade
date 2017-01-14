//
//  SpriteViewController.m
//  SpriteWalkthrough
//
//  Created by Jeffery Glasse on 8/30/13.
//  Copyright (c) 2013 Jeffery Glasse. All rights reserved.
//

#import "SpriteViewController.h"
#import "MainMenuScene.h"

@import SpriteKit;



@interface SpriteViewController ()
{

}






@end

@implementation SpriteViewController










- (void)viewDidLoad
{
    [super viewDidLoad];
    SKView *spriteView = (SKView *) self.view;
    spriteView.showsDrawCount = NO;
    spriteView.showsNodeCount = NO;
    spriteView.showsFPS = NO;
   }

    
    





- (void)viewWillAppear:(BOOL)animated
{
    MainMenuScene  * hello = [[MainMenuScene alloc] initWithSize:CGSizeMake(768,1324)];
    SKView *spriteView = (SKView *) self.view;
    [spriteView presentScene: hello];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
