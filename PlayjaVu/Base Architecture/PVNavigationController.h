//
//  PVNavigationController.h PlayjaVu
//
//  Created by Kerry Knight on 1/23/14.  Copyright (c) 2014 Kerry Knight. All
//  rights reserved.
//
//  This subclass will contain the gestures for opening and closing
//  side panel; all views will be loaded into this main UI class

#import <UIKit/UIKit.h>
//#import "ICSDrawerController.h"

@interface PVNavigationController : UINavigationController

//@property (weak, nonatomic) ICSDrawerController *drawer;

- (void)resetToRootViewController:(UIViewController *)vc title:(NSString *)title;

@end