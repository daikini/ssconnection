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
	NSURL *baseURL = [[NSURL alloc] initWithString:@"http://dev.api2.youversion.com/1.0/"];
	
	NSURL *url = [[NSURL alloc] initWithString:@"bible/verse.plist?reference=John.3.16" relativeToURL:baseURL];
	[[SSConnection sharedConnection] requestURL:url];
	[url release];
	
	[baseURL release];
}

- (IBAction)refresh:(id)sender {

}

@end
