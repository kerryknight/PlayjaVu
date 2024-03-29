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
#import "UIImage+Coloring.h"

@interface FBErrorUtility (PVActivityTracing)
+ (NSUInteger)errorCodeForError:(NSError *)error;
+ (NSUInteger)errorSubcodeForError:(NSError *)error;
@end

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
@property (weak, nonatomic) IBOutlet UIView *facebookButtonBG;
@property (strong, nonatomic) PVLoginViewModel *viewModel;
@end

@implementation PVLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self configureUI];
    
    self.viewModel = [[PVLoginViewModel alloc] init];
    
    [self createRACBindings];
}

#pragma mark - Private Methods
- (void)createRACBindings {
    [self createTextFieldViewModelBindings];
    [self createParseLoginButtonSignal];
    [self createForgotPasswordButtonSignal];
    [self createSignUpButtonSignal];
    [self createLoginWithFacebookButtonSignal];
}

- (void)createTextFieldViewModelBindings {
    RAC(self.viewModel, username) = self.usernameFloatTextField.rac_textSignal;
    RAC(self.viewModel, password) = self.passwordFloatTextField.rac_textSignal;
    
#pragma mark - REMOVE THIS HARDCODE LOGIN
    self.viewModel.username = @"kerry.a.knight@gmail.com";
    self.viewModel.password = @"H2C1spar";
    
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

- (void)createParseLoginButtonSignal {
    @weakify(self);
    self.loginButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        os_activity_initiate("Log in with Parse Click", OS_ACTIVITY_FLAG_DEFAULT, ^{
            @strongify(self);
            [self logIn];
        });
        return [RACSignal empty];
    }];
}

- (void)createForgotPasswordButtonSignal {
    @weakify(self);
    self.forgotPasswordButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        os_activity_initiate("Forgot Password Click", OS_ACTIVITY_FLAG_DEFAULT, ^{
            @strongify(self);
            [self loadForgotPasswordView];
        });
        return [RACSignal empty];
    }];
}

- (void)createSignUpButtonSignal {
    self.signUpButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        [self loadSignUpView];
        return [RACSignal empty];
    }];
}

- (void)createLoginWithFacebookButtonSignal {
    @weakify(self);
    self.facebookButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        os_activity_initiate("Log in with Facebook Click", OS_ACTIVITY_FLAG_DEFAULT, ^{
            @strongify(self);
            [self logInWithFacebook];
        });
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
                [PVStatusBarNotification showWithStatus:NSLocalizedString(@"Welcome back!", nil) dismissAfter:2.0 customStyleName:PVStatusBarSuccess];
            }
            error:^(NSError *error) {
                DLogRed(@"login error and show alert: %@", [error localizedDescription]);
                os_trace_error("Parse login failed error %ld", error.code);
                
                //dismiss the spinner regardless of outcome
                [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
                
                //error logging in, show error message
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Error: %@", nil), [error localizedDescription]];
                [PVStatusBarNotification showWithStatus:message dismissAfter:2.0 customStyleName:PVStatusBarError];
            }
            completed:^{
                os_activity_set_breadcrumb("Parse login completed successfully");
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
            subscribeError:^(NSError *error) {
                os_trace_error("Facebook login error code: %ld, subcode: %ld",
                               [FBErrorUtility errorCodeForError:error],
                               [FBErrorUtility errorSubcodeForError:error]);
                
                DLogError(@"Facebook-friendly ERROR: %@",  [FBErrorUtility userMessageForError:error]);

                NSString *message;
                //dismiss the spinner regardless of outcome
                [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
                
                //check if the error was caused by the use disallowing FB integration within their device settings
                if ([[error userInfo][@"com.facebook.sdk:ErrorLoginFailedReason"] isEqualToString:@"com.facebook.sdk:SystemLoginDisallowedWithoutError"]) {
                    //alert user to allow facebook integration in Settings > Facebook > ApplicationName (NO)
                    message = NSLocalizedString(@"Enable logging into PlayjaVu with Facebook by going to Settings > Facebook > and ensuring PlayjaVu is turned ON.", nil);
                    
                    os_activity_set_breadcrumb("Facebook login error: System login disallowed without error.");
                } else {
                    os_activity_set_breadcrumb("Facebook login error: Some other error.");
                    //error logging in, show error message
                    message = [NSString stringWithFormat:NSLocalizedString(@"%@ \n\nPlease try again.", nil), [FBErrorUtility userMessageForError:error]];
                }
                
                SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:@"Facebook Login Error" andMessage:message];
                [alertView addButtonWithTitle:@"OK"
                                         type:SIAlertViewButtonTypeDefault
                                      handler:^(SIAlertView *alert) {
                                          //called when button pressed
                                      }];
                alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
                [alertView show];
                
            }
            completed:^{
                os_activity_set_breadcrumb("Facebook login completed successfully");
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
    
    return nil;
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
    
    UIColor *drkFacebookBlue = [UIColor colorWithRed:48/255 green:73/255 blue:131/255 alpha:0.2];
    UIImage *blueImage = [UIImage imageWithColor:drkFacebookBlue];
    [self.facebookButton setBackgroundImage:blueImage forState:UIControlStateHighlighted];
    
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
        self.usernameFloatTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Email Address", nil) attributes:@{NSForegroundColorAttributeName:gray}];
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
        self.passwordFloatTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Password", nil) attributes:@{NSForegroundColorAttributeName: gray}];
    }
    [self.container addSubview:self.passwordFloatTextField];
    
    // ********** FLOATING LABEL TEXT FIELDS ********************** //
}

@end
