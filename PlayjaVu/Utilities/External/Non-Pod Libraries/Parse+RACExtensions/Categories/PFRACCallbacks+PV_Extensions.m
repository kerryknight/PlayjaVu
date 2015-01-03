//
//  PFRACCallbacks+PV_Extensions.m
//  Bar Golf
//
//  Created by Kerry Knight on 2/16/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PFRACCallbacks+PV_Extensions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PFRACCallbacks.h"
#import "PFRACErrors.h"

// Parse errors include only a generic "error" key. This function ensures that
// generic error gets assigned under NSLocalizedDescriptionKey.
static NSError *PFRACNormalizeError(NSError *error) {
	if (error == nil) return [NSError errorWithDomain:PFRACErrorDomain code:PFRACUnknownError userInfo:nil];
    
	if (error.userInfo[@"error"] == nil) return error;
    
	NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
	userInfo[NSLocalizedDescriptionKey] = userInfo[@"error"];
	return [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
}

FBRequestHandler PFRACFBRequestCallback(id<RACSubscriber> subscriber) {
	return ^(FBRequestConnection *connection,
             id result,
             NSError *error) {
		if (error == nil) {
			[subscriber sendNext:result];
			[subscriber sendCompleted];
		} else {
			[subscriber sendError:PFRACNormalizeError(error)];
		}
	};
}
