//
//  ViewController.h
//  Sample Project
//
//  Created by Sam Soffes on 3/19/09.
//  Copyright 2009 Sam Soffes. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface ViewController : UIViewController {

	IBOutlet UILabel *methodLabel;
	IBOutlet UITextView *outputView;
	IBOutlet UIProgressView *progressView;
}

- (IBAction)refresh:(id)sender;

@end
