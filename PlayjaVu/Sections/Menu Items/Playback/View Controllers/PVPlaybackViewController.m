//
//  PVPlaybackViewController.m
//  PlayjaVu
//
//  Created by Kerry Knight on 3/7/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVPlaybackViewController.h"
#import "PVNavigationController.h"

@interface PVPlaybackViewController ()

@end

@implementation PVPlaybackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    [self configureUI];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    //have to set our custom nav controller's title by hand each time by
    //casting to it for forward and backward navigation compatibility
    PVNavigationController *navController = (PVNavigationController *)self.navigationController;
    navController.titleLabel.text = NSLocalizedString(@"PlayjaVu", nil);
}

#pragma mark - Public Methods

#pragma mark - Private Methods
- (void)configureUI
{
    self.view.backgroundColor = kMedGray;
}

@end
