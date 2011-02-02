//
//  SSConnection.m
//  Sample Project
//
//  Created by Sam Soffes on 3/19/09.
//  Copyright 2009 Sam Soffes. All rights reserved.
//

#import "SSConnection.h"

static NSTimeInterval kTimeout = 60.0;

@implementation SSConnection

@synthesize delegate;

- (SSConnection *)initWithDelegate:(id)aDelegate {
	if (self = [super init]) {
		self.delegate = aDelegate;
	}
	return self;
}

- (void)dealloc {
	[self cancel];
	[super dealloc];
}

#pragma mark -
#pragma mark Request Methods
#pragma mark -

- (void)requestURL:(NSURL *)url {
	[self requestURL:url HTTPMethod: nil credential:nil];
}

- (void)requestURL:(NSURL *)url HTTPMethod:(NSString *)HTTPMethod credential:(NSURLCredential *)aCredential {
	NSMutableURLRequest* aRequest = [[NSMutableURLRequest alloc] initWithURL:url 
																cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
															timeoutInterval:kTimeout];
	
	// Setup POST data
	if ([HTTPMethod isEqual:@"POST"]) {
		[aRequest setHTTPMethod:HTTPMethod];
		NSString *parametersString = [url parameterString];
		NSInteger contentLength = [parametersString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[aRequest setValue:[NSString stringWithFormat:@"%d", contentLength] forHTTPHeaderField:@"Content-Length"];
		NSData *body = [[NSData alloc] initWithBytes:[parametersString UTF8String] length:contentLength];
		[aRequest setHTTPBody:body];
		[body release];
	}
	
	[self startRequest:aRequest];
	[aRequest release];
}

- (void)startRequest:(NSURLRequest *)aRequest {
	
	// Cancel any current requests
	[self cancel];
	
	if (aRequest == nil) {
		return;
	}
	
	// Generate the temp file name to store the plist data
	tempFilePath = [[NSString alloc] initWithFormat:@"%@ssconnection_temp_%@.plist", NSTemporaryDirectory(), [[NSProcessInfo processInfo] globallyUniqueString]];

	// Create the temp file
	if([[NSFileManager defaultManager] fileExistsAtPath:tempFilePath] == NO) {
		[[NSFileManager defaultManager] createFileAtPath:tempFilePath contents:nil attributes:nil];
	}
	
	// Retain the request
	request = [aRequest retain];
	
	// Initialize the connection
	urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	// Start the request
	[urlConnection start];
	
	// Notify the delegate the request started
	if ([delegate respondsToSelector:@selector(connection:startedLoadingRequest:)]) {
		[delegate connection:self startedLoadingRequest:request];
	}
}

- (void)cancel {
	[urlConnection cancel];
	[urlConnection release];
	urlConnection = nil;
	
	[credential release];
	credential = nil;
	
	[request release];
	request = nil;
	
	// Remove temp file
	if (tempFilePath != nil) {
		[[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:NULL];
	}
	
	[tempFilePath release];
	tempFilePath = nil;
}

#pragma mark -
#pragma mark NSURLConnection Delegate
#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if (credential != nil) {
		[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
	} else {
		// TODO: notify the delegate of an error
		[self cancel];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	// Setup the file handle
	fileHandle = [[NSFileHandle fileHandleForWritingAtPath:tempFilePath] retain];
	[fileHandle truncateFileAtOffset:0];
	
	expectedBytes = [response expectedContentLength];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[fileHandle writeData:data];
	totalReceivedBytes += [data length];
	
	// Send an update to the delegate
	if ([delegate respondsToSelector:@selector(connection:totalReceivedBytes:expectedBytes:)]) {
		NSLog(@"%i / %i", totalReceivedBytes, expectedBytes);
		[delegate connection:self totalReceivedBytes:totalReceivedBytes expectedBytes:expectedBytes];
	}
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self cancel];
	// TODO: notify the delegate
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	NSData *data = [[NSData alloc] initWithContentsOfFile:tempFilePath];
	id result = [NSPropertyListSerialization propertyListWithData:data options:0 format:NULL error:NULL];
	[data release];
	
	// Send the result to the delegate
	if ([delegate respondsToSelector:@selector(connection:didFinishLoadingRequest:withResult:)]) {
		[delegate connection:self didFinishLoadingRequest:request withResult:result];
	}
	
	// Stop request and free up resources
	[self cancel];
}

@end
