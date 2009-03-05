//
//  YVConnection.m
//  Sample Project
//
//  Created by Sam Soffes on 3/5/09.
//  Copyright 2009 Sam Soffes. All rights reserved.
//

#import "YVConnection.h"

static NSString *kAPIURL = @"http://api.youversion.com";
static NSString *kAPIVersion = @"1.0";
static NSTimeInterval kTimeout = 60.0;

@implementation YVConnection

@synthesize credential;

- (void)request:(NSString *)methodName {
	[self request:methodName parametersString:nil HTTPMethod:@"GET" credential:nil];
}

- (void)request:(NSString *)methodName parameters:(NSDictionary *)parametersDictionary {
	[self request:methodName parameters:parametersDictionary HTTPMethod:@"GET" credential:nil];
}

- (void)request:(NSString *)methodName parameters:(NSDictionary *)parametersDictionary HTTPMethod:(NSString *)HTTPMethod credential:(NSURLCredential *)aCredential {
	NSMutableString *parametersString = [[NSMutableString alloc] init];
	
	// Loop through the elements in the dictionary to build the parameters string
	for (NSString *key in parametersDictionary) {
		[parametersString appendFormat:@"&%@=%@", 
		 [key stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding], 
		 [[parametersDictionary objectForKey:key] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
	}
	
	[self request:methodName parametersString:parametersString HTTPMethod:HTTPMethod credential:aCredential];
	[parametersString release];
}

- (void)request:(NSString *)methodName parametersString:(NSString *)parametersString {
	[self request:methodName parametersString:parametersString HTTPMethod:@"GET" credential:nil];
}

- (void)request:(NSString *)methodName parametersString:(NSString *)parametersString HTTPMethod:(NSString *)HTTPMethod credential:(NSURLCredential *)aCredential {
	
	// Cancel any current requests
	[self cancel];
	
	// Build the URL string
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@/%@/%@/%@.plist?%@", 
						   kAPIURL, kAPIVersion, methodName, parametersString];
	NSURL *requestUrl = [[NSURL alloc] initWithString:urlString];
	[urlString release];
	
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:requestUrl 
																cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
															timeoutInterval:kTimeout];
	[requestUrl release];
	    
	// Setup POST data
	if ([HTTPMethod isEqual:@"POST"]) {
		[request setHTTPMethod:HTTPMethod];
		NSInteger contentLength = [parametersString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[request setValue:[NSString stringWithFormat:@"%d", contentLength] forHTTPHeaderField:@"Content-Length"];
		NSData *body = [[NSData alloc] initWithBytes:[parametersString UTF8String] length:contentLength];
		[request setHTTPBody:body];
		[body release];
	}
	
	// Setup credential
	if (aCredential != nil) {
		self.credential = aCredential;
	}
	
	// Initialize the connection
	urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	[request release];
	
	// Start the request
	[urlConnection start];
}

- (void)cancel {
	[urlConnection cancel];
	[urlConnection release];
	urlConnection = nil;
	
	[credential release];
	credential = nil;
	
	[receivedData release];
	receivedData = nil;
}

- (void)dealloc {
	[self cancel];
	[super dealloc];
}

#pragma mark -
#pragma mark NSURLConnection Delegate
#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	receivedData = [[NSMutableData alloc] initWithCapacity:[response expectedContentLength]];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[receivedData appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
}

@end
