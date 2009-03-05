//
//  Sample_ProjectAppDelegate.m
//  Sample Project
//
//  Created by Sam Soffes on 3/5/09.
//  Copyright Sam Soffes 2009. All rights reserved.
//

#import "Sample_ProjectAppDelegate.h"
#import "Sample_ProjectViewController.h"

@implementation Sample_ProjectAppDelegate

@synthesize window;
@synthesize viewController;

- (void)applicationDidFinishLaunching:(UIApplication *)application {    
    
    // Override point for customization after app launch    
    [window addSubview:viewController.view];
    [window makeKeyAndVisible];
}

- (void)dealloc {
    [viewController release];
    [window release];
    [super dealloc];
}

@end
