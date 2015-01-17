//
//  PVNetworkingUtility.h
//  PlayjaVu
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

@interface PVNetworkingUtility : NSObject

+ (PVNetworkingUtility *)sharedUtility;

#pragma mark - Networking Stuff
// called every time side menu loads to determine if we should
// show the main view or the login view
- (void)verifyUserLoginStatus;

// called every time the main interface shows
- (void)refreshUser;

// log out of everything
- (void)logOutOfEverything;

@end
