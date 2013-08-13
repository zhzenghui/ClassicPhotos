//
//  AppDelegate.m
//  ClassicPhotos
//
//  Created by Soheil M. Azarpour on 8/11/12.
//  Copyright (c) 2012 iOS Developer. All rights reserved.
//

#import "AppDelegate.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    /*
     ListViewController is a subclass of UITableViewController.
     We will display images in ListViewController.
     Here, we wrap our ListViewController in a UINavigationController, and set it as the root view controller.
     */
    
    ListViewController *listViewController = [[ListViewController alloc] initWithStyle:UITableViewStylePlain];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:listViewController];
    
    self.window.rootViewController = navController;
    
    
    [self.window makeKeyAndVisible];
    return YES;
}


@end
