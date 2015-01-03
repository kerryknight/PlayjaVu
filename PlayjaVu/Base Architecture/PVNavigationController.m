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
@property (strong, nonatomic) UIView *dropdown;
@property (assign, nonatomic) BOOL dropdownIsVisible;
@property (strong, nonatomic) UILabel *addressLabel;
@property (strong, nonatomic) UIButton *refreshButton;
@end

@implementation PVNavigationController

- (instancetype)initWithRootViewController:(UIViewController *)rootViewController andTitle:(NSString *)title
{
    self = [super initWithRootViewController:rootViewController];
    if (self) {
        // Custom initialization
        [self configureUI];
        _titleLabel.text = title;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
}

#pragma mark - Public Methods
- (void)setTitleLabelText:(NSString *)title
{
    self.titleLabel.text = title;
}

- (void)showUserAddressBarWithAddress:(NSString *)address
{
    //animate in if not showing
	if (!self.dropdownIsVisible) {
        self.dropdownIsVisible = !self.dropdownIsVisible;
        
        //show the refresh button too
        [self shouldShowRefreshButton:YES];
        
		//create the user's current address label dropdown view
		self.dropdown = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
		self.dropdown.autoresizingMask = UIViewAutoresizingFlexibleWidth;
		self.dropdown.backgroundColor = [kLtGreen colorWithAlphaComponent:0.97];//97% alpha for poor man's translucency

		//add the labels to the view
		UILabel *appearToBeLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, self.view.frame.size.width, 20)];
		appearToBeLabel.textColor = [UIColor whiteColor];
		appearToBeLabel.backgroundColor = [UIColor clearColor];
		appearToBeLabel.font = [UIFont fontWithName:kHelveticaMedium size:12.0f];
		[appearToBeLabel setTextAlignment:NSTextAlignmentCenter];
		[appearToBeLabel setContentMode:UIViewContentModeCenter];
		appearToBeLabel.text = @"You appear to be near:";

		self.addressLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 20, self.view.frame.size.width, 20)];
		self.addressLabel.textColor = [UIColor whiteColor];
		self.addressLabel.backgroundColor = [UIColor clearColor];
		self.addressLabel.font = [UIFont fontWithName:kHelveticaLight size:12.0f];
		[self.addressLabel setTextAlignment:NSTextAlignmentCenter];
		[self.addressLabel setContentMode:UIViewContentModeCenter];
		//update the address
		self.addressLabel.text = address;

		[self.dropdown addSubview:appearToBeLabel];
		[self.dropdown addSubview:self.addressLabel];

		[self.navigationBar insertSubview:self.dropdown atIndex:0];
        
		CGRect frame = self.dropdown.frame;
		frame.origin.y = 0.;
		self.dropdown.hidden = NO;
		self.dropdown.frame = frame;

		[UIView animateWithDuration : 0.25 animations : ^{
		    CGRect frame = self.dropdown.frame;
		    frame.origin.y = self.navigationBar.frame.size.height;
		    self.dropdown.frame = frame;
		} completion : ^(BOOL finished) {
		}];
	}
}

- (void)hideUserAddressBar
{
    if (self.dropdownIsVisible) {
        self.dropdownIsVisible = !self.dropdownIsVisible;
        
        //also, hide refresh button
        [self shouldShowRefreshButton:NO];
        
        CGRect frame = self.dropdown.frame;
        frame.origin.y = self.navigationBar.frame.size.height;
        self.dropdown.frame = frame;
        
        [UIView animateWithDuration:0.25 animations:^{
            CGRect frame = self.dropdown.frame;
            frame.origin.y = 0.;
            self.dropdown.frame = frame;
        } completion:^(BOOL finished) {
            self.dropdown.hidden = YES;
            [self.dropdown removeFromSuperview];
        }];
    }
}

- (void)shouldShowRefreshButton:(BOOL)show
{
    self.refreshButton.hidden = !show;
}

#pragma mark - Private Methods
- (void)configureUI
{
    [self configureNavBar];
    self.view.backgroundColor = kMedGray;
}

- (void)configureNavBar
{
    self.navigationBar.tintColor = [UIColor whiteColor];
    self.navigationBar.barTintColor = kLtGray;
    
    //add the custom title label
    self.titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, 200, self.navigationBar.frame.size.height)];
    [self.titleLabel setBackgroundColor:[UIColor clearColor]];
    [self.titleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.titleLabel setContentMode:UIViewContentModeCenter];
    [self.titleLabel setFont:[UIFont fontWithName:kHelveticaLight size:18.0f]];
    [self.titleLabel setTextColor:[UIColor whiteColor]];
    [self.titleLabel setShadowColor:[UIColor darkGrayColor]];
    [self.titleLabel setShadowOffset:CGSizeMake(0, 1)];
    
    [self.navigationBar addSubview:self.titleLabel];
    
    //add the right refresh button
    [self addRefreshBarButton];
}

- (void)addRefreshBarButton
{
    self.refreshButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.refreshButton.frame = CGRectMake(270, 0, 44, 44);
	self.refreshButton.backgroundColor = [UIColor clearColor];
    [self.refreshButton setImage:[UIImage imageNamed:@"760-refresh-3.png"] forState:UIControlStateNormal];
    self.refreshButton.hidden = YES;//hidden initially
	[self.refreshButton addTarget:self action:@selector(postRefreshNotification) forControlEvents:UIControlEventTouchUpInside];
    [self.navigationBar addSubview:self.refreshButton];
}

- (void)postRefreshNotification
{
    NSAssert(FALSE, @"Called something we shouldn't");
//    [[NSNotificationCenter defaultCenter] postNotificationName:kBarGolfRefreshButtonNotification object:nil];
}

#pragma mark - ICSDrawerControllerPresenting
- (void)drawerControllerWillOpen:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(ICSDrawerController *)drawerController
{
    self.view.userInteractionEnabled = YES;
}

#pragma mark - Open drawer button
- (void)openDrawer:(id)sender
{
    [self.drawer open];
}

@end
