//
//  PVUtility.h
//  PlayjaVu
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

@interface PVUtility : NSObject

// Parse-related
+ (void)configureParseWithLaunchOptions:(NSDictionary *)options;
+ (void)updateCurrentParseUser;
+ (void)logOut; // log out of everything, really

// Facebook-related
+ (BOOL)userHasValidFacebookData:(PFUser *)user;

@end
