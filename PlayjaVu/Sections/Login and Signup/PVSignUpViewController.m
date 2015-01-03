//
//  PVSignUpViewController.m
//  Bar Golf
//
//  Created by Kerry Knight on 2/7/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVSignUpViewController.h"
#import "PVSignUpViewModel.h"
#import "PVAppDelegate.h"
#import "NimbusCore.h"
#import "NimbusAttributedLabel.h"
#import "MRProgress.h"

@interface PVSignUpViewController () <NIAttributedLabelDelegate>
@property (strong, nonatomic) JVFloatLabeledTextField *usernameFloatTextField;
@property (strong, nonatomic) JVFloatLabeledTextField *passwordFloatTextField;
@property (strong, nonatomic) JVFloatLabeledTextField *confirmPasswordFloatTextField;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *signUpButton;
@property (weak, nonatomic) IBOutlet UIView *usernameBG;
@property (weak, nonatomic) IBOutlet UIView *passwordBG;
@property (weak, nonatomic) IBOutlet UIView *confirmPasswordBG;
@property (weak, nonatomic) IBOutlet UIView *signUpButtonBG;
@property (strong, nonatomic) PVSignUpViewModel *viewModel;
@end

@implementation PVSignUpViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self configureUI];
    [self configureViewModel];
    [self rac_addButtonCommands];
    [self rac_racifyInputTextFields];
}

#pragma mark - Private Methods
- (void)configureViewModel
{
    self.viewModel = [[PVSignUpViewModel alloc] init];
    self.viewModel.active = YES;
    
    //subscribe to our viewModel's signal
    [[self.viewModel.sendErrorSignal deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id error) {
        //post error to status bar notification
        NSString *message = [NSString stringWithFormat:@"%@", error];
        [PVStatusBarNotification showWithStatus:message dismissAfter:2.0
                                customStyleName:PVStatusBarError];
    }];
}

- (void)rac_addButtonCommands
{
    [self rac_createSignUpButtonAndTextFieldViewModelBindings];
    [self rac_createCancelButtonSignal];}

- (void)rac_createSignUpButtonAndTextFieldViewModelBindings
{
    RAC(self.viewModel, username) = self.usernameFloatTextField.rac_textSignal;
    RAC(self.viewModel, password) = self.passwordFloatTextField.rac_textSignal;
    RAC(self.viewModel, confirmPassword) = self.confirmPasswordFloatTextField.rac_textSignal;
    
    self.signUpButton.rac_command = [[RACCommand alloc] initWithSignalBlock:^(id _) {
        [self signUp];
        return [RACSignal empty];
    }];
    
    //only show the login button solid color if we have a valid email address and
    //something is entered in the password field in order to reduce erroneous and
    //wasteful parse api calls
    [self.viewModel.allFieldsCombinedSignal subscribeNext:^(id x) {
        if ([x boolValue]) {
            self.signUpButton.userInteractionEnabled = YES;
            //fill in our log in button's bg
            [UIView animateWithDuration:0.25 animations:^{
                self.signUpButtonBG.alpha = 1.0;
            }];
        } else {
            self.signUpButton.userInteractionEnabled = NO;
            [UIView animateWithDuration:0.25 animations:^{
                self.signUpButtonBG.alpha = 0.4;
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

- (RACDisposable *)signUp
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //show the spinner
        MRProgressOverlayView *spinnerView = [MRProgressOverlayView showOverlayAddedTo:self.view title:NSLocalizedString(@"Signing up...", Nil) mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [spinnerView setTintColor:kLtGreen];
    });
    
	return [[[self.viewModel rac_signUpNewUser] deliverOn:[RACScheduler mainThreadScheduler]]
	        subscribeError:^(NSError *error) {
                DLogRed(@"sign up error and show alert: %@", [error localizedDescription]);
                
                //dismiss the spinner regardless of outcome
                [MRProgressOverlayView dismissOverlayForView:self.view animated:YES];
                
                //error logging in, show error message
                NSString *message = [NSString stringWithFormat:NSLocalizedString(@"Error: %@", nil), [error localizedDescription]];
                [PVStatusBarNotification showWithStatus:message dismissAfter:2.0 customStyleName:PVStatusBarError];
                
            } completed: ^{
                DLog(@"sign up completed successfully, so show main interface");
                
                [PVStatusBarNotification showWithStatus:NSLocalizedString(@"Success! Welcome, new bar golfer!", nil) dismissAfter:2.0 customStyleName:PVStatusBarSuccess];
                //successfully logged in
                
                //post a notification that our main interface should show which our
                //menu view controller will observe and load as needed
                [[NSNotificationCenter defaultCenter] postNotificationName:kMenuShouldShowMainInterfaceNotification object:nil];
            }];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.passwordFloatTextField) {
        if (self.viewModel.passwordTextLengthIsUnderLimit) {
            //always allow changes if we're under our character limit
            return YES;
        } else {
            //if, at our limit, should still always allow backspacing (will be passed in as @"" string)
            return [string isEqualToString:@""] ? YES : NO;
        }
    }
    
    return YES;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == self.passwordFloatTextField) {
        [self.passwordFloatTextField pv_setFloatingLabelText:NSLocalizedString(@"Password (Minimum 7 characters and 1 number)", nil)];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UI Configuration
- (void)configureUI
{
    //set initially to appear disabled
    self.signUpButtonBG.alpha = 0.4;
    
    // ********** FLOATING LABEL TEXT FIELDS ********************** //
    //add the username textfield
    self.usernameFloatTextField = [[JVFloatLabeledTextField alloc] initWithFrame:
                                   CGRectMake(kWelcomeTextFieldMargin,
                                              self.usernameBG.frame.origin.y,
                                              self.container.frame.size.width - 2 * kWelcomeTextFieldMargin + 5,
                                              self.usernameBG.frame.size.height)];
    self.usernameFloatTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.usernameFloatTextField.delegate = self;
    [self.usernameFloatTextField setKeyboardType:UIKeyboardTypeEmailAddress];
    self.usernameFloatTextField.returnKeyType = UIReturnKeyDone;
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
    self.passwordFloatTextField.returnKeyType = UIReturnKeyDone;
    self.passwordFloatTextField.secureTextEntry = YES;
    self.passwordFloatTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //set our placeholder text color
    if ([self.passwordFloatTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.passwordFloatTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Password", nil)
                                                                                            attributes:@{NSForegroundColorAttributeName: gray}];
    }
    
    [self.container addSubview:self.passwordFloatTextField];
    
    //add the password confirmation textfield
    self.confirmPasswordFloatTextField = [[JVFloatLabeledTextField alloc] initWithFrame:
                                          CGRectMake(kWelcomeTextFieldMargin,
                                                     self.confirmPasswordBG.frame.origin.y,
                                                     self.container.frame.size.width - 2 * kWelcomeTextFieldMargin + 5,
                                                     self.confirmPasswordBG.frame.size.height)];
    self.confirmPasswordFloatTextField.clearButtonMode = UITextFieldViewModeWhileEditing;
    self.confirmPasswordFloatTextField.delegate = self;
    self.confirmPasswordFloatTextField.returnKeyType = UIReturnKeyDone;
    self.confirmPasswordFloatTextField.secureTextEntry = YES;
    self.confirmPasswordFloatTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    //set our placeholder text color
    if ([self.confirmPasswordFloatTextField respondsToSelector:@selector(setAttributedPlaceholder:)]) {
        self.confirmPasswordFloatTextField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:NSLocalizedString(@"Confirm Password", nil)
                                                                                                   attributes:@{NSForegroundColorAttributeName: gray}];
    }
    [self.container addSubview:self.confirmPasswordFloatTextField];
    // ********** FLOATING LABEL TEXT FIELDS ********************** //
    
    [self configureAgreementAttributedString];
}

- (void)rac_racifyInputTextFields
{
    //change the password font color from white to green when it's a legal password
    [self.viewModel.passwordIsValidSignal subscribeNext:^(id x) {
        if ([x boolValue]) {
            //it's a valid password, turn it green
            self.passwordFloatTextField.textColor = kLtGreen;
        } else {
            //not valid, keep white
            self.passwordFloatTextField.textColor = kLtWhite;
        }
    }];
    
    //change the confirm password font color from white to green when it matches password
    [self.viewModel.confirmPasswordMatchesSignal  subscribeNext:^(id x) {
        if ([x boolValue]) {
            //it matches, turn it green
            self.confirmPasswordFloatTextField.textColor = kLtGreen;
        } else {
            //not valid, keep white
            self.confirmPasswordFloatTextField.textColor = kLtWhite;
        }
    }];
}

#pragma mark - Attributed String Agreement label
- (void)configureAgreementAttributedString
{
    //add the password footer label
    NIAttributedLabel *agreementLabel = [[NIAttributedLabel alloc] initWithFrame:CGRectMake(self.confirmPasswordBG.frame.origin.x,
                                                                                            self.confirmPasswordBG.frame.origin.y + self.confirmPasswordBG.frame.size.height + 50,
                                                                                            self.confirmPasswordBG.frame.size.width,
                                                                                            self.confirmPasswordBG.frame.size.height)];
    agreementLabel.font = [UIFont fontWithName:kHelveticaLight size:13.0f];
    agreementLabel.textAlignment = NSTextAlignmentCenter;
    agreementLabel.backgroundColor = [UIColor clearColor];
    agreementLabel.textColor = kLtWhite;
    CALayer *agreementLayer = agreementLabel.layer;
    agreementLayer.shadowOpacity = 0.0f;
    agreementLabel.lineBreakMode = NSLineBreakByWordWrapping;
    agreementLabel.autoresizingMask = UIViewAutoresizingFlexibleDimensions;
    agreementLabel.numberOfLines = 0;
    
    // Set link's color
    agreementLabel.linkColor = kLtGreen;
    
    // When the user taps a link we can change the way the link text looks.
    agreementLabel.attributesForHighlightedLink = [NSDictionary dictionaryWithObject:(id)kLtGreen.CGColor forKey:(NSString *)kCTForegroundColorAttributeName];
    
    // In order to handle the events generated by the user tapping a link we must implement the
    // delegate.
    agreementLabel.delegate = self;
    
    // By default the label will not automatically detect links. Turning this on will cause the label
    // to pass through the text with an NSDataDetector, highlighting any detected URLs.
    agreementLabel.autoDetectLinks = YES;
    
    // By default links do not have underlines and this is generally accepted as the standard on iOS.
    // If, however, you do wish to show underlines, you can enable them like so:
    //    self.agreementLabel.linksHaveUnderlines = YES;
    
    agreementLabel.text = @"By signing up, you accept PlayjaVu's\nTerms of Service and Privacy Policy.";
    
#warning STILL NEED REAL URLS FOR TOS AND PRIVACY
    NSRange linkRange = [agreementLabel.text rangeOfString:@"Terms of Service"];
    
    // Explicitly adds a link at a given range.
    [agreementLabel addLink:[NSURL URLWithString:@"http://www.playjavu.com/terms"] range:linkRange];
    
    NSRange linkRange2 = [agreementLabel.text rangeOfString:@"Privacy Policy"];
    
    // Explicitly adds a link at a given range.
    [agreementLabel addLink:[NSURL URLWithString:@"http://www.playjavu.com/privacy"] range:linkRange2];
    [self.container addSubview:agreementLabel];
}

#pragma mark - NIAttributedLabelDelegate

- (void)attributedLabel:(NIAttributedLabel *)attributedLabel didSelectTextCheckingResult:(NSTextCheckingResult *)result atPoint:(CGPoint)point
{
    // In a later example we will show how to push a Nimbus web controller onto the navigation stack
    // rather than punt the user out of the application to Safari.
    [[UIApplication sharedApplication] openURL:result.URL];
}

@end
