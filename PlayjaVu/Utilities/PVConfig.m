//
//  PVConfig.m
//  PlayjaVu
//
//  Created by Kerry Knight on 1/4/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVConfig.h"

#pragma mark - API keys
NSString *const kParseApplicationID                           = @"lrVzV1hH5TedZ2X7bxSCVVF2fHdBErC6aHd9Pbk7";
NSString *const kParseApplicationClientKey                    = @"WspQhLtLfH6XRUz14O3t8ZJKOUvR1SV1bdLwjjdM";

#pragma mark - NSUserDefaults
NSString *const kUserDefaultsCacheFacebookFriendsKey          = @"com.kerryknight.playjavu.userDefaults.cache.facebookFriends";

#pragma mark - Default App Settings
int const kMinimumPasswordLength                              =   7;
int const kMaximumPasswordLength                              =   20;

#pragma mark - Launch URLs
NSString *const kLaunchURLHostTakePicture                     = @"camera";

#pragma mark - NSNotification
NSString *const kAppDelegateApplicationDidReceiveRemoteNotification = @"com.kerryknight.playjavu.appDelegate.applicationDidReceiveRemoteNotification";
NSString *const kMenuShouldShowMainInterfaceNotification      = @"kMenuShouldShowMainInterfaceNotification";
NSString *const kMenuShouldShowLoginNotification              = @"kMenuShouldShowLoginNotification";

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
NSString *const kUserFBIdKey                                    = @"fbId";
NSString *const kUserPrivateChannelKey                          = @"channel";
NSString *const kUserEmailKey                                   = @"email";
NSString *const kUserEmailVerifiedKey                           = @"emailVerified";
NSString *const kUserUsernameKey                                = @"username";
NSString *const kUserDisplayNameKey                             = @"displayName";
NSString *const kUserFirstNameKey                               = @"firstName";
NSString *const kUserLastNameKey                                = @"lastName";
NSString *const kUserFBLargeProfilePicURLKey                    = @"fbLargeProfilePictureURL";
NSString *const kUserFBSmallProfilePicURLKey                    = @"fbSmallProfilePictureURL";
NSString *const kUserGenderKey                                  = @"gender";
NSString *const kUserTimezoneKey                                = @"timezone";
NSString *const kUserBirthdayKey                                = @"birthday";
NSString *const kUserFBProfileLinkKey                           = @"fbProfileLink";


