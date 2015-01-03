//
//  PVUtility.m
//  PlayjaVu
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "PVUtility.h"
#import "UIImage+ResizeAdditions.h"
#import "SIAlertView.h"

// convenient for alert messages, with variadic format
void alertMessage ( NSString *format, ... ) {
    va_list args;
    va_start(args, format);
    
    NSString *outstr = [[NSString alloc] initWithFormat:format arguments:args];
    va_end(args);
    
    //be sure we only ever call this from the main thread //kak 09Feb2012
    dispatch_async(dispatch_get_main_queue(), ^{
        //knightka replaced a regular alert view with our custom subclass
        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(kAlertTitle, nil) andMessage:NSLocalizedString(outstr, nil)];
        [alertView addButtonWithTitle:@"OK"
                                 type:SIAlertViewButtonTypeCancel
                              handler:^(SIAlertView *alert) {
                                  NSLog(@"OK Clicked");
                              }];
        
        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
        [alertView show];
    });
}

@interface PVUtility ()
+ (BOOL)saveProfileImageToParse:(UIImage *)profileImage;
@end

@implementation PVUtility

#pragma mark - Parse Account Profile Picture
+ (BOOL)processLocalProfilePicture:(UIImage *)profileImage {
    return [self saveProfileImageToParse:profileImage];
}

+ (BOOL)saveProfileImageToParse:(UIImage *)profileImage {
    NSLog(@"%s", __FUNCTION__);
    
    UIImage *image = profileImage;
    UIImage *mediumImage = [image thumbnailImage:280 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationHigh];
    UIImage *smallRoundedImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:9 interpolationQuality:kCGInterpolationLow];
    
    NSData *mediumImageData = UIImageJPEGRepresentation(mediumImage, 0.5); // using JPEG for larger pictures
    NSData *smallRoundedImageData = UIImagePNGRepresentation(smallRoundedImage);
    
    //check to ensure we have proper image data to upload
    //we're doing this as a check to make sure we can alert the user if uploading a profile pic fails
    if (!mediumImageData || !smallRoundedImageData) {
        return NO;
    }
    
    if (mediumImageData.length > 0) {
//        DLog(@"Uploading Medium Profile Picture");
        PFFile *fileMediumImage = [PFFile fileWithData:mediumImageData];
        
        // Request a background execution task to allow us to finish uploading the photo even if the app is backgrounded
        UIBackgroundTaskIdentifier fileUploadBackgroundTaskId = 0;
        fileUploadBackgroundTaskId = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            [[UIApplication sharedApplication] endBackgroundTask:fileUploadBackgroundTaskId];
        }];
        
        DLog(@"Requested background expiration task with id %lu for PlayjaVu profile photo upload", (unsigned long)fileUploadBackgroundTaskId);
        [fileMediumImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                DLog(@"Uploaded Medium Profile Picture");
                [[PFUser currentUser] setObject:fileMediumImage forKey:kUserProfilePicMediumKey];
                //ensure the UI updates itself even if we haven't officially saved the photo to parse yet since we've set it to the currentUser's photov
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MyAccountViewLoadProfilePhoto" object:nil];
                [[PFUser currentUser] saveEventually];
                [[UIApplication sharedApplication] endBackgroundTask:fileUploadBackgroundTaskId];
                
            } else {
                DLog(@"Photo failed to save: %@", error);
                [[UIApplication sharedApplication] endBackgroundTask:fileUploadBackgroundTaskId];
                
                //knightka replaced a regular alert view with our custom subclass
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops. Something happened.", nil) andMessage:NSLocalizedString(@"Couldn't post your photo. Please try again.", nil)];
                [alertView addButtonWithTitle:NSLocalizedString(@"Dismiss", nil)
                                         type:SIAlertViewButtonTypeCancel
                                      handler:^(SIAlertView *alert) {
                                          NSLog(@"Dismiss Clicked");
                                      }];
                
                alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                [alertView show];
            }
        }];
    }
    
    if (smallRoundedImageData.length > 0) {
//        DLog(@"Uploading Profile Picture Thumbnail");
        PFFile *fileSmallRoundedImage = [PFFile fileWithData:smallRoundedImageData];
        [fileSmallRoundedImage saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!error) {
                DLog(@"Uploaded Profile Picture Thumbnail");
                [[PFUser currentUser] setObject:fileSmallRoundedImage forKey:kUserProfilePicSmallKey];
                [[PFUser currentUser] saveEventually];
            } else {
                DLog(@"Photo failed to save: %@", error);
                //knightka replaced a regular alert view with our custom subclass
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Oops. Something happened.", nil) andMessage:NSLocalizedString(@"Couldn't post your photo. Please try again.", nil)];
                [alertView addButtonWithTitle:NSLocalizedString(@"Dismiss", nil)
                                         type:SIAlertViewButtonTypeCancel
                                      handler:^(SIAlertView *alert) {
                                          NSLog(@"Dismiss Clicked");
                                      }];
                
                alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                [alertView show];
            }
        }];
    }
    
    return YES;
}

#pragma mark - Facebook

+ (void)processFacebookProfilePictureData:(NSData *)newProfilePictureData {
    if (newProfilePictureData.length == 0) {
        DLog(@"Profile picture did not download successfully.");
        return;
    }
    
    // The user's Facebook profile picture is cached to disk. Check if the cached profile picture data matches the incoming profile picture. If it does, avoid uploading this data to Parse.
    
    NSURL *cachesDirectoryURL = [[[NSFileManager defaultManager] URLsForDirectory:NSCachesDirectory inDomains:NSUserDomainMask] lastObject]; // iOS Caches directory
    
    NSURL *profilePictureCacheURL = [cachesDirectoryURL URLByAppendingPathComponent:@"FacebookProfilePicture.jpg"];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:[profilePictureCacheURL path]]) {
        // We have a cached Facebook profile picture
        
        NSData *oldProfilePictureData = [NSData dataWithContentsOfFile:[profilePictureCacheURL path]];
        
        if ([oldProfilePictureData isEqualToData:newProfilePictureData]) {
            DLog(@"Cached profile picture matches incoming profile picture. Will not update.");
            return;
        }
    }
    
    BOOL cachedToDisk = [[NSFileManager defaultManager] createFileAtPath:[profilePictureCacheURL path] contents:newProfilePictureData attributes:nil];
    DLog(@"Wrote profile picture to disk cache: %d", cachedToDisk);
    
    UIImage *image = [UIImage imageWithData:newProfilePictureData];
    
    [self saveProfileImageToParse:image];
}

+ (BOOL)userHasValidFacebookData:(PFUser *)user {
    NSString *facebookId = [user objectForKey:kUserFacebookIDKey];
    return (facebookId && facebookId.length > 0);
}

+ (BOOL)userHasProfilePictures:(PFUser *)user {
    DLog(@"");
    PFFile *profilePictureMedium = [user objectForKey:kUserProfilePicMediumKey];
    PFFile *profilePictureSmall = [user objectForKey:kUserProfilePicSmallKey];
    
    return (profilePictureMedium && profilePictureSmall);
}

#pragma mark Display Name

+ (NSString *)firstNameForDisplayName:(NSString *)displayName {
    if (!displayName || displayName.length == 0) {
        return @"Someone";
    }
    
    NSArray *displayNameComponents = [displayName componentsSeparatedByCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    NSString *firstName = [displayNameComponents objectAtIndex:0];
    
    if (firstName.length > 100) {
        // truncate to 100 so that it fits in a Push payload
        firstName = [firstName substringToIndex:100];
    }
    return firstName;
}

#pragma mark - Non-Parse Utilities
+ (UIImage *)imageFromColor:(UIColor *)color {
    CGRect rect = CGRectMake(0, 0, 1, 1);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, [color CGColor]);
    //  [[UIColor colorWithRed:222./255 green:227./255 blue: 229./255 alpha:1] CGColor]) ;
    CGContextFillRect(context, rect);
    UIImage *img = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return img;
}

@end
