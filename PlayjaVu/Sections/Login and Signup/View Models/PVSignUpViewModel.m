//
//  PVSignUpViewModel.m
//  PlayjaVu
//
//  Created by Kerry Knight on 2/7/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVSignUpViewModel.h"
#import "NSString+EmailAdditions.h"

@interface PVSignUpViewModel ()
@property (strong, nonatomic, readwrite) RACSignal *usernameIsValidEmailSignal;
@property (strong, nonatomic, readwrite) RACSignal *passwordIsValidSignal;
@property (strong, nonatomic, readwrite) RACSignal *confirmPasswordMatchesSignal;
@property (strong, nonatomic, readwrite) RACSignal *allFieldsCombinedSignal;
@property (strong, nonatomic, readwrite) RACSignal *sendErrorSignal;
@property (assign, nonatomic, readwrite) BOOL passwordTextLengthIsUnderLimit;
@end

@implementation PVSignUpViewModel

#pragma mark - Life Cycle

- (instancetype)init
{
    self = [super init];
    if (self) {
        _sendErrorSignal = [[RACSubject subject] setNameWithFormat:@"PVSignUpViewModel sendErrorSignal"];
    }
    return self;
}

#pragma mark - Public Methods
- (RACSignal *)rac_signUpNewUser
{
    //create a new PFUser with username and password set; the email address will double as the username
    PFUser *user = [PFUser user];
    user.username = self.username;
    user.password = self.password;
    user.email = self.username;
    
    return [[user rac_signUp] deliverOn:[RACScheduler immediateScheduler]];
}

#pragma mark - Public Normal Properties
- (BOOL)passwordTextLengthIsUnderLimit
{
    BOOL underLimit = (self.password.length < kMaximumPasswordLength);
    
    if (!underLimit) {
        NSString *characterLimit = [NSString stringWithFormat:NSLocalizedString(@"Passwords are limited to %i characters", nil), kMaximumPasswordLength];
        [(RACSubject *)self.sendErrorSignal sendNext:characterLimit];
    }
    
    return underLimit;
}

#pragma mark - Public Signal Properties
- (RACSignal *)allFieldsCombinedSignal
{
    return [RACSignal combineLatest:@[self.usernameIsValidEmailSignal, self.passwordIsValidSignal, self.confirmPasswordMatchesSignal]
                             reduce:^(NSNumber *user, NSNumber *pass, NSNumber *confirmPass) {
                                 //only count passwords matching if we have a valid password
                                 BOOL passesMatch = (confirmPass.intValue > 0 && pass.intValue > 0);
                                 int total = user.intValue + pass.intValue + passesMatch;
                                
                                 return @(total == 3);
                             }];
}

#pragma mark - Private Methods
- (BOOL)isValidPassword
{
    BOOL isValid = YES;
    //ensure password is long enough
    if (self.password.length < kMinimumPasswordLength || self.password.length > kMaximumPasswordLength) {
        isValid = NO;
        return isValid;
    }
    
    //check the characters used in the password field; new passwords must contain at least 1 digit
    NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
    
    if ([self.password rangeOfCharacterFromSet:set].location == NSNotFound) {
        //no numbers found
        isValid = NO;
        return isValid;
    }
    
    //ensure our display name doesn't include any special characters so we don't get lots of dicks and stuff for names 8======D
    set = [NSCharacterSet characterSetWithCharactersInString:@" "];
    
    if ([self.password rangeOfCharacterFromSet:set].location != NSNotFound) {
        //special characters found
        NSString *error = [NSString stringWithFormat:NSLocalizedString(@"Passwords can't contain spaces.", nil)];
        [(RACSubject *)self.sendErrorSignal sendNext:error];
        isValid = NO;
        return isValid;
    }
    return isValid;
}

- (BOOL)confirmPasswordMatchesPassword
{
    return [self.password isEqualToString:self.confirmPassword];
}

#pragma mark - Private Signal Properties
- (RACSignal *)usernameIsValidEmailSignal
{
	if (!_usernameIsValidEmailSignal) {
		_usernameIsValidEmailSignal = [RACObserve(self, username) map: ^id (NSString *user) {
		    return @([user isValidEmail]);
		}];
	}
	return _usernameIsValidEmailSignal;
}

- (RACSignal *)passwordIsValidSignal
{
	if (!_passwordIsValidSignal) {
		_passwordIsValidSignal = [RACObserve(self, password) map: ^id (NSString *pass) {
		    return @([self isValidPassword]);
		}];
	}
	return _passwordIsValidSignal;
}

- (RACSignal *)confirmPasswordMatchesSignal
{
	if (!_confirmPasswordMatchesSignal) {
		_confirmPasswordMatchesSignal = [RACSignal combineLatest:@[self.passwordIsValidSignal,
		                                                           RACObserve(self, confirmPassword)]
		                                                  reduce: ^(NSNumber *pass, NSString *confirmPass) {
                                                              // we only care if matching passwords if the password is valid
                                                              return @(([self confirmPasswordMatchesPassword] && pass.intValue > 0));
                                                          }];
	}
	return _confirmPasswordMatchesSignal;
}

@end
