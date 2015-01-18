//
//  PVPlaybackViewController.m
//  PlayjaVu
//
//  Created by Kerry Knight on 3/7/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVPlaybackViewController.h"
#import "PVPlaybackViewModel.h"
#import "SlideNavigationController.h"

@interface PVPlaybackViewController ()<SlideNavigationControllerDelegate>
@property (strong, nonatomic) PVPlaybackViewModel *viewModel;
@property (nonatomic, strong) UITapGestureRecognizer *coverArtGestureRecognizer; // Tap Recognizer used to dim in / out the scrobble overlay.
@end

@implementation PVPlaybackViewController

#pragma mark - Life Cycle
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
    
    // set up view model
    self.viewModel = [[PVPlaybackViewModel alloc] init];
    
    // ensure our bg is colored
    self.view.backgroundColor = kMedGray;
}

#pragma mark - Public Methods

#pragma mark - Private Methods

@end
