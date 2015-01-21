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
#import "PVUser.h"

@interface PVLoginViewModel ()
@property (strong, nonatomic) RACSignal *usernameIsValidEmailSignal;
@property (strong, nonatomic) RACSignal *passwordExistsSignal;
@end

@implementation PVLoginViewModel

#pragma mark - Public Methods
- (RACSignal *)rac_logIn
{
    os_activity_set_breadcrumb("kick off Parse login");
    
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
    os_activity_set_breadcrumb("kick off Facebook login");
    
#if DEVELOPER_BYPASS_LOGIN_MODE
    return [RACSignal createSignal:^RACDisposable *(id<RACSubscriber> subscriber) {
        [subscriber sendNext:subscriber];
        [subscriber sendCompleted];
        return nil;
    }];
#endif
    
    return [[PFFacebookUtils rac_logInWithPermissions:@[@"public_profile", @"email", @"user_friends"]]
    deliverOn:[RACScheduler mainThreadScheduler]];
}

//#pragma mark - Private Methods

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
