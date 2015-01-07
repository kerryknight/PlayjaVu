//
//  PVNavigationController.m
//  PlayjaVu
//
//  Created by Kerry Knight on 1/23/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVNavigationController.h"
#import "ReactiveCocoa.h"
#import "RACEXTScope.h"

@interface PVNavigationController ()
@property (strong, nonatomic) UILabel *titleLabel;
@end

@implementation PVNavigationController

- (instancetype)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        [self _configureUI];
    }
    return self;
}

#pragma mark - Public Methods

- (void)resetToRootViewController:(UIViewController *)vc title:(NSString *)title
{
    [self setViewControllers:@[vc]];
    self.titleLabel.text = title;
}

#pragma mark - Private Methods
- (void)_configureUI
{
    // nav bar
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.barTintColor = kLtGray;
    
    //add the custom title label
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.navigationBar.frame.size.width, self.navigationBar.frame.size.height)];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setFont:[UIFont fontWithName:kHelveticaLight size:18.0f]];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setShadowColor:[UIColor darkGrayColor]];
    [self.titleLabel setShadowOffset:CGSizeMake(0, 1)];
    
    [self.navigationBar addSubview:self.titleLabel];
    
    self.view.backgroundColor = kMedGray;
}

//#pragma mark - ICSDrawerControllerPresenting
//- (void)drawerControllerWillOpen:(ICSDrawerController *)drawerController
//{
//    self.view.userInteractionEnabled = NO;
//}
//
//- (void)drawerControllerDidClose:(ICSDrawerController *)drawerController
//{
//    self.view.userInteractionEnabled = YES;
//}
//
//#pragma mark - Open drawer button
//- (void)openDrawer:(id)sender
//{
//    [self.drawer open];
//}

@end
