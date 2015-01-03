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

- (void)setAttributesForUser:(PFUser *)user photoCount:(NSNumber *)count followedByCurrentUser:(BOOL)following {
    NSAssert(FALSE, @"Just tried a commented out thing");
//    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
//                                count, kUserAttributesPhotoCountKey,
//                                [NSNumber numberWithBool:following], kUserAttributesIsFollowedByCurrentUserKey,
//                                nil];
//    [self setAttributes:attributes forUser:user];
}

- (NSDictionary *)attributesForUser:(PFUser *)user {
    NSString *key = [self keyForUser:user];
    return [self.cache objectForKey:key];
}

- (NSNumber *)photoCountForUser:(PFUser *)user {
    NSDictionary *attributes = [self attributesForUser:user];
    
    if (attributes) {
        NSNumber *photoCount = [attributes objectForKey:kUserAttributesPhotoCountKey];
        
        if (photoCount) {
            return photoCount;
        }
    }
    
    return [NSNumber numberWithInt:0];
}

- (BOOL)followStatusForUser:(PFUser *)user {
    NSAssert(FALSE, @"Just tried a commented out thing");
//    NSDictionary *attributes = [self attributesForUser:user];
//    
//    if (attributes) {
//        NSNumber *followStatus = [attributes objectForKey:kUserAttributesIsFollowedByCurrentUserKey];
//        
//        if (followStatus) {
//            return [followStatus boolValue];
//        }
//    }
    
    return NO;
}

- (void)setPhotoCount:(NSNumber *)count user:(PFUser *)user {
    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
    [attributes setObject:count forKey:kUserAttributesPhotoCountKey];
    [self setAttributes:attributes forUser:user];
}

- (void)setFollowStatus:(BOOL)following user:(PFUser *)user {
    NSAssert(FALSE, @"Just tried a commented out thing");
//    NSMutableDictionary *attributes = [NSMutableDictionary dictionaryWithDictionary:[self attributesForUser:user]];
//    [attributes setObject:[NSNumber numberWithBool:following] forKey:kUserAttributesIsFollowedByCurrentUserKey];
//    [self setAttributes:attributes forUser:user];
}

- (void)setFacebookFriends:(NSArray *)friends {
    NSString *key = kUserDefaultsCacheFacebookFriendsKey;
    [self.cache setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] setObject:friends forKey:key];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (NSArray *)facebookFriends {
    NSString *key = kUserDefaultsCacheFacebookFriendsKey;
    
    if ([self.cache objectForKey:key]) {
        return [self.cache objectForKey:key];
    }
    
    NSArray *friends = [[NSUserDefaults standardUserDefaults] objectForKey:key];
    
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
