//
//  PVUtility.m
//  PlayjaVu
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "PVUtility.h"
#import <ParseCrashReporting/ParseCrashReporting.h>
#import "PVCache.h"

@interface PVUtility ()
@end

@implementation PVUtility

#pragma mark - Public Methods
#pragma mark Parse-related
+ (void)configureParseWithLaunchOptions:(NSDictionary *)options
{
    // START 3RD PARTY INSTANTIATIONS ********************************************************
    // Parse stuff that can be done on background queue
    
    // Enable crash reporting on Parse
    [ParseCrashReporting enable];
    
//    // enable Parse local sqlite data store
//    [Parse enableLocalDatastore];
    
    // NOT SURE IF I SHOULD KEEP THESE ON OR NOT
    [Parse errorMessagesEnabled:YES];
    [Parse offlineMessagesEnabled:YES];
    
    // enable logging
    [Parse setLogLevel:PFLogLevelDebug];
    
    // initialize everything
    [Parse setApplicationId:kParseApplicationID clientKey:kParseApplicationClientKey];
    [PFFacebookUtils initializeFacebook];
    
    //Configure Parse setup
    PFACL *defaultACL = [PFACL ACL];
    // If you would like all objects to be private by default, remove this line.
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    
    // analytics
    [PFAnalytics trackAppOpenedWithLaunchOptionsInBackground:options block:nil];
    
    // END 3RD PARTY
    // INSTANTIATIONS **********************************************************
}

+ (void)updateCurrentParseUser
{
    // Refresh current user with server side data -- checks if user is still valid and so on
    [[PFUser currentUser] fetchInBackgroundWithTarget:self selector:@selector(_refreshCurrentUserCallbackWithResult:error:)];
}

+ (void)logOut
{
    [[PVCache sharedCache] clear];
    
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Unsubscribe from push notifications by clearing the channels key (leaving only broadcast enabled).
    [[PFInstallation currentInstallation] setObject:@[@""] forKey:kInstallationChannelsKey];
    [[PFInstallation currentInstallation] removeObjectForKey:kInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Log out
    [PFUser logOut];
    
    // close FB
    [[PFFacebookUtils session] close];
    
    // clean up local data store
    [PFObject unpinAllObjectsInBackground];
}

#pragma mark Facebook-related
+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    return [user objectForKey:kUserFacebookUserKey] != nil;
}

#pragma mark - Private Methods
+ (void)_refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error
{
    DLogBlue(@"MAKE SURE THIS GETS CALLED !!!!");
    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
    if (error && error.code == kPFErrorObjectNotFound) {
        DLog(@"User does not exist.");
        
        [self logOut];
        return;
    }
    
    //check what type of login we have
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        //we're logged in with Facebook
        // Check if user is missing a Facebook ID
        if ([PVUtility userHasValidFacebookData:[PFUser currentUser]]) {
            // User has Facebook ID.
            
            DLogGreen(@"user has facebook id so request friend list");
            //            // refresh Facebook friends on each launch
            //            PF_FBRequest *request = [PF_FBRequest requestForMyFriends];
            //            [request setDelegate:(PVAppDelegate*)[[UIApplication sharedApplication] delegate]];
            //            [request startWithCompletionHandler:nil];
        } else {
            DLogGreen(@"User missing Facebook ID; Should check to see if they connected via Facebook first before querying again.");
            //            PF_FBRequest *request = [PF_FBRequest requestForGraphPath:@"me/?fields=name,picture,email"];
            //            [request setDelegate:(PVAppDelegate*)[[UIApplication sharedApplication] delegate]];
            //            [request startWithCompletionHandler:nil];
        }
        /*else if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]] ) {
         //we're logged in with Twitter //TODO:
         } */
    } else {
        DLogSuccess(@"LOGGED IN WITH PARSE");
        //we're logged with via a Parse account
    }
}

@end
