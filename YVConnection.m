//
//  YVConnection.m
//  Sample Project
//
//  Created by Sam Soffes on 3/5/09.
//  Copyright 2009 Sam Soffes. All rights reserved.
//

#import "YVConnection.h"

static NSString *kAPIURL = @"http://dev.api2.youversion.com";
static NSString *kAPIVersion = @"1.0";
static NSTimeInterval kTimeout = 60.0;

static YVConnection *sharedConnection = nil;

@implementation YVConnection

@synthesize delegate;
@synthesize credential;

#pragma mark -
#pragma mark Singleton
#pragma mark -

+ (YVConnection *)sharedConnection {
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

- (void)request:(NSString *)methodName {
	[self request:methodName parametersString:nil HTTPMethod:nil credential:nil];
}

- (void)request:(NSString *)methodName parameters:(NSDictionary *)parametersDictionary {
	[self request:methodName parameters:parametersDictionary HTTPMethod:nil credential:nil];
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
	[self request:methodName parametersString:parametersString HTTPMethod:nil credential:nil];
}

- (void)request:(NSString *)methodName parametersString:(NSString *)parametersString HTTPMethod:(NSString *)HTTPMethod credential:(NSURLCredential *)aCredential {
	
	// Build the URL string
	NSString *urlString = [[NSString alloc] initWithFormat:@"%@/%@/%@.plist", 
						   kAPIURL, kAPIVersion, methodName];
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
	} else {
		urlString = [NSString stringWithFormat:@"%@?%@", urlString, parametersString];
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
	tempFilePath = [[NSString alloc] initWithFormat:@"%@yvconnection_temp_%i.plist", NSTemporaryDirectory(), [NSDate timeIntervalSinceReferenceDate]];
	
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
	
	NSLog(@"%i - %@", [fileHandle offsetInFile], tempFilePath);
	[fileHandle closeFile];
	
	NSDictionary *response = [[NSDictionary alloc] initWithContentsOfFile:tempFilePath];
	
	//[self cancel];
	
	NSLog(@"%@", response);
	[response release];
}

@end
