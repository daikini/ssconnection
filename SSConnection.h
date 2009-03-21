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
	NSURLRequest *request;
	NSString *tempFilePath;
	NSFileHandle *fileHandle;
	NSUInteger totalReceivedBytes;
	NSUInteger expectedBytes;
}

@property (nonatomic, assign) id<SSConnectionDelegate> delegate;

- (SSConnection *)initWithDelegate:(id)aDelegate;
- (void)requestURL:(NSURL *)url;
- (void)requestURL:(NSURL *)url HTTPMethod:(NSString *)HTTPMethod credential:(NSURLCredential *)aCredential;
- (void)startRequest:(NSURLRequest *)request;
- (void)cancel;

@end


@protocol SSConnectionDelegate <NSObject>

@optional

- (void)connection:(SSConnection *)aConnection startedLoadingRequest:(NSURLRequest *)aRequest;
- (void)connection:(SSConnection *)aConnection totalReceivedBytes:(NSUInteger)totalReceivedBytes expectedBytes:(NSUInteger)expectedBytes;
- (void)connection:(SSConnection *)aConnection didFinishLoadingRequest:(NSURLRequest *)aRequest withResult:(id)result;

@end