//
//  SpriteAppDelegate.m
//  SpriteWalkthrough
//
//  Created by Jeffery Glasse on 8/30/13.
//  Copyright (c) 2013 Jeffery Glasse. All rights reserved.
//

#import "SmackAppDelegate.h"
#import <AVFoundation/AVFoundation.h>
#import "MainMenu.h"
#import "Nostalgiaroids.h"
#import "MoonPatroller.h"
#import "SpriteViewController.h"


@implementation SmackAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
    return YES;
}
							
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    
    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused = YES;
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    
    [[AVAudioSession sharedInstance] setActive:NO error:nil];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [[AVAudioSession sharedInstance] setActive:YES error:nil];

    
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    

    SKView *view = (SKView *)self.window.rootViewController.view;
    view.paused = NO;
    
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
