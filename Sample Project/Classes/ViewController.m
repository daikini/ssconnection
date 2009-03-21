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
	outputView.font = [UIFont fontWithName:@"Courier" size:14.0];
	[self refresh:nil];
}

- (IBAction)refresh:(id)sender {
	NSURL *url = [[NSURL alloc] initWithString:@"http://samsoffes.github.com/iphone-plist/HelloWorld.plist"];
	SSConnection *connection =  [[SSConnection alloc] initWithDelegate:self];
	[connection requestURL:url];
	[url release];
}

#pragma mark -
#pragma mark SSConnectionDelegate
#pragma mark -

- (void)connection:(SSConnection *)aConnection didFinishLoadingRequest:(NSURLRequest *)aRequest withResult:(id)result {
	outputView.text = [result description];
}

@end
