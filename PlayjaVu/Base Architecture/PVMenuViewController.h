// PVMenuViewController.h
//  PlayjaVu
//
//  Created by Kerry Knight on 1/4/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PVAppDelegate.h"
#import "PVNavigationController.h"
#import "ICSDrawerController.h"
#import "PVWelcomeViewController.h"
#import "PVMyProfileViewController.h"

@interface PVMenuViewController : UIViewController <ICSDrawerControllerChild, ICSDrawerControllerPresenting>

@property(nonatomic, weak) ICSDrawerController *drawer;

- (void)showWelcomeView;

@end