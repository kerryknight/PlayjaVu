//
//  PVLoginViewModel.m
//  Bar Golf
//
//  Created by Kerry Knight on 2/7/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVLoginViewModel.h"
#import "NSString+EmailAdditions.h"
#import "PFFacebookUtils+RACExtensions.h"
#import "PFFile+RACExtensions.h"
#import "UIImage+ResizeAdditions.h"

@interface PVLoginViewModel ()
@property (strong, nonatomic) RACSignal *usernameIsValidEmailSignal;
@property (strong, nonatomic) RACSignal *passwordExistsSignal;
@end

@implementation PVLoginViewModel

#pragma mark - Public Methods
- (RACSignal *)rac_logIn
{
    return [PFUser rac_logInWithUsername:self.username password:self.password];
}

- (RACSignal *)rac_logInWithFacebook
{
    __block id facebookRequestResult;
    
    return [[[[[[PFFacebookUtils rac_logInWithPermissions:kFacebookPermissionsList]
                flattenMap: ^id (id value) {
                    return [PFFacebookUtils rac_getCurrentFacebookUserConnectionInfo];
                }]
               flattenMap: ^id (id result) {
                   facebookRequestResult = result;
                   NSString *facebookId = result[@"id"];
                   return [PFFacebookUtils rac_getCurrentFacebookUsersProfilePicture:facebookId];
               }]
              flattenMap: ^id (id imageData) {
                  return [self rac_savePFFileFromImageData:imageData];
              }]
             flattenMap: ^id (PFFile *imageFile) {
                 facebookRequestResult[kUserProfilePicSmallKey] = imageFile;
                 return [PFFacebookUtils rac_saveFacebookUserDataToParseForCurrentUser:facebookRequestResult];
             }]
            deliverOn:[RACScheduler mainThreadScheduler]];
    return nil;
}

#pragma mark - Public Signal Properties
- (RACSignal *)usernameAndPasswordCombinedSignal
{
    return [RACSignal combineLatest:@[self.usernameIsValidEmailSignal, self.passwordExistsSignal]
                             reduce:^(NSNumber *user, NSNumber *pass) {
                                 return @(user.intValue > 0 && pass.intValue > 0);//both must be 1 to enable
                             }];
}

#pragma mark - Private Methods
- (RACSubject *)rac_savePFFileFromImageData:(NSData *)imageData
{
    RACSubject *subject = [RACSubject subject];
    
    UIImage *image = [UIImage imageWithData:imageData];
    UIImage *smallImage = [image thumbnailImage:64 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationLow];
    
    NSData *newImageData = UIImageJPEGRepresentation(smallImage, 1.0); // using JPEG for larger pictures
    
    if (newImageData.length == 0) {
        return nil;
    }
    
    PFFile *imageFile = [PFFile fileWithData:newImageData];
    
    [[imageFile rac_save] subscribeError:^(NSError *error) {
        [subject sendError:error];
    } completed:^{
        //on successfully saving the image to parse, pass it on to our currentUser
        //so we can save it with our user account
        [subject sendNext:imageFile];
        [subject sendCompleted];
    }];
    
    return subject;
}

#pragma mark - Private Signal Properties
- (RACSignal *)usernameIsValidEmailSignal
{
	if (!_usernameIsValidEmailSignal) {
		_usernameIsValidEmailSignal = [RACObserve(self, username) map:^id(NSString *user) {
			return @([user isValidEmail]);
		}];
	}
	return _usernameIsValidEmailSignal;
}

- (RACSignal *)passwordExistsSignal
{
	if (!_passwordExistsSignal) {
		_passwordExistsSignal = [RACObserve(self, password) map:^id(NSString *pass) {
			return @(pass.length > 0);
		}];
	}
	return _passwordExistsSignal;
}

@end
