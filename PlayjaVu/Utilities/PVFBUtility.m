//
//  PVFBUtility.m
//  PlayjaVu
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "PVFBUtility.h"
#import "PVFBFriend.h"

typedef enum {
    PVGenderTypeFemale = 0,
    PVGenderTypeMale = 1
} PVGenderType;

@interface PVFBUtility ()
@property (assign, nonatomic) int facebookResponseCount;
@property (assign, nonatomic) int expectedFacebookResponseCount;
@end

@implementation PVFBUtility

#pragma mark - Public Methods
+ (PVFBUtility *)sharedUtility {
    static PVFBUtility * _sharedUtility = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedUtility = [[PVFBUtility alloc] init];
    });
    
    return _sharedUtility;
}

#pragma mark - Facebook stuff
- (void)processedFacebookResponse {
    // Once we handled all necessary facebook batch responses, save everything necessary and continue
    @synchronized (self) {
        self.facebookResponseCount++;
        if (self.facebookResponseCount != self.expectedFacebookResponseCount) {
            return;
        }
    }
    self.facebookResponseCount = 0;
    
    [[PFUser currentUser] saveEventually];
}

- (void)refreshFacebookUser
{
    self.facebookResponseCount = 0;
    // This fetches the most recent data from FB, and syncs up all data with the server;
    // this includes profile pic and friends list from FB.
    FBSession *session = [PFFacebookUtils session];
    
//    DLogBlue(@"session: %@", session);
//    DLogBlue(@"user: %@", [PFUser currentUser]);
    
    if (!session.isOpen) {
        DLogRed(@"FB Session does not exist, logout");
        [[PVNetworkingUtility sharedUtility] logOutOfEverything];
        return;
    }
    
    // Finished checking for invalid stuff
    // Refresh FB Session (When we link up the FB access token with the parse user, information other than the access token string is dropped
    // By going through a refresh, we populate useful parameters on FBAccessTokenData such as permissions.
    [[PFFacebookUtils session] refreshPermissionsWithCompletionHandler:^(FBSession *session, NSError *error) {
        
        if (error) {
            DLogRed(@"Failed refresh of FB Session, logging out: %@", error);
            [[PVNetworkingUtility sharedUtility] logOutOfEverything];
            return;
        }
        
        self.expectedFacebookResponseCount = 0;
        
        NSArray *permissions = [[session accessTokenData] permissions];
        
        if ([permissions containsObject:@"public_profile"]) {
            // Logged in with FB; create batch request for all the things
            FBRequestConnection *connection = [[FBRequestConnection alloc] init];
            
            self.expectedFacebookResponseCount++;
            
            // REQUEST #1; /me public info
            [connection addRequest:[FBRequest requestForMe] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                
                if (error) {
                    DLogRed(@"couldn't fetch facebook /me data: %@, logout", error);
                    [self checkErrorForOAuthException:error];
                    return;
                }
                
                [self handleFacebookUserPublicDataResponseResult:(NSDictionary *)result];
                [self processedFacebookResponse];
            }];
            
            self.expectedFacebookResponseCount++;
            
            // REQUEST #2; large profile pic
            [connection addRequest:[FBRequest requestWithGraphPath:@"me" parameters:@{@"fields": @"picture.width(500).height(500)"} HTTPMethod:@"GET"] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                
                if (!error) {
                    // result is a dictionary with the user's Facebook data
                    [self handleFacebookUserProfilePicResponseResult:(NSDictionary *)result];
                }
                
                [self processedFacebookResponse];
                
            }];
            
            if ([permissions containsObject:@"user_friends"]) {
                self.expectedFacebookResponseCount++;
                
                // REQUEST #3; friends list
                [connection addRequest:[FBRequest requestWithGraphPath:@"/me/taggable_friends" parameters:nil HTTPMethod:@"GET"] completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                    
                    if (error) {
                        DLogRed(@"error: %@", error);
//                        // just clear the FB friend cache
//                        [[PAPCache sharedCache] clear];
                    }
                    
                    [self handleFacebookUserTaggableFriendsResponseResult:(NSDictionary *)result];
                    [self processedFacebookResponse];
                }];
            }
            
            [connection start];
            
        } else {
            DLog(@"No public profile data returned for the user");
//            NSData *profilePictureData = UIImagePNGRepresentation([UIImage imageNamed:@"AvatarPlaceholder.png"]);
//            [PAPUtility processFacebookProfilePictureData:profilePictureData];
//            
//            [[PAPCache sharedCache] clear];
//            [currentParseUser setObject:@"Someone" forKey:kPAPUserDisplayNameKey];
//            
//            self.expectedFacebookResponseCount++;
//            [self processedFacebookResponse];
        }
    }];
}

#pragma mark - Parsing Responses
- (void)handleFacebookUserPublicDataResponseResult:(NSDictionary *)result
{
    // parse our FB data into our _User object subclass
    if (result[@"id"]) {
        // facebookId
        [[PFUser currentUser] setObject:result[@"id"] forKey:kUserFBIdKey];
        
        // link to our small profile pic
        NSString *smallPicURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", result[@"id"]];
        [[PFUser currentUser] setObject:smallPicURL forKey:kUserFBSmallProfilePicURLKey];
    }
    
    if (result[@"first_name"]) {
        [[PFUser currentUser] setObject:result[@"first_name"] forKey:kUserFirstNameKey];
    }
    
    if (result[@"last_name"]) {
        [[PFUser currentUser] setObject:result[@"last_name"] forKey:kUserLastNameKey];
    }
    
    if (result[@"name"]) {
        [[PFUser currentUser] setObject:result[@"name"] forKey:kUserDisplayNameKey];
    }
    
    if (result[@"email"]) {
        [[PFUser currentUser] setObject:result[@"email"] forKey:kUserEmailKey];
    }
    
    if (result[@"link"]) {
        [[PFUser currentUser] setObject:result[@"link"] forKey:kUserFBProfileLinkKey];
    }
    
    if (result[@"timezone"]) {
        [[PFUser currentUser] setObject:result[@"timezone"] forKey:kUserTimezoneKey];
    }
    
    if (result[@"birthday"]) {
        [[PFUser currentUser] setObject:result[@"birthday"] forKey:kUserBirthdayKey];
    }
    
    if (result[@"gender"]) {
        PVGenderType gender = [result[@"gender"] isEqualToString:@"male"] ? PVGenderTypeMale : PVGenderTypeFemale;
        [[PFUser currentUser] setObject:@(gender) forKey:kUserGenderKey];
    }
}

- (void)handleFacebookUserProfilePicResponseResult:(NSDictionary *)result
{
    if (result[@"picture"][@"data"][@"url"]) {
        // this is a larger version of our small profile pic
        NSString *profilePictureURL = result[@"picture"][@"data"][@"url"];
        [[PFUser currentUser] setObject:profilePictureURL forKey:kUserFBLargeProfilePicURLKey];
    }
}

- (void)handleFacebookUserTaggableFriendsResponseResult:(NSDictionary *)result
{
    if (result[@"data"]) {
        NSArray *data = result[@"data"];
        NSMutableArray *friends = [[NSMutableArray alloc] initWithCapacity:data.count];
        
        [data enumerateObjectsUsingBlock:^(NSDictionary *friendData, NSUInteger idx, BOOL *stop) {
            PVFBFriend *friend = [[PVFBFriend alloc] init];
            
            if (friendData[@"id"]) {
                friend.fbId = friendData[@"id"];
            }
            
            if (friendData[@"name"]) {
                friend.name = friendData[@"name"];
            }
            
            if (friendData[@"picture"][@"data"][@"url"]) {
                friend.smallProfilePictureURL = friendData[@"smallProfilePictureURL"];
            }
            
            [friends addObject:friend];
        }];
        
        // we won't save the friends list to Parse, we'll just
        // cache it an keep it locally since we rebuild it 
        // everytime we open up the app
        [[PVCache sharedCache] setFacebookFriends:friends];
    }
}

- (void)checkErrorForOAuthException:(NSError *)error
{
    if ([[error userInfo][@"error"][@"type"] isEqualToString: @"OAuthException"]) {
        // Since the request failed, we can check if it was due to an invalid session
        DLogError(@"The facebook session was invalidated with error: %@", error);
        [[PVNetworkingUtility sharedUtility] logOutOfEverything];
    }
}

@end
