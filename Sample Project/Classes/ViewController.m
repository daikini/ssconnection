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
	outputView.text = @"Loading...";
	
	NSInteger urlIndex = 0;
	if ([sender isKindOfClass:[UISegmentedControl class]]) {
		urlIndex = [sender selectedSegmentIndex];
	}
	NSString *basePath = @"https://github.com/daikini/ssconnection/raw/master/Sample%20Project";
	
	NSArray *urls = [NSArray arrayWithObjects:
					 @"HelloWorld-XML-Dictionary.plist",
					 @"HelloWorld-Binary-Dictionary.plist",
					 @"HelloWorld-XML-Array.plist",
					 @"HelloWorld-Binary-Array.plist",
					 nil];
	
	NSURL *url = [[NSURL alloc] initWithString:[NSString stringWithFormat:@"%@/%@", basePath, [urls objectAtIndex:urlIndex]]];
	SSConnection *connection = [[SSConnection alloc] initWithDelegate:self];
	[connection requestURL:url];
	[url release];
}

#pragma mark -
#pragma mark SSConnectionDelegate
#pragma mark -

- (void)connection:(SSConnection *)aConnection didFinishLoadingRequest:(NSURLRequest *)aRequest withResult:(id)result {
	outputView.text = [result description];
	[aConnection release];
}

@end
