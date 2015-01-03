//
//  PVLoginViewModel.h
//  PlayjaVu
//
//  Created by Kerry Knight on 2/7/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//
#import "RVMViewModel.h"

@interface PVLoginViewModel : RVMViewModel

@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *forgottenEmail;
@property (strong, nonatomic) RACSignal *usernameAndPasswordCombinedSignal;

- (RACSignal *)rac_logIn;
- (RACSignal *)rac_logInWithFacebook;

@end
