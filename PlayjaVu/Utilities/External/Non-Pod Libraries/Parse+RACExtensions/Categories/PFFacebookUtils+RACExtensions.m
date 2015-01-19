//
//  PFFacebookUtils+RACExtensions.m
//  PlayjaVu
//
//  Created by Kerry Knight on 2/16/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PFFacebookUtils+RACExtensions.h"
#import "PFUser+RACExtensions.h"
#import "PFObject+RACExtensions.h"
#import "PFRACCallbacks.h"
#import "PFRACCallbacks+PV_Extensions.h"
#import "PFRACErrors.h"
#import "PVUtility.h"

@implementation PFFacebookUtils (RACExtensions)

+ (RACSignal *)rac_logInWithPermissions:(NSArray *)permissions {
    return [RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
        [self logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
            DLogPurple(@"user: %@", user);
            DLogPurple(@"error: %@", error);
            if (error == nil) {
                if (user.isNew) {
                    DLogGreen(@"User with facebook signed up and logged in!");
                } else {
                    DLogGreen(@"User with facebook logged in!");
                }
                
                [subscriber sendNext:user];
                [subscriber sendCompleted];
            }
            else {
                [subscriber sendError:[[PVUtility sharedUtility] normalizeRACError:error]];
            }
        }];
        return nil;
    }];
}

@end
