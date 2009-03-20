//
//  SSConnection.m
//  Sample Project
//
//  Created by Sam Soffes on 3/19/09.
//  Copyright 2009 Sam Soffes. All rights reserved.
//

#import "SSConnection.h"

static NSTimeInterval kTimeout = 60.0;
static SSConnection *sharedConnection = nil;

@implementation SSConnection

@synthesize delegate;
@synthesize credential;

#pragma mark -
#pragma mark Singleton
#pragma mark -

+ (SSConnection *)sharedConnection {
	@synchronized(self) {
        if (sharedConnection == nil) {
            [[self alloc] init]; // Assignment not done here
        }
    }
    return sharedConnection;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (sharedConnection == nil) {
            sharedConnection = [super allocWithZone:zone];
            return sharedConnection;  // Assignment and return on first allocation
        }
    }
    return nil; // On subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // Denotes an object that cannot be released
}

- (void)release {
    // Do nothing
}

- (id)autorelease {
    return self;
}

#pragma mark -
#pragma mark Request Methods
#pragma mark -

- (void)requestURL:(NSURL *)url {
	[self requestURL:url HTTPMethod: nil credential:nil];
}

- (void)requestURL:(NSURL *)url HTTPMethod:(NSString *)HTTPMethod credential:(NSURLCredential *)aCredential {
	NSMutableURLRequest* request = [[NSMutableURLRequest alloc] initWithURL:url 
																cachePolicy:NSURLRequestReloadIgnoringLocalCacheData 
															timeoutInterval:kTimeout];
	
	// Setup POST data
	if ([HTTPMethod isEqual:@"POST"]) {
		[request setHTTPMethod:HTTPMethod];
		NSString *parametersString = [url parameterString];
		NSInteger contentLength = [parametersString lengthOfBytesUsingEncoding:NSUTF8StringEncoding];
		[request setValue:[NSString stringWithFormat:@"%d", contentLength] forHTTPHeaderField:@"Content-Length"];
		NSData *body = [[NSData alloc] initWithBytes:[parametersString UTF8String] length:contentLength];
		[request setHTTPBody:body];
		[body release];
	}
	
	[self startRequest:request];
	[request release];
}

- (void)startRequest:(NSURLRequest *)request {
	
	// Cancel any current requests
	[self cancel];
	
	if (request == nil) {
		return;
	}
	
	// Generate the temp file name to store the plist data
	// TODO: make this string more unique to prevent collisions
	tempFilePath = [[NSString alloc] initWithFormat:@"%@ssconnection_temp_%i.plist", NSTemporaryDirectory(), [NSDate timeIntervalSinceReferenceDate]];
		
	// Create the temp file
	if([[NSFileManager defaultManager] fileExistsAtPath:tempFilePath] == NO) {
		[[NSFileManager defaultManager] createFileAtPath:tempFilePath contents:nil attributes:nil];
	}
	
	// Initialize the connection
	urlConnection = [[NSURLConnection alloc] initWithRequest:request delegate:self];
	
	// Start the request
	[urlConnection start];
}

- (void)cancel {
	[urlConnection cancel];
	[urlConnection release];
	urlConnection = nil;
	
	[credential release];
	credential = nil;
	
	// Remove temp file
	if (tempFilePath != nil) {
		[[NSFileManager defaultManager] removeItemAtPath:tempFilePath error:NULL];
	}
	
	[tempFilePath release];
	tempFilePath = nil;
}

- (void)dealloc {
	[self cancel];
	[super dealloc];
}

#pragma mark -
#pragma mark NSURLConnection Delegate
#pragma mark -

- (void)connection:(NSURLConnection *)connection didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge *)challenge {
	if (credential != nil) {
		[[challenge sender] useCredential:credential forAuthenticationChallenge:challenge];
	} else {
		[self cancel];
	}
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
	// Setup the file handle
	fileHandle = [[NSFileHandle fileHandleForWritingAtPath:tempFilePath] retain];
	[fileHandle truncateFileAtOffset:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	[fileHandle writeData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
	[self cancel];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
	
	[fileHandle closeFile];
	[fileHandle release];
	
	NSLog(@"temp file path: %@, exists: %i", tempFilePath, [[NSFileManager defaultManager] fileExistsAtPath:tempFilePath]);
	
	NSDictionary *response = [[NSDictionary alloc] initWithContentsOfFile:tempFilePath];
	
	//[self cancel];
	
	NSLog(@"dictionary description: %@", response);
	[response release];
}

@end
