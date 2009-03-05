//
//  YVConnection.h
//  Sample Project
//
//  Created by Sam Soffes on 3/5/09.
//  Copyright 2009 Sam Soffes. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol YVConnectionDelegate;

@interface YVConnection : NSObject {

	id<YVConnectionDelegate> delegate;
	NSURLConnection *urlConnection;
	NSURLCredential *credential;
	NSMutableData *receivedData;
}

@property (nonatomic, retain) NSURLCredential *credential;

- (void)request:(NSString *)methodName;
- (void)request:(NSString *)methodName parameters:(NSDictionary *)parametersDictionary;
- (void)request:(NSString *)methodName parameters:(NSDictionary *)parametersDictionary HTTPMethod:(NSString *)HTTPMethod credential:(NSURLCredential *)aCredential;
- (void)request:(NSString *)methodName parametersString:(NSString *)parametersString;
- (void)request:(NSString *)methodName parametersString:(NSString *)parametersString HTTPMethod:(NSString *)HTTPMethod credential:(NSURLCredential *)aCredential;

- (void)startRequest:(NSURLRequest *)request;
- (void)cancel;

@end


@protocol YVConnectionDelegate <NSObject>

@end
