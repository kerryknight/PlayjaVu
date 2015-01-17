//
//  PVCache.m
//  PlayjaVu
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "PVCache.h"

@interface PVCache()
@property (nonatomic, strong) NSCache *cache;
@end

@implementation PVCache

#pragma mark - Initialization

+ (id)sharedCache {
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init];
    });
    return _sharedObject;
}

- (id)init {
    self = [super init];
    
    if (self) {
        self.cache = [[NSCache alloc] init];
    }
    return self;
}

#pragma mark - PVCache

- (void)clear {
    [self.cache removeAllObjects];
}

- (NSDictionary *)attributesForUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

- (void)setFacebookFriends:(NSArray *)friends {
    NSString *key = kUserDefaultsCacheFacebookFriendsKey;
    [self.cache setObject:friends forKey:key];
    
    // since we're storing custom PVFBFriend objects, we have to
    // ensure we encode them for saving to user defaults
    NSData *encodedFriends = [NSKeyedArchiver archivedDataWithRootObject:friends];
    [[NSUserDefaults standardUserDefaults] setObject:encodedFriends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)facebookFriends {
    NSString *key = kUserDefaultsCacheFacebookFriendsKey;
    
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    
    // and also decode the whole array of friends
    NSData *encodedFriends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    NSArray *friends = [NSKeyedUnarchiver unarchiveObjectWithData:encodedFriends];
    
    if (friends) {
        [self.cache setObject:friends forKey:key];
    }
    
    return friends;
}

#pragma mark - ()

- (void)setAttributes:(NSDictionary *)attributes forUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    [self.cache setObject:attributes forKey:key];
}

- (NSString *)keyForUser:(PFUser *)user {
    return [NSString stringWithFormat:@"user_%@", [user objectId]];
}

@end
