//
//  PFRACCallbacks+PV_Extensions.m
//  PlayjaVu
//
//  Created by Kerry Knight on 2/16/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PFRACCallbacks+PV_Extensions.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "PFRACCallbacks.h"
#import "PFRACErrors.h"
#import "PVUtility.h"

FBRequestHandler PFRACFBRequestCallback(id<RACSubscriber> subscriber) {
    return ^(FBRequestConnection *connection, id result, NSError *error) {
        if (error == nil) {
            DLogOrange(@"old request type result: %@", result);
            [subscriber sendNext:result];
            [subscriber sendCompleted];
        } else {
            [subscriber sendError:[[PVUtility sharedUtility] normalizeRACError:error]];
        }
    };
}
