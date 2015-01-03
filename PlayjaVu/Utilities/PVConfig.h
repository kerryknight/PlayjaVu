//
//  PVConfig.h
//  PlayjaVu
//
//  Created by Kerry Knight on 1/4/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import <Foundation/Foundation.h>

#pragma mark - API keys
//extern NSString *const kREV_MOB_APP_ID;
//extern NSString *const kREV_MOB_FULLSCREEN_PLACEMENT_ID;
//extern NSString *const kREV_MOB_BANNER_PLACEMENT_ID;
//extern NSString *const kREV_MOB_AD_LINK_PLACEMENT_ID;
extern NSString *const kParseApplicationID;
extern NSString *const kParseApplicationClientKey;
//extern NSString *const kFacebookAppID;
//extern NSString *const kFacebookAppSecret;
extern NSString *const kTwitterConsumerKey;
extern NSString *const kTwitterConsumerSecret;
//extern NSString *const kFoursquareEndpoint;
//extern NSString *const kFoursquareCallbackURL;
//extern NSString *const kFoursquareClientId;
//extern NSString *const kFoursquareClientSecret;


#pragma mark - NSUserDefaults
extern NSString *const kUserDefaultsActivityFeedViewControllerLastRefreshKey;
extern NSString *const kUserDefaultsCacheFacebookFriendsKey;


#pragma mark - Default App Settings
extern int const kMinimumPasswordLength;
extern int const kMaximumPasswordLength;
extern int const kMinimumDisplayNameLength;
extern int const kMaximumDisplayNameLength;


#pragma mark - Launch URLs
extern NSString *const kLaunchURLHostTakePicture;


#pragma mark - NSNotification
extern NSString *const kAppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const kMenuShouldShowMainInterfaceNotification;


#pragma mark - Installation Class

// Field keys
extern NSString *const kInstallationUserKey;
extern NSString *const kInstallationChannelsKey;


#pragma mark - Cached User Attributes
// keys
extern NSString *const kUserAttributesPhotoCountKey;

#pragma mark - PFPush Notification Payload Keys

extern NSString *const kAPNSAlertKey;
extern NSString *const kAPNSBadgeKey;
extern NSString *const kAPNSSoundKey;

extern NSString *const kPushPayloadPayloadTypeKey;
extern NSString *const kPushPayloadPayloadTypeActivityKey;

extern NSString *const kPushPayloadActivityTypeKey;
extern NSString *const kPushPayloadActivityLikeKey;
extern NSString *const kPushPayloadActivityCommentKey;
extern NSString *const kPushPayloadActivityFollowKey;

extern NSString *const kPushPayloadFromUserObjectIdKey;
extern NSString *const kPushPayloadToUserObjectIdKey;
extern NSString *const kPushPayloadPhotoObjectIdKey;

//// *********************************************** PARSE CLOUD CODE **************************************
//extern NSString *const kCloudCodeDeleteUserKey;

// *********************************************** PARSE CLASSES *****************************************
#pragma mark - PFObject User Class
// Field keys
//displayName: name user signs up with or that comes from FB at signup; default
//that's displayed on scorecard
extern NSString *const kUserDisplayNameKey;
extern NSString *const kUserFacebookIDKey;
extern NSString *const kUserPhotoIDKey;
extern NSString *const kUserProfilePicSmallKey;
extern NSString *const kUserProfilePicMediumKey;
extern NSString *const kUserFacebookFriendsKey;
extern NSString *const kUserPrivateChannelKey;
extern NSString *const kUserFacebookProfileKey;
extern NSString *const kUserEmailKey;
extern NSString *const kUserUsernameKey;
extern NSString *const kUserEmailVerifiedKey;
extern NSString *const kUserTwitterIdKey;
