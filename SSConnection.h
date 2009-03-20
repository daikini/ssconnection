//
//  SSConnection.h
//  Sample Project
//
//  Created by Sam Soffes on 3/19/09.
//  Copyright 2009 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol SSConnectionDelegate;

@interface SSConnection : NSObject {

	id<SSConnectionDelegate> delegate;
	NSURLConnection *urlConnection;
	NSURLCredential *credential;
	
	NSString *tempFilePath;
	NSFileHandle *fileHandle;
}

@property (nonatomic, assign) id<SSConnectionDelegate> delegate;
@property (nonatomic, retain) NSURLCredential *credential;

+ (SSConnection *)sharedConnection;

- (void)requestURL:(NSURL *)url;
- (void)requestURL:(NSURL *)url HTTPMethod:(NSString *)HTTPMethod credential:(NSURLCredential *)aCredential;
- (void)startRequest:(NSURLRequest *)request;
- (void)cancel;

@end


@protocol SSConnectionDelegate <NSObject>

@end