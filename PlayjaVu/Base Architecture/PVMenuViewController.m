// PVMenuViewController.m
//  PlayjaVu
//
//  Created by Kerry Knight on 1/4/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVMenuViewController.h"
#import "PVAllSTPTransitions.h"
#import "PVWelcomeViewController.h"
#import "PVPlaybackViewController.h"
#import "PVMyProfileViewController.h"

static NSString * const kMenuViewControllerCellReuseId = @"PVMenuCell";

@interface PVMenuViewController ()
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSArray *menuItems;
@property (assign, nonatomic) NSInteger previousRow;
@property (strong, nonatomic) PVNavigationController *navController;
@property (strong, nonatomic) PVWelcomeViewController *welcomeViewController;
@property (strong, nonatomic) ICSDrawerController *drawerController;
@end

@implementation PVMenuViewController

#pragma mark - Life Cycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization this is the only observer need to have
        //immediately at instantiation; the others can and should wait to be
        //added in the -addNotificationObservers method
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showMainInterface) name:kMenuShouldShowMainInterfaceNotification object:nil];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (NSArray *)menuItems
{
	if (!_menuItems) {
		_menuItems = @[@"Now Playing", @"My Profile", @"Log Out"];
	}
	return _menuItems;
}

#pragma mark - Public Methods
- (void)showWelcomeView
{
    // Create the navigation controller with our welcome vc
    self.welcomeViewController = [[PVWelcomeViewController alloc] init];
    UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:self.welcomeViewController];
    // This is the tits. Don't forget to do this! for STPTransitions
    navController.delegate = STPTransitionCenter.sharedInstance;
    navController.navigationBarHidden = YES;
    navController.toolbarHidden = YES;
    
    PVAD.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    PVAD.window.backgroundColor = kDrkGray;
    PVAD.window.rootViewController = navController;
    [PVAD.window makeKeyAndVisible];
}

#pragma mark - Private Methods that Create and/or Push New View Controllers
- (void)showMainInterface
{
    //the scorecard view will be the first view shown by default
    PVPlaybackViewController *playbackVC = [[PVPlaybackViewController alloc] init];
    self.navController = [[PVNavigationController alloc] initWithRootViewController:playbackVC andTitle:@"Now Playing"];
    self.drawerController = [[ICSDrawerController alloc] initWithLeftViewController:self
                                                                     centerViewController:self.navController];
    
    //drawer needs to be the main interface view so it's top view can hold any
    //navigation controllers while the menu view controller is not part of a
    //nav controller; hence, we set the drawer to window's root
    PVAD.window.rootViewController = self.drawerController;
}

- (void)pushInNewViewController:(UIViewController *)vc withTitle:(NSString *)title
{
//    self.toolbarPullDownController.frontController = vc;
//    [self.navController setViewControllers:@[self.toolbarPullDownController]];
//    [self.drawer replaceCenterViewControllerWithViewController:self.navController];
}

#pragma mark - Configuring the view’s layout behavior
- (UIStatusBarStyle)preferredStatusBarStyle
{
	// Even if this view controller hides the status bar, implementing this method is still needed to match the center view controller's
	// status bar style to avoid a flicker when the drawer is dragged and then left to open.
	return UIStatusBarStyleLightContent;
}

- (BOOL)prefersStatusBarHidden
{
	return YES;
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
	return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return self.menuItems.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:kMenuViewControllerCellReuseId];
    
	if (cell == nil) {
		cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kMenuViewControllerCellReuseId];
	}
    
	cell.textLabel.text = self.menuItems[indexPath.row];
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
    
	if (indexPath.row == self.previousRow) {
		// Close the drawer without no further actions on the center view controller
		[self.drawer close];
	}
	else {
		NSString *menuItem = self.menuItems[indexPath.row];
		UIViewController *newVC;

		if ([menuItem isEqualToString:@"Now Playing"]) {
            DLogOrange(@"LOAD NOW PLAYING VIEW");
			newVC = [[PVPlaybackViewController alloc] init];
		}
		else if ([menuItem isEqualToString:@"My Profile"]) {
			newVC = [[PVMyProfileViewController alloc] init];
		}
		else if ([menuItem isEqualToString:@"Log Out"]) {
			[self.drawer close];
			[PVAD logOut];
            
            //show the welcome view
            [self showWelcomeView];
			return;
		}
        
        //pass our vc and it's title off to our helper method which will
        //create a new pulldown view controller to put them into
        [self pushInNewViewController:newVC withTitle:menuItem];
	}

	self.previousRow = indexPath.row;
}

#pragma mark - ICSDrawerControllerPresenting Methods
- (void)drawerControllerWillOpen:(ICSDrawerController *)drawerController
{
	self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidOpen:(ICSDrawerController *)drawerController
{
	self.view.userInteractionEnabled = YES;
}

- (void)drawerControllerWillClose:(ICSDrawerController *)drawerController
{
	self.view.userInteractionEnabled = NO;
}

- (void)drawerControllerDidClose:(ICSDrawerController *)drawerController
{
	self.view.userInteractionEnabled = YES;
}

@end
