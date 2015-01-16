//
//  PVLoginViewModel.m
//  PlayjaVu
//
//  Created by Kerry Knight on 2/7/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVLoginViewModel.h"
#import "NSString+EmailAdditions.h"
#import "PFFacebookUtils+RACExtensions.h"
#import "PFFile+RACExtensions.h"
#import "UIImage+ResizeAdditions.h"
#import "PVFBUser.h"

@interface PVLoginViewModel ()
@property (strong, nonatomic) RACSignal *usernameIsValidEmailSignal;
@property (strong, nonatomic) RACSignal *passwordExistsSignal;
@end

@implementation PVLoginViewModel

#pragma mark - Public Methods
- (RACSignal *)rac_logIn
{
#if DEVELOPER_BYPASS_LOGIN_MODE
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:subscriber];
        [subscriber sendCompleted];
        return nil;
    }];
#endif
    return [PFUser rac_logInWithUsername:self.username password:self.password];
}

- (RACSignal *)rac_logInWithFacebook
{
#if DEVELOPER_BYPASS_LOGIN_MODE
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:subscriber];
        [subscriber sendCompleted];
        return nil;
    }];
#endif
    
    return
    [[[[PFFacebookUtils rac_logInWithPermissions:kFacebookPermissionsList]
    flattenMap: ^id (id value) {
        return [PFFacebookUtils rac_makeRequestForMe];
    }]
    flattenMap: ^id (id result) {
        return [self rac_saveFacebookDataForUserToParse:result];
    }]
    deliverOn:[RACScheduler mainThreadScheduler]];
}

#pragma mark - Private Methods
- (RACSignal *)rac_saveFacebookDataForUserToParse:(NSDictionary *)facebookResult {
//    NSString *facebookName = facebookResult[@"username"];
//    NSString *profilePicURL = facebookResult[kUserProfilePicSmallKey];
    
    PVFBUser *fbUser = [PVFBUser object];
    fbUser.facebookId = facebookResult[@"id"];
    fbUser.firstName = facebookResult[@"first_name"];
    fbUser.lastName = facebookResult[@"last_name"];
    fbUser.username = facebookResult[@"name"];
    fbUser.email = facebookResult[@"email"];
    fbUser.profileLink = facebookResult[@"link"];
    fbUser.birthday = [self dateFromJSONString:facebookResult[@"birthday"]];
    fbUser.timezone = facebookResult[@"timezone"];
    fbUser.location = facebookResult[@"location"][@"name"];
    fbUser.gender = [facebookResult[@"gender"] isEqualToString:@"male"] ? PVGenderTypeMale : PVGenderTypeFemale;
    
//    DLogCyan(@"fbUser: %@", fbUser);
    
    [[PFUser currentUser] setObject:fbUser forKey:@"facebookUser"];
    
    if (![[PFUser currentUser] objectForKey:kUserEmailKey]) {
        [[PFUser currentUser] setObject:fbUser.email forKey:@"email"];
    }
    
    return [[PFUser currentUser] rac_saveEventually];
}

- (NSDate *)dateFromJSONString:(NSString *)dateString
{
    return [[[self class] dateFormatter] dateFromString:dateString];
}

+ (NSDateFormatter *)dateFormatter {
    static NSDateFormatter *formatter = nil;
    if (!formatter) {
        formatter = [[NSDateFormatter alloc] init];
        [formatter setDateFormat:@"yyyy-MM-dd"];
    }
    return formatter;
}

#pragma mark - Public Signal Properties
- (RACSignal *)usernameAndPasswordCombinedSignal
{
    return
    [RACSignal combineLatest:@[self.usernameIsValidEmailSignal, self.passwordExistsSignal]
    reduce:^(NSNumber *user, NSNumber *pass) {
        return @(user.intValue > 0 && pass.intValue > 0);//both must be 1 to enable
    }];
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
