//
//  PVFBUser.m
//  PlayjaVu
//
//  Created by Kerry Knight on 1/3/15.
//  Copyright (c) 2015 Kerry Knight. All rights reserved.
//

#import "PVFBUser.h"
#import <Parse/PFObject+Subclass.h>

@implementation PVFBUser
@dynamic birthday;
@dynamic facebookId;
@dynamic email;
@dynamic firstName;
@dynamic lastName;
@dynamic username;
@dynamic friends;
@dynamic location;
@dynamic profileLink;
@dynamic timezone;
@dynamic gender;

+ (NSString *)parseClassName {
    return @"FacebookUser";
}

+ (void)load {
    [self registerSubclass];
}

//- (NSString *)description {
//    return self.username;
//}

@end
