//
//  PVForgotPasswordViewModel.h
//  PlayjaVu
//
//  Created by Kerry Knight on 2/7/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PVForgotPasswordViewModel : NSObject

@property (copy, nonatomic) NSString *email;
@property (strong, nonatomic, readonly) RACSignal *emailIsValidEmailSignal;

- (RACSignal *)rac_sendResetPasswordLink;

@end
