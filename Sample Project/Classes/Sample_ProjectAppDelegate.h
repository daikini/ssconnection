//
//  Sample_ProjectAppDelegate.h
//  Sample Project
//
//  Created by Sam Soffes on 3/5/09.
//  Copyright Sam Soffes 2009. All rights reserved.
//

#import <UIKit/UIKit.h>

@class Sample_ProjectViewController;

@interface Sample_ProjectAppDelegate : NSObject <UIApplicationDelegate> {

    UIWindow *window;
    Sample_ProjectViewController *viewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet Sample_ProjectViewController *viewController;

@end
