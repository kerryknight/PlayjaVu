//
//  PVSignUpViewModel.h
//  PlayjaVu
//
//  Created by Kerry Knight on 2/7/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "RVMViewModel.h"

@interface PVSignUpViewModel : RVMViewModel

@property (copy, nonatomic) NSString *username;
@property (copy, nonatomic) NSString *password;
@property (copy, nonatomic) NSString *confirmPassword;
@property (strong, nonatomic, readonly) RACSignal *allFieldsCombinedSignal;
@property (strong, nonatomic, readonly) RACSignal *usernameIsValidEmailSignal;
@property (strong, nonatomic, readonly) RACSignal *passwordIsValidSignal;
@property (strong, nonatomic, readonly) RACSignal *confirmPasswordMatchesSignal;
@property (strong, nonatomic, readonly) RACSignal *sendErrorSignal;
@property (assign, nonatomic, readonly) BOOL passwordTextLengthIsUnderLimit;

- (BOOL)isValidPassword;
- (BOOL)confirmPasswordMatchesPassword;
- (RACSignal *)rac_signUpNewUser;

@end
