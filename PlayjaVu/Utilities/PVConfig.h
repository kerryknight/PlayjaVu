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
extern NSString *const kUserDefaultsCacheFacebookFriendsKey;

#pragma mark - Default App Settings
extern int const kMinimumPasswordLength;
extern int const kMaximumPasswordLength;


#pragma mark - Launch URLs
extern NSString *const kLaunchURLHostTakePicture;


#pragma mark - NSNotification
extern NSString *const kAppDelegateApplicationDidReceiveRemoteNotification;
extern NSString *const kMenuShouldShowMainInterfaceNotification;
extern NSString *const kMenuShouldShowLoginNotification;


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

//// *********************************************** PARSE CLOUD CODE **************************************
//extern NSString *const kCloudCodeDeleteUserKey;

// *********************************************** PARSE CLASSES *****************************************
#pragma mark - PFObject User Class
// Field keys
extern NSString *const kUserFBIdKey;
extern NSString *const kUserPrivateChannelKey;
extern NSString *const kUserEmailKey;
extern NSString *const kUserEmailVerifiedKey;
extern NSString *const kUserFBFriendsKey;
extern NSString *const kUserUsernameKey;
extern NSString *const kUserDisplayNameKey;
extern NSString *const kUserFirstNameKey;
extern NSString *const kUserLastNameKey;
extern NSString *const kUserFBLargeProfilePicURLKey;
extern NSString *const kUserFBSmallProfilePicURLKey;
extern NSString *const kUserGenderKey;
extern NSString *const kUserTimezoneKey;
extern NSString *const kUserLocationKey;
extern NSString *const kUserBirthdayKey;
extern NSString *const kUserFBProfileLinkKey;

