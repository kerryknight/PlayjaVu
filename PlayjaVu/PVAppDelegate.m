//
//  PVAppDelegate.m
//  PlayjaVu
//
//  Created by Kerry Knight on 1/4/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVAppDelegate.h"
#import "PVMenuViewController.h"
#import "PVCache.h"
#import "Reachability.h"
#import "MRProgress.h"
#import "PVStatusBarNotification.h"
#import "PVNavigationController.h"
#import <ParseCrashReporting/ParseCrashReporting.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "PVLoginViewController.h"

@interface PVAppDelegate ()
@property (strong, nonatomic) PVMenuViewController *menuViewController;
@property (strong, nonatomic) Reachability *hostReach;
@property (strong, nonatomic) Reachability *internetReach;
@property (strong, nonatomic) Reachability *wifiReach;
@property (assign, nonatomic, readwrite) int networkStatus;
@property (assign, nonatomic) BOOL firstLaunch;
@property (strong, nonatomic) NSMutableData *data;;
@end

@implementation PVAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [self configure3rdParties];
    [self configureMenuController];
    
    // Use Reachability to monitor connectivity
    [self monitorReachability];
    
    return YES;
}

#pragma mark - Public methods
- (BOOL)isParseReachable
{
    return self.networkStatus != NotReachable;
}

- (void)logOut
{
    // clear cache
    [[PVCache sharedCache] clear];
    
    // clear NSUserDefaults
    [[NSUserDefaults standardUserDefaults] removeObjectForKey:kUserDefaultsCacheFacebookFriendsKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    // Unsubscribe from push notifications by clearing the channels key (leaving only broadcast enabled).
    [[PFInstallation currentInstallation] setObject:@[@""] forKey:kInstallationChannelsKey];
    [[PFInstallation currentInstallation] removeObjectForKey:kInstallationUserKey];
    [[PFInstallation currentInstallation] saveInBackground];
    
    // Log out
    [PFUser logOut];
}

- (void)showSpinnerWithMessage:(NSString *)message
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        //show the spinner
        MRProgressOverlayView *spinnerView = [MRProgressOverlayView showOverlayAddedTo:self.window title:NSLocalizedString(message, Nil) mode:MRProgressOverlayViewModeIndeterminate animated:YES];
        [spinnerView setTintColor:kLtGreen];
    });
}

- (void)hideSpinner
{
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        [MRProgressOverlayView dismissOverlayForView:self.window animated:YES];
    });
}

#pragma mark - Private Methods
- (void)configure3rdParties
{
    // START 3RD PARTY INSTANTIATIONS ********************************************************
    // Parse stuff that can be done on background queue
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Enable crash reporting on Parse
        [ParseCrashReporting enable];
        
        // enable Parse local sqlite data store
        [Parse enableLocalDatastore];
        
        // enable logging
        [Parse setLogLevel:PFLogLevelDebug];
        
        // initialize everything
        [Parse setApplicationId:kParseApplicationID clientKey:kParseApplicationClientKey];
        [PFFacebookUtils initializeFacebook];
        
        //Configure Parse setup
        PFACL *defaultACL = [PFACL ACL];
        // If you would like all objects to be private by default, remove this line.
        [defaultACL setPublicReadAccess:YES];
        [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    });
    
    // END 3RD PARTY
    // INSTANTIATIONS **********************************************************
}

- (void)configureMenuController
{
    // the menuViewController will control all view loading for the app
    // delegate and even sets the window's root view controller on app load;
    // eventhough the menu view controller won't have actual menu items for some
    // of the views we're having it load, it will make it easier to user it
    // essentially as a GCD for loading view controllers regardless
    self.menuViewController = [[PVMenuViewController alloc] init];
    [self.menuViewController showWelcomeView];
}

#pragma mark - Reachability
- (void)monitorReachability
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        self.hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];
        [self.hostReach startNotifier];
        
        self.internetReach = [Reachability reachabilityForInternetConnection];
        [self.internetReach startNotifier];
        
        self.wifiReach = [Reachability reachabilityForLocalWiFi];
        [self.wifiReach startNotifier];
    });
}

// Called by Reachability whenever status changes.
- (void)reachabilityChanged:(NSNotification *)note
{
    Reachability *curReach = (Reachability *)[note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    self.networkStatus = [curReach currentReachabilityStatus];

    if (![self isParseReachable]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [PVStatusBarNotification showWithStatus:NSLocalizedString(@"PlayjaVu service is disconnected.", nil) customStyleName:PVStatusBarError];
        });
    } else {
        DLogBlue(@"PLAYJAVU BACK ONLINE!!!!");
        dispatch_async(dispatch_get_main_queue(), ^{
           [PVStatusBarNotification dismiss];
        });
    }
    
}

#pragma mark - Facebook and...
// Facebook oauth callback
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    DLogBlue(@"sourceapplication: %@", sourceApplication);
    
    if ([sourceApplication isEqualToString:@"Facebook"]) {
        return [FBAppCall handleOpenURL:url sourceApplication:sourceApplication withSession:[PFFacebookUtils session]];
    }
    
    return YES;
}

#pragma mark - PVAppDelegate
// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
- (void)applicationDidBecomeActive:(UIApplication *)application {
//    /*
//     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
//     */
//    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
//    /*
//     Called when the application is about to terminate.
//     Save data if appropriate.
//     See also applicationDidEnterBackground:.
//     */
//    [[PFFacebookUtils session] close];
}

@end
