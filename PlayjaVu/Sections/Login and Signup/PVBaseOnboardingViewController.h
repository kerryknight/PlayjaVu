//
//  PVBaseOnboardingViewController.h
//  PlayjaVu
//
//  Created by Kerry Knight on 1/3/15.
//  Copyright (c) 2015 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "JVFloatLabeledTextField+LabelText.h"

@interface PVBaseOnboardingViewController : UIViewController <UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UIView *container;

- (void)dismissAnyKeyboard;

@end
