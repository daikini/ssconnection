//
//  AppDelegate.h
//  Sample Project
//
//  Created by Sam Soffes on 3/5/09.
//  Copyright Sam Soffes 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {

    UIWindow *window;
    ViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet ViewController *viewController;

@end
