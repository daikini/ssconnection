//
//  ViewController.m
//  Sample Project
//
//  Created by Sam Soffes on 3/19/09.
//  Copyright 2009 Sam Soffes. All rights reserved.
//

#import "ViewController.h"
#import "YVConnection.h"

@implementation ViewController

- (void)viewDidLoad {
	[[YVConnection sharedConnection] request:@"bible/verse"];
}

- (IBAction)refresh:(id)sender {

}

@end
