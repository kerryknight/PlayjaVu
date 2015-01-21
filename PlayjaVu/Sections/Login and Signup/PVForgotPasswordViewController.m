//
//  PVForgotPasswordViewController.m
//  PlayjaVu
//
//  Created by Kerry Knight on 2/7/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVForgotPasswordViewController.h"
#import "PVForgotPasswordViewModel.h"
#import "JVFloatLabeledTextField+LabelText.h"
#import "MRProgress.h"
#import "PVAppDelegate.h"

@interface PVForgotPasswordViewController () <UITextFieldDelegate>
@property (strong, nonatomic) JVFloatLabeledTextField *emailAddressFloatTextField;
@property (strong, nonatomic, readwrite) PVForgotPasswordViewModel *viewModel;
@end

@implementation PVForgotPasswordViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self configureUI];
    
    self.viewModel = [[PVForgotPasswordViewModel alloc] init];
    
    [self rac_addButtonCommands];
}

#pragma mark - Private Methods
- (void)rac_addButtonCommands
{
    [self rac_createResetLinkButtonAndTextFieldViewModelBindings];
    [self rac_createCancelButtonSignal];}

- (void)rac_createResetLinkButtonAndTextFieldViewModelBindings
{
    RAC(self.viewModel, email) = self.emailAddressFloatTextField.rac_textSignal;
    
    @weakify(self);
    self.sendResetLinkButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        os_activity_initiate("Send Reset Password Link Click", OS_ACTIVITY_FLAG_DEFAULT, ^{
            @strongify(self);
            [self dismissAnyKeyboard];
            [self sendResetLink];
        });
        return [RACSignal empty];
    }];
    
    //only show the login button solid color if we have a valid email address and
    //something is entered in the password field in order to reduce erroneous and
    //wasteful parse api calls
    [self.viewModel.emailIsValidEmailSignal subscribeNext:^(id x) {
        if ([x boolValue]) {
            self.sendResetLinkButton.userInteractionEnabled = YES;
            //fill in our log in button's bg
            [UIView animateWithDuration:0.25 animations:^{
                self.sendResetLinkButtonBG.alpha = 1.0;
            }];
        } else {
            self.sendResetLinkButton.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.25 animations:^{
                self.sendResetLinkButtonBG.alpha = 0.4;
            }];
        }
    }];
}

- (void)rac_createCancelButtonSignal
{
    self.cancelButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        [self.navigationController popViewControllerAnimated:YES];
        return [RACSignal empty];
    }];
}

- (RACDisposable *)sendResetLink
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //dismiss the spinner regardless of outcome
        MRProgressOverlayView *spinnerView = [MRProgressOverlayView showOverlayAddedTo:self.view title:NSLocalizedString(@"Sending reset link...", Nil) mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [spinnerView setTintColor:kLtGreen];
    });
    
	return [[[self.viewModel rac_sendResetPasswordLink] deliverOn:[RACScheduler mainThreadScheduler]]
	        subscribeError:^(NSError *error) {
                os_trace_error("Send password reset link failed error %ld", error.code);
                DLogRed(@"reset link send error show alert: %@", [error localizedDescription]);
                
                //dismiss the spinner regardless of outcome
                [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
                
                //error logging in, show error message
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Error: %@", nil), [error localizedDescription]];
                [PVStatusBarNotification showWithStatus:message dismissAfter:2.0 customStyleName:PVStatusBarError];
                
            } completed:^{
                os_activity_set_breadcrumb("Send reset password completed successfully");
                DLog(@"sent reset link successfully, go back to login view");
                
                [PVStatusBarNotification showWithStatus:NSLocalizedString(@"Email with reset link sent!", nil) dismissAfter:2.0 customStyleName:PVStatusBarSuccess];
                //successfully sent email
                [self.navigationController popViewControllerAnimated:YES];
                
            }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self.viewModel.emailIsValidEmailSignal subscribeNext:^(id x) {
        [self sendResetLink];
    }];
    return YES;
}

#pragma mark - UI Configuration
- (void)configureUI
{
    //set initially to appear disabled
    self.sendResetLinkButtonBG.alpha = 0.4;
    
    // ********** FLOATING LABEL TEXT FIELDS ********************** //
    //add the username textfield
    self.emailAddressFloatTextField = [[JVFloatLabeledTextField alloc] initWithFrame:
                                   CGRectMake(kWelcomeTextFieldMargin,
                                              self.emailAddressBG.frame.origin.y,
                                              self.container.frame.size.width - 2 * kWelcomeTextFieldMargin + 5,
                                              self.emailAddressBG.frame.size.height)];
    self.emailAddressFloatTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.emailAddressFloatTextField.delegate = self;
    [self.emailAddressFloatTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    self.emailAddressFloatTextField.returnKeyType = UIReturnKeyGo;
    self.emailAddressFloatTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    
    //set our placeholder text color
    UIColor *gray = [kMedWhite colorWithAlphaComponent:0.5];
    
    if ([self.emailAddressFloatTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.emailAddressFloatTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Email Address", nil) attributes:@{NSForegroundColorAttributeName: gray}];
    }
    
    [self.container addSubview:self.emailAddressFloatTextField];
    // ********** FLOATING LABEL TEXT FIELDS ********************** //
}

@end
