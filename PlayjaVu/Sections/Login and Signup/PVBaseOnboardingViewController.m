//
//  PVBaseOnboardingViewController.m
//  PlayjaVu
//
//  Created by Kerry Knight on 1/3/15.
//  Copyright (c) 2015 Kerry Knight. All rights reserved.
//

#import "PVBaseOnboardingViewController.h"

@implementation PVBaseOnboardingViewController

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // ********** FLOATING LABEL TEXT FIELDS ********************** //
    UIColor *gray = [kMedWhite colorWithAlphaComponent:0.5];
    [[JVFloatLabeledTextField appearance] setFloatingLabelActiveTextColor:kLtGreen];
    [[JVFloatLabeledTextField appearance] setFloatingLabelTextColor:gray];
    [[JVFloatLabeledTextField appearance] setFloatingLabelFont:[UIFont fontWithName:kHelveticaLight size:12.0f]];
    [[JVFloatLabeledTextField appearance] setFloatingLabelYPadding:5];
    [[JVFloatLabeledTextField appearance] setFont:[UIFont fontWithName:kHelveticaLight size:20.0f]];
    [[JVFloatLabeledTextField appearance] setTextColor:kMedWhite];
    [JVFloatLabeledTextField appearance].keyboardAppearance = UIKeyboardAppearanceDark;
}

#pragma mark - Public Methods
- (void)dismissAnyKeyboard
{
    NSArray *subviews = [self.container subviews];
    
    for (UIView *aview in subviews) {
        if ([aview isKindOfClass: [JVFloatLabeledTextField class]]) {
            JVFloatLabeledTextField *textField = (JVFloatLabeledTextField *)aview;
            
            if ([textField isEditing]) {
                [textField resignFirstResponder];
            }
        }
    }
}

#pragma mark - Private Methods
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self dismissAnyKeyboard];
    [super touchesBegan:touches withEvent:event];
}

- (void)viewDidLayoutSubviews
{
    // Set frame for elements on smaller phones
    if (IS_IPHONE_4_OR_LESS) {
        self.container.frame = CGRectMake(self.container.frame.origin.x,
                                          30, // magic numbers!!!
                                          self.container.frame.size.width,
                                          self.container.frame.size.height);
    }
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

@end
