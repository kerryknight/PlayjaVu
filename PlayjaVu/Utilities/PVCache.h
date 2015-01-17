//
//  PVCache.h
//  PlayjaVu
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVCache : NSObject

+ (id)sharedCache;

- (void)clear;

- (NSDictionary *)attributesForUser:(PFUser *)user;

- (void)setFacebookFriends:(NSArray *)friends;

- (NSArray *)facebookFriends;

@end
