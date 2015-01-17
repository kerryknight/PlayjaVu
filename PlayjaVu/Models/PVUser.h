//
//  PVUser.h
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

@interface PVUser : PFObject <PFSubclassing>
@property (strong, nonatomic) NSDate *birthday;
@property (copy, nonatomic) NSString *fbId;
@property (copy, nonatomic) NSString *fbProfilePictureURL;
@property (copy, nonatomic) NSString *email;
@property (copy, nonatomic) NSString *firstName;
@property (copy, nonatomic) NSString *lastName;
@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSArray *fbFriends;
@property (copy, nonatomic) NSString *location;
@property (copy, nonatomic) NSString *fbProfileLink;
@property (strong, nonatomic) NSNumber *timezone;
@property (assign, nonatomic) PVGenderType gender;

+ (PVUser *)currentUser;

@end
