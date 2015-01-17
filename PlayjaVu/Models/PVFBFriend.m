//
//  PVFBFriend.m
//  PlayjaVu
//
//  Created by Kerry Knight on 1/17/15.
//  Copyright (c) 2015 Kerry Knight. All rights reserved.
//

#import "PVFBFriend.h"

@implementation PVFBFriend

- (void)encodeWithCoder:(NSCoder *)encoder {
    //Encode properties, other class variables, etc
    [encoder encodeObject:self.fbId forKey:@"fbId"];
    [encoder encodeObject:self.name forKey:@"name"];
    [encoder encodeObject:self.smallProfilePictureURL forKey:@"smallProfilePictureURL"];
}

- (id)initWithCoder:(NSCoder *)decoder {
    if((self = [super init])) {
        //decode properties, other class vars
        self.fbId = [decoder decodeObjectForKey:@"fbId"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.smallProfilePictureURL = [decoder decodeObjectForKey:@"smallProfilePictureURL"];
    }
    return self;
}

@end
