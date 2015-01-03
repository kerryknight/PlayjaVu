//
//  PFFacebookUtils+RACExtensions.m
//  Bar Golf
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

@implementation PFFacebookUtils (RACExtensions)


+ (RACSignal *)rac_logInWithPermissions:(NSArray *)permissions {
    return [[[RACSignal
              createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
                  [self logInWithPermissions:permissions block:PFRACObjectCallback(subscriber)];
                  return nil;
              }]
             pfrac_useDefaultErrorDescription:NSLocalizedString(@"Facebook log in failed", nil)]
            setNameWithFormat:@"+rac_logInWithPermissions: %@", permissions]; // Debug builds only

}

+ (RACSignal *)rac_getCurrentFacebookUserConnectionInfo {
    return [[[RACSignal
              createSignal:^RACDisposable * (id<RACSubscriber> subscriber) {
                  [FBRequestConnection startForMeWithCompletionHandler:PFRACFBRequestCallback(subscriber)];
                  return nil;
              }]
             pfrac_useDefaultErrorDescription:NSLocalizedString(@"Get current Facebook connection info for user failed", nil)]
            setNameWithFormat:@"+rac_getCurrentFacebookUserConnectionInfo"]; // Debug builds only
}

+ (RACSubject *)rac_getCurrentFacebookUsersProfilePicture:(NSString *)facebookId {
    RACSubject *subject = [RACSubject subject];
    
    NSURL *profilePictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", facebookId]];
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

+ (RACSignal *)rac_saveFacebookUserDataToParseForCurrentUser:(id)facebookResult {
    NSString *facebookId = facebookResult[@"id"];
    NSString *facebookName = facebookResult[@"username"];
    NSString *facebookEmail = facebookResult[@"email"];
    PFFile *profilePicSmall = facebookResult[kUserProfilePicSmallKey];
    
//    DLogPurple(@"fb permissions list: %@", facebookResult);
    
    if (facebookName && facebookName != 0) {
        [[PFUser currentUser] setObject:facebookName forKey:kUserDisplayNameKey];
    }
    
    if (facebookId && facebookId != 0) {
        [[PFUser currentUser] setObject:facebookId forKey:kUserFacebookIDKey];
    }
    
    if (facebookEmail && facebookEmail != 0) {
        [[PFUser currentUser] setObject:facebookEmail forKey:kUserEmailKey];
    }
    
    if (profilePicSmall) {
        [[PFUser currentUser] setObject:profilePicSmall forKey:kUserProfilePicSmallKey];
    }
    
    return [[[PFUser currentUser] rac_saveEventually] deliverOn:[RACScheduler mainThreadScheduler]];
}

@end
