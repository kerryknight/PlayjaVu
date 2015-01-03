//
//  PVForgotPasswordViewController.h
//  PlayjaVu
//
//  Created by Kerry Knight on 2/7/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVBaseOnboardingViewController.h"

@class PVForgotPasswordViewModel;

@interface PVForgotPasswordViewController : PVBaseOnboardingViewController
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *sendResetLinkButton;
@property (weak, nonatomic) IBOutlet UIView *emailAddressBG;
@property (weak, nonatomic) IBOutlet UIView *sendResetLinkButtonBG;
@property (strong, nonatomic, readonly) PVForgotPasswordViewModel *viewModel;
@end
