// PVLeftMenuViewController.m
//  PlayjaVu
//
//  Created by Kerry Knight on 1/4/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVLeftMenuViewController.h"
#import "PVAllSTPTransitions.h"
#import "PVLoginViewController.h"
#import "PVPlaybackViewController.h"
#import "PVMyProfileViewController.h"
#import "PVLeftMenuViewModel.h"
#import "SlideNavigationController.h"

static NSString * const kMenuViewControllerCellReuseId = @"PVMenuCell";

@interface PVLeftMenuViewController () <UITableViewDelegate, UITableViewDataSource>
@property (strong, nonatomic) PVLeftMenuViewModel *viewModel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (assign, nonatomic) BOOL slideOutAnimationEnabled;
@property (strong, nonatomic) UILabel *navBarTitleLabel;
@end

@implementation PVLeftMenuViewController

#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
        _slideOutAnimationEnabled = YES;
        self.view.backgroundColor = kDrkGray;
        // by default, hide pertinent items from view during transitions
        [self _shouldHideVisibleContent:YES];
        
        // view model set up
        _viewModel = [[PVLeftMenuViewModel alloc] init];
        
        // configure our sliding navigation controller; this
        // automatically sets our login view as our root view
        [self _configureSlideNavigationController];
        [self _configureNavBar];

#if DEVELOPER_BYPASS_LOGIN_MODE
        [self _showMainInterface];
#else
        // If logged in, present login view controller
        if ([PFUser currentUser]) {
            // logged in already
            [self _showMainInterface];
            
            // update our user info in the background
            [PVUtility updateCurrentParseUser];
        }
#endif
        
        // Custom initialization this is the only observer need to have
        //immediately at instantiation; the others can and should wait to be
        //added in the -addNotificationObservers method
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_showMainInterface) name:kMenuShouldShowMainInterfaceNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Public Methods
- (UIViewController *)configuredSlideNavigationAndMenuController
{
    return [SlideNavigationController sharedInstance];
}

#pragma mark - Private Methods
- (void)_showLoginView
{
    // hide pertinent items from view during transitions
    [self _shouldHideVisibleContent:YES];
    
    // hide the navigation bar and set our custom
    // transitions navigation delegate
    [self _configureForMainInterface:NO];
    PVLoginViewController *loginViewController = [[PVLoginViewController alloc] init];
    [[SlideNavigationController sharedInstance] setViewControllers:@[loginViewController]];
    [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
}

- (void)_showMainInterface
{
    // make sure we display everything in this view
    [self _shouldHideVisibleContent:NO];
    
    //the scorecard view will be the first view shown by default
    PVPlaybackViewController *playbackVC = [[PVPlaybackViewController alloc] init];
    [self _configureForMainInterface:YES];
    [[SlideNavigationController sharedInstance] setViewControllers:@[playbackVC]];
    [[SlideNavigationController sharedInstance] popToRootViewControllerAnimated:YES];
    
    self.navBarTitleLabel.text = @"Now Playing";
}

// this one's called whenever we touch on a menu option
- (void)_pushInNewViewController:(UIViewController *)vc title:(NSString *)title
{
    [[SlideNavigationController sharedInstance] popToRootAndSwitchToViewController:vc
                                                             withSlideOutAnimation:self.slideOutAnimationEnabled
                                                                     andCompletion:nil];
    
    self.navBarTitleLabel.text = title;
}

- (void)_configureForMainInterface:(BOOL)isMainInterface
{
    // nav bar
    [SlideNavigationController sharedInstance].navigationBarHidden = !isMainInterface;
    [SlideNavigationController sharedInstance].enableSwipeGesture = isMainInterface;
}

- (void)_configureSlideNavigationController
{
    // this instance does nothing other than ensure we set up our slide nav
    // controller's singleton; it's essentially a bug workaround here to
    // prevent the 'unused variable' yellow flag from the compiler
    PVLoginViewController *loginViewController = [[PVLoginViewController alloc] init];
    SlideNavigationController *slideNavController = [[SlideNavigationController alloc] initWithRootViewController:loginViewController];
    slideNavController = nil;
    
    // this singleton is who does all the work
    [SlideNavigationController sharedInstance].avoidSwitchingToSameClassViewController = YES;
    [SlideNavigationController sharedInstance].leftMenu = self;
    [SlideNavigationController sharedInstance].navigationController.view.backgroundColor = kDrkGray;
    [SlideNavigationController sharedInstance].enableShadow = NO;
    
    [self _configureForMainInterface:NO];
}

- (void)_configureNavBar
{
    // nav bar
    [SlideNavigationController sharedInstance].navigationBar.tintColor = [UIColor whiteColor];
    [SlideNavigationController sharedInstance].navigationBar.barTintColor = kLtGray;
    
    //add the custom title label
    self.navBarTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(60, 0, [SlideNavigationController sharedInstance].navigationBar.frame.size.width - 120, [SlideNavigationController sharedInstance].navigationBar.frame.size.height)];
    [self.navBarTitleLabel setBackgroundColor:[UIColor clearColor]];
    [self.navBarTitleLabel setTextAlignment:NSTextAlignmentCenter];
    [self.navBarTitleLabel setContentMode:UIViewContentModeCenter];
    [self.navBarTitleLabel setFont:[UIFont fontWithName:kHelveticaLight size:18.0f]];
    [self.navBarTitleLabel setTextColor:[UIColor whiteColor]];
    [self.navBarTitleLabel setShadowColor:[UIColor darkGrayColor]];
    [self.navBarTitleLabel setShadowOffset:CGSizeMake(0, 1)];
    
    __weak typeof(self) weakSelf = self;
    [[SlideNavigationController sharedInstance].navigationBar addSubview:weakSelf.navBarTitleLabel];
    
    // Creating a custom bar hamburger button for left menu
    UIButton *button  = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 44, 34)];
    [button setImage:[UIImage imageNamed:@"hamburgerButton"] forState:UIControlStateNormal];
    [button addTarget:[SlideNavigationController sharedInstance] action:@selector(toggleLeftMenu) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    [SlideNavigationController sharedInstance].leftBarButtonItem = leftBarButtonItem;
}

- (void)_shouldHideVisibleContent:(BOOL)shouldHide
{
    // only when we've logged in successfully should we show
    // the left menu view's table view; otherwise, it'll be visible
    // during transitions in the onboarding workflow
    self.tableView.hidden = shouldHide;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return PVMenuRowCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMenuViewControllerCellReuseId];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMenuViewControllerCellReuseId];
    }
    
    cell.textLabel.text = [self.viewModel displayStringForMenuRow:indexPath.row];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    
    cell.selectedBackgroundView = [[UIView alloc] initWithFrame:cell.bounds] ;
    cell.selectedBackgroundView.backgroundColor = kMedGray;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UIViewController *newVC;
    
    switch (indexPath.row) {
        case PVMenuRowNowPlaying:
            newVC = [[PVPlaybackViewController alloc] init];
            break;
        case PVMenuRowMyProfile:
            newVC = [[PVMyProfileViewController alloc] init];
            break;
        case PVMenuRowLogOut: {
            [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
            
            // have our view model log us out and perform any cleanup
            [PVUtility logOut];
            
            //show the welcome view
            [self _showLoginView];
            return;
        }
        default:
            NSAssert(false, @"We should always have every possible row accounted for.");
    }
    
    // pass our vc and it's title off to our helper method which
    // will insert them in our nav controller and then reset our drawer
    NSString *title = [self.viewModel displayStringForMenuRow:indexPath.row];
    [self _pushInNewViewController:newVC title:title];
}

#pragma mark - Configuring the view’s layout behavior
- (UIStatusBarStyle)preferredStatusBarStyle
{
    // Even if this view controller hides the status bar, implementing this method is still needed to match the center view controller's status bar style to avoid a flicker when the drawer is dragged and then left to open.
    return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

@end
