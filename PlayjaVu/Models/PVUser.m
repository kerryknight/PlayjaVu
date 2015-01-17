//
//  PVUser.m
//  PlayjaVu
//
//  Created by Kerry Knight on 1/3/15.
//  Copyright (c) 2015 Kerry Knight. All rights reserved.
//

#import "PVUser.h"
#import <Parse/PFObject+Subclass.h>

@implementation PVUser
@dynamic birthday;
@dynamic fbId;
@dynamic email;
@dynamic firstName;
@dynamic lastName;
@dynamic username;
@dynamic fbFriends;
@dynamic location;
@dynamic fbProfileLink;
@dynamic fbProfilePictureURL;
@dynamic timezone;
@dynamic gender;

+ (NSString *)parseClassName
{
    return @"_User";
}

+ (void)load
{
    [self registerSubclass];
}

#pragma mark - Public Methods
+ (PVUser *)currentUser
{
    return (PVUser *)[PFUser currentUser];
}

@end
