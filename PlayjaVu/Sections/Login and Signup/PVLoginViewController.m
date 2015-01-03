//
//  PVLoginViewController.m
//  PlayjaVu
//
//  Created by Kerry Knight on 2/7/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVLoginViewController.h"
#import "PVLoginViewModel.h"
#import "PVAppDelegate.h"
#import "PVAllSTPTransitions.h"
#import "PVSignUpViewController.h"
#import "PVForgotPasswordViewController.h"
#import "JVFloatLabeledTextField+LabelText.h"
#import "MRProgress.h"
#import "SIAlertView.h"
#import "PVAppDelegate.h"

@interface PVLoginViewController () <UITextFieldDelegate>
@property (strong, nonatomic) JVFloatLabeledTextField *usernameFloatTextField;
@property (strong, nonatomic) JVFloatLabeledTextField *passwordFloatTextField;
@property (weak, nonatomic) IBOutlet UIButton *loginButton;
@property (weak, nonatomic) IBOutlet UIButton *forgotPasswordButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIButton *facebookButton;
@property (weak, nonatomic) IBOutlet UIView *usernameBG;
@property (weak, nonatomic) IBOutlet UIView *passwordBG;
@property (weak, nonatomic) IBOutlet UIView *loginButtonBG;
@property (strong, nonatomic) PVLoginViewModel *viewModel;
@end

@implementation PVLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureUI];
    [self configureViewModel];
    [self rac_addButtonCommands];
}

#pragma mark - Private Methods
- (void)configureViewModel {
    self.viewModel = [[PVLoginViewModel alloc] init];
    self.viewModel.active = YES;
}

- (void)rac_addButtonCommands {
    [self rac_createLoginButtonAndTextFieldViewModelBindings];
    [self rac_createForgotPasswordButtonSignal];
    [self rac_createSignUpButtonSignal];
    [self rac_createFacebookButtonSignal];
}

- (void)rac_createLoginButtonAndTextFieldViewModelBindings {
    RAC(self.viewModel, username) = self.usernameFloatTextField.rac_textSignal;
    RAC(self.viewModel, password) = self.passwordFloatTextField.rac_textSignal;
    
    self.loginButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        [self logIn];
        return [RACSignal empty];
    }];
    
    //only show the login button solid color if we have a valid email address and
    //something is entered in the password field in order to reduce erroneous and
    //wasteful parse api calls
    [self.viewModel.usernameAndPasswordCombinedSignal subscribeNext:^(id x) {
        if ([x boolValue]) {
            self.loginButton.userInteractionEnabled = YES;
            //fill in our log in button's bg
            [UIView animateWithDuration:0.25 animations:^{
                self.loginButtonBG.alpha = 1.0;
            }];
            
        } else {
            self.loginButton.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.25 animations:^{
                self.loginButtonBG.alpha = 0.05;
            }];
        }
    }];
}

- (void)rac_createForgotPasswordButtonSignal {
    self.forgotPasswordButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        [self loadForgotPasswordView];
        return [RACSignal empty];
    }];
}

- (void)rac_createSignUpButtonSignal {
    self.signUpButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        
        [self loadSignUpView];
        return [RACSignal empty];
    }];
}

- (void)rac_createFacebookButtonSignal {
    self.facebookButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        [self logInWithFacebook];
        return [RACSignal empty];
    }];
}

- (RACDisposable *)logIn {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //show the spinner
        MRProgressOverlayView *spinnerView = [MRProgressOverlayView showOverlayAddedTo:self.view title:NSLocalizedString(@"Logging in...", Nil) mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [spinnerView setTintColor:kLtGreen];
    });
    
    return [[self.viewModel rac_logIn]
            subscribeNext:^(PFUser *user) {
                //dismiss the spinner regardless of outcome
                [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
                
                //error logging in, show error message
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Welcome back, %@!", nil), user[@"displayName"]];
                [PVStatusBarNotification showWithStatus:message dismissAfter:2.0 customStyleName:PVStatusBarSuccess];
                
            } error:^(NSError *error) {
                DLogRed(@"login error and show alert: %@", [error localizedDescription]);
                
                //dismiss the spinner regardless of outcome
                [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
                
                //error logging in, show error message
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Error: %@", nil), [error localizedDescription]];
                [PVStatusBarNotification showWithStatus:message dismissAfter:2.0 customStyleName:PVStatusBarError];
            } completed:^{
                DLog(@"log in completed successfully, so show main interface");
                //successfully logged in
                //post a notification that our main interface should show which our
                //menu view controller will observe and load as needed
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuShouldShowMainInterfaceNotification object:nil];
            }];
}

- (RACDisposable *)logInWithFacebook {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //show the spinner
        MRProgressOverlayView *spinnerView = [MRProgressOverlayView showOverlayAddedTo:self.view title:NSLocalizedString(@"Logging in...", Nil) mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [spinnerView setTintColor:kLtGreen];
    });
    
    return [[self.viewModel rac_logInWithFacebook]
            subscribeNext:^(id x) {
                DLog(@"rac_logInWithFacebook subscribeNext:");
            }
            error:^(NSError *error) {
                NSString *message;
                //dismiss the spinner regardless of outcome
                [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
                
                //check if the error was caused by the use disallowing FB integration within their device settings
                if ([[error userInfo][@"com.facebook.sdk:ErrorLoginFailedReason"] isEqualToString:@"com.facebook.sdk:SystemLoginDisallowedWithoutError"]) {
                    //alert user to allow facebook integration in Settings > Facebook > ApplicationName (NO)
                    message = NSLocalizedString(@"Enable logging into Bar Golf with Facebook by going to Settings > Facebook > and ensuring Bar Golf is turned ON.", nil);
                } else {
                    //error logging in, show error message
                    message = [NSString stringWithFormat:NSLocalizedString(@"Error: %@ \n\nPlease try again.", nil), [error localizedDescription]];
                }
                
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Facebook Login Error" andMessage:message];
                [alertView addButtonWithTitle:@"OK"
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alert) {
                                          //called when button pressed
                                      }];
                alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                [alertView show];
                
            } completed:^{
                DLog(@"rac_logInWithFacebook completed successfully, so show main interface");
                //successfully logged in

                //dismiss the spinner regardless of outcome
                [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
                
                //error logging in, show error message
                NSString *message = NSLocalizedString(@"Welcome to PlayjaVu!", nil);
                [PVStatusBarNotification showWithStatus:message dismissAfter:2.0 customStyleName:PVStatusBarSuccess];
                
                //post a notification that our main interface should show which our
                //menu view controller will observe and load as needed
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuShouldShowMainInterfaceNotification object:nil];
            }];
}

- (void)loadSignUpView {
    self.navigationController.delegate = [STPTransitionCenter sharedInstance];
    STPCardTransition *transition = [STPCardTransition new];
    transition.reverseTransition = [STPCardTransition new];
    
    PVSignUpViewController *signUpViewController = [[PVSignUpViewController alloc] init];
    [self.navigationController pushViewController:signUpViewController
                                  usingTransition:transition];
}

- (void)loadForgotPasswordView {
    self.navigationController.delegate = [STPTransitionCenter sharedInstance];
    STPCardTransition *transition = [STPCardTransition new];
    transition.reverseTransition = [STPCardTransition new];
    
    PVForgotPasswordViewController *forgotPasswordViewController = [[PVForgotPasswordViewController alloc] init];
    [self.navigationController pushViewController:forgotPasswordViewController
                                  usingTransition:transition];
}

#pragma mark - UI Configuration
- (void)configureUI {
    //set initially to appear disabled
    self.loginButtonBG.alpha = 0.05;
    
    // ********** FLOATING LABEL TEXT FIELDS ********************** //
    //add the username textfield
    self.usernameFloatTextField = [[JVFloatLabeledTextField alloc] initWithFrame:
                                   CGRectMake(kWelcomeTextFieldMargin,
                                              self.usernameBG.frame.origin.y,
                                              self.container.frame.size.width - 2 * kWelcomeTextFieldMargin + 5,
                                              self.usernameBG.frame.size.height)];
    self.usernameFloatTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.usernameFloatTextField.delegate = self;
    self.usernameFloatTextField.floatingLabel.text = NSLocalizedString(@"Email Address", nil);
    [self.usernameFloatTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    self.usernameFloatTextField.returnKeyType = UIReturnKeyGo;
    self.usernameFloatTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //set our placeholder text color
    UIColor *gray = [kMedWhite colorWithAlphaComponent:0.5];
    if ([self.usernameFloatTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.usernameFloatTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Email Address", nil)
                                                                                            attributes:@{NSForegroundColorAttributeName: gray}];
    }
    [self.container addSubview:self.usernameFloatTextField];
    
    //add the password textfield
    self.passwordFloatTextField = [[JVFloatLabeledTextField alloc] initWithFrame:
                                   CGRectMake(kWelcomeTextFieldMargin,
                                              self.passwordBG.frame.origin.y,
                                              self.container.frame.size.width - 2 * kWelcomeTextFieldMargin + 5,
                                              self.passwordBG.frame.size.height)];
    self.passwordFloatTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.passwordFloatTextField.delegate = self;
    self.passwordFloatTextField.returnKeyType = UIReturnKeyGo;
    self.passwordFloatTextField.secureTextEntry = YES;
    self.passwordFloatTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.passwordFloatTextField.floatingLabel.text = NSLocalizedString(@"Password", nil);
    
    //set our placeholder text color
    if ([self.passwordFloatTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.passwordFloatTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Password", nil)
                                                                                            attributes:@{NSForegroundColorAttributeName: gray}];
    }
    [self.container addSubview:self.passwordFloatTextField];
    
    // ********** FLOATING LABEL TEXT FIELDS ********************** //
}

@end
