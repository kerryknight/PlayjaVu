//
//  PVFBUtility.h
//  PlayjaVu
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

@interface PVFBUtility : NSObject

+ (PVFBUtility *)sharedUtility;

#pragma mark - Networking Stuff
// called every time the main interface shows
- (void)refreshFacebookUser;

@end
