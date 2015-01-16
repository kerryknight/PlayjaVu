//
//  PVConfig.m
//  PlayjaVu
//
//  Created by Kerry Knight on 1/4/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVConfig.h"

#pragma mark - API keys
//NSString *const kREV_MOB_APP_ID                               = @"5063a942d1a7040c00000027";
//NSString *const kREV_MOB_FULLSCREEN_PLACEMENT_ID              = @"50f8496e1c5cb51a00000001";
//NSString *const kREV_MOB_BANNER_PLACEMENT_ID                  = @"50f849607293dc0e00000003";
//NSString *const kREV_MOB_AD_LINK_PLACEMENT_ID                 = @"50f849902af5fe1200000001";
NSString *const kParseApplicationID                           = @"lrVzV1hH5TedZ2X7bxSCVVF2fHdBErC6aHd9Pbk7";
NSString *const kParseApplicationClientKey                    = @"WspQhLtLfH6XRUz14O3t8ZJKOUvR1SV1bdLwjjdM";
//NSString *const kFacebookAppID                                = @"569418169862409";
//NSString *const kFacebookAppSecret                            = @"e1ee4515fc9ca0a94f88734408fa7faa";
NSString *const kTwitterConsumerKey                           = @"Sud9crv4umTDRXDzIJELA";
NSString *const kTwitterConsumerSecret                        = @"1C4tmO120pNAYzLMQ5B4TXqoBhNVx67uNaKY8Uzc6k";
//NSString *const kFoursquareEndpoint                           = @"https://api.foursquare.com/v2/";
//NSString *const kFoursquareCallbackURL                        = @"playjavuredirect://foursquare";
//NSString *const kFoursquareClientId                           = @"YGW04MPRBJIQKV3WVHTCJCOU5DUD5ILSAGEZ1KM2B2C5EQMT";
//NSString *const kFoursquareClientSecret                       = @"M10XYKPZGNCVVR2ONGAEGX4VJ1J15GYTBMRWJ1Z3PS3UXGHQ";

#pragma mark - NSUserDefaults
NSString *const kUserDefaultsCacheFacebookFriendsKey          = @"com.kerryknight.playjavu.userDefaults.cache.facebookFriends";

#pragma mark - Default App Settings
int const kMinimumPasswordLength                              =   7;
int const kMaximumPasswordLength                              =   20;

#pragma mark - Launch URLs
NSString *const kLaunchURLHostTakePicture                     = @"camera";


#pragma mark - NSNotification

NSString *const kAppDelegateApplicationDidReceiveRemoteNotification = @"com.kerryknight.playjavu.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const kMenuShouldShowMainInterfaceNotification      = @"PVMenuShouldShowMainInterfaceNotification";

#pragma mark - Installation Class

// Field keys
NSString *const kInstallationUserKey                          = @"user";
NSString *const kInstallationChannelsKey                      = @"channels";


#pragma mark - Cached User Attributes
// keys
NSString *const kUserAttributesPhotoCountKey                  = @"photoCount";

#pragma mark - Push Notification Payload Keys

NSString *const kAPNSAlertKey                                 = @"alert";
NSString *const kAPNSBadgeKey                                 = @"badge";
NSString *const kAPNSSoundKey                                 = @"sound";

// the following keys are intentionally kept short, APNS has a maximum payload limit
NSString *const kPushPayloadPayloadTypeKey                    = @"p";
NSString *const kPushPayloadPayloadTypeActivityKey            = @"a";

NSString *const kPushPayloadActivityTypeKey                   = @"t";
NSString *const kPushPayloadActivityLikeKey                   = @"l";
NSString *const kPushPayloadActivityCommentKey                = @"c";
NSString *const kPushPayloadActivityFollowKey                 = @"f";

NSString *const kPushPayloadFromUserObjectIdKey               = @"fu";
NSString *const kPushPayloadToUserObjectIdKey                 = @"tu";
NSString *const kPushPayloadPhotoObjectIdKey                  = @"pid";

//// *********************************************** PARSE CLOUD CODE **************************************
//NSString *const kCloudCodeDeleteUserKey                       = @"deleteUserAccountAndData";


// *********************************************** PARSE CLASSES *****************************************
#pragma mark - PFObject User Class
NSString *const kUserFacebookUserKey                          = @"facebookUser";
NSString *const kUserProfilePicURLKey                         = @"profilePictureURL";
NSString *const kUserPrivateChannelKey                        = @"channel";
NSString *const kUserEmailKey                                 = @"email";
NSString *const kUserEmailVerifiedKey                         = @"emailVerified";

#pragma mark - PFObject FacebookUser Class
NSString *const kFacebookUserIdKey                            = @"facebookId";
NSString *const kFacebookUserFriendsKey                       = @"friends";
NSString *const kFacebookUserUsernameKey                      = @"username";
NSString *const kFacebookUserProfilePicURLKey                 = @"profilePictureURL";
NSString *const kFacebookUserGenderKey                        = @"gender";
NSString *const kFacebookUserTimezoneKey                      = @"timezone";
NSString *const kFacebookUserLocationKey                      = @"location";
NSString *const kFacebookUserBirthdayKey                      = @"birthday";
NSString *const kFacebookUserEmailKey                         = @"email";
NSString *const kFacebookUserProfileLinkKey                   = @"profileLink";


