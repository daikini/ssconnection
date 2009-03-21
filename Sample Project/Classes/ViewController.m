//
//  ViewController.m
//  Sample Project
//
//  Created by Sam Soffes on 3/19/09.
//  Copyright 2009 Sam Soffes. All rights reserved.
//

#import "ViewController.h"
#import "SSConnection.h"

@implementation ViewController

- (void)viewDidLoad {
	
	NSURL *url = [[NSURL alloc] initWithString:@"http://samsoffes.github.com/iphone-plist/HelloWorld.plist"];
	[[SSConnection sharedConnection] requestURL:url];
	[url release];
}

- (IBAction)refresh:(id)sender {

}

@end
