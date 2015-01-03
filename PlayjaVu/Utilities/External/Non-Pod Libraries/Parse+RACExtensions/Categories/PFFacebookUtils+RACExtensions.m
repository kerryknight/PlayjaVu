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

// Parse errors include only a generic "error" key. This function ensures that
// generic error gets assigned under NSLocalizedDescriptionKey.
static NSError *PFRACNormalizeError(NSError *error) {
    if (error == nil) return [NSError errorWithDomain:PFRACErrorDomain code:PFRACUnknownError userInfo:nil];
    
    if (error.userInfo[@"error"] == nil) return error;
    
    NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
    userInfo[NSLocalizedDescriptionKey] = userInfo[@"error"];
    return [NSError errorWithDomain:error.domain code:error.code userInfo:userInfo];
}

@implementation PFFacebookUtils (RACExtensions)

+ (RACSignal *)rac_logInWithPermissions:(NSArray *)permissions {
    return [RACSignal createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
        [self logInWithPermissions:permissions block:PFRACObjectCallback(subscriber)];
        return nil;
    }];
}

+ (RACSignal *)rac_makeRequestForMe {
    FBRequest *request = [FBRequest requestForMe];
    return [PFFacebookUtils kickOffRequest:request];
}

+ (RACSubject *)rac_profilePictureForUserId:(NSString *)facebookId {
    RACSubject *subject = [RACSubject subject];
    
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookId]];
    NSURLRequest *profilePictureURLRequest = [NSURLRequest requestWithURL:profilePictureURL cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:10.0f]; // Facebook profile picture cache policy: Expires in 2 weeks
    [NSURLConnection sendAsynchronousRequest:profilePictureURLRequest queue:[NSOperationQueue mainQueue] completionHandler:^(NSURLResponse *response, NSData *data, NSError *connectionError) {
        if (data) {
            [subject sendNext:data];
            [subject sendCompleted];
        }
        else {
            [subject sendError:connectionError];
        }
    }];
    
    return subject;
}

#pragma mark - Private Methods
+ (RACSignal *)kickOffRequest:(FBRequest *)request
{
    return
    [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
            // handle response
            if (!error) {
                [subscriber sendNext:result];
                [subscriber sendCompleted];
            }
            else {
                if ([[error userInfo][@"error"][@"type"] isEqualToString: @"OAuthException"]) {
                    // Since the request failed, we can check if it was due to an invalid session
                    DLogError(@"The facebook session was invalidated");
                    [PFUser logOut];
                }
                DLogError(@"Some other error: %@", error);
                [subscriber sendError:PFRACNormalizeError(error)];
            }
        }];
        return nil;
    }];
}

@end
