//
//  PVUtility.h
//  PlayjaVu
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

static NSString * const kAlertTitle = @"Alert";
void alertMessage ( NSString *format, ... );

@interface PVUtility : NSObject

+ (BOOL)processLocalProfilePicture:(UIImage *)profileImage;
+ (void)processFacebookProfilePictureData:(NSData *)newProfilePictureData;

+ (BOOL)userHasValidFacebookData:(PFUser *)user;
+ (BOOL)userHasProfilePictures:(PFUser *)user;

+ (NSString *)firstNameForDisplayName:(NSString *)displayName;


+ (UIImage *)imageFromColor:(UIColor *)color;
@end
