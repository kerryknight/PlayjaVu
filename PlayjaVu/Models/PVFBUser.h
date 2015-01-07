//
//  PVFBUser.h
//  PlayjaVu
//
//  Created by Kerry Knight on 1/3/15.
//  Copyright (c) 2015 Kerry Knight. All rights reserved.
//

#import <Parse/Parse.h>

typedef enum {
    PVGenderTypeFemale = 0,
    PVGenderTypeMale = 1
} PVGenderType;

@interface PVFBUser : PFObject<PFSubclassing>
@property (strong, nonatomic) NSDate *birthday;
@property (copy, nonatomic) NSString *facebookId;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *lastName;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSArray *friends;
@property (copy, nonatomic) NSString *location;
@property (copy, nonatomic) NSString *profileLink;
@property (strong, nonatomic) NSNumber *timezone;
@property (assign, nonatomic) PVGenderType gender;

@end
