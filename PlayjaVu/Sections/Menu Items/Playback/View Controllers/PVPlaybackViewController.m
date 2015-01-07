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
    DLogYellow(@"");
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    // set up view model
    self.viewModel = [[PVPlaybackViewModel alloc] init];
    
    // ensure our bg is colored
    self.view.backgroundColor = kMedGray;
    
    // Fetches the config at most once every 12 hours per app runtime
    const NSTimeInterval configRefreshInterval = 12.0 * 60.0 * 60.0;
    static NSDate *lastFetchedDate;
    if (lastFetchedDate == nil ||
        [lastFetchedDate timeIntervalSinceNow] * -1.0 > configRefreshInterval) {
        [PFConfig getConfigInBackgroundWithBlock:^(PFConfig *config, NSError *error) {
            // no op
//            DLogGreen(@"PFConfig: %@", [PFConfig currentConfig]);
        }];
        lastFetchedDate = [NSDate date];
    }
}

#pragma mark - Public Methods

#pragma mark - Private Methods

@end
