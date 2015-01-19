//
//  PVNetworkingUtility.m
//  PlayjaVu
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "PVNetworkingUtility.h"
#import "PVFacebookUtility.h"

@implementation PVNetworkingUtility

#pragma mark - Public Methods
+ (PVNetworkingUtility *)sharedUtility {
    static PVNetworkingUtility * _sharedUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUtility = [[PVNetworkingUtility alloc] init];
    });
    
    return _sharedUtility;
}

#pragma mark Networking Stuff
- (void)verifyUserLoginStatus
{
    // If logged in, present main view controller
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        if ([PFUser currentUser]) {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                // logged in already
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuShouldShowMainInterfaceNotification object:nil];
            });
        }
        else {
            dispatch_async(dispatch_get_main_queue(), ^(void) {
                // not logged in
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuShouldShowLoginNotification object:nil];
            });
        }
    });
}

- (void)refreshUser
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Refresh current user with server side data -- checks if user is still valid and so on
        [[PFUser currentUser] fetchInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
    });
}

- (void)logOutOfEverything
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        // Log out
        [PFUser logOut];
        
        // close FB if it's being used
        [[PFFacebookUtils session] close];
        
        // clear NSUserDefaults
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsCacheFacebookFriendsKey];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        // Unsubscribe from push notifications by clearing the channels key (leaving only broadcast enabled).
        [[PFInstallation currentInstallation] setObject:@[@""] forKey:kInstallationChannelsKey];
        [[PFInstallation currentInstallation] removeObjectForKey:kInstallationUserKey];
        [[PFInstallation currentInstallation] saveInBackground];
        
//        // clean up local data store
//        [PFObject unpinAllObjectsInBackground];
    });
    
    [[NSNotificationCenter defaultCenter] postNotificationName:kMenuShouldShowLoginNotification object:nil];
}

#pragma mark - Private Methods
- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error {
    
    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
    if (error && error.code == kPFErrorObjectNotFound) {
        DLogRed(@"User does not exist.");
        [self logOutOfEverything];
        return;
    }
    
    if (![PFUser currentUser]) {
        DLogRed(@"Current Parse user does not exist, logout");
        [self logOutOfEverything];
        return;
    }
    
    //check what type of login we have
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        // logged in with Facebook so refresh our FB data
        [[PVFacebookUtility sharedUtility] refreshFacebookUser];
    } else {
        //we're logged with via a Parse account
        DLog(@"LOGGED IN WITH PARSE OR LOGGED OUT");
    }
}

@end
