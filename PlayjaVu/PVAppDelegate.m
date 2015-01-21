//
//  PVAppDelegate.m
//  PlayjaVu
//
//  Created by Kerry Knight on 1/4/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import "PVAppDelegate.h"
#import "Reachability.h"
#import "MRProgress.h"
#import "PVStatusBarNotification.h"
#import "PVLeftMenuViewController.h"
#import "SlideNavigationController.h"
#import "PVUtility.h"
#import <os/activity.h>
#import <os/trace.h>

@interface PVAppDelegate ()
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
#if !OFFLINE_MODE
    // connect Reachability; not sure I like doing this in the
    // app delegate or not...should probably move this later
    [self _monitorReachability];
#endif
    
    os_activity_initiate("Configure Parse", OS_ACTIVITY_FLAG_DEFAULT, ^{
        // set up and configure Parse
        [[PVUtility sharedUtility] configureParseWithLaunchOptions:launchOptions];
    });
    
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    self.window.backgroundColor = kDrkGray;
    
    // the left menu actually returns our configured sliding nav singleton here; weird, i know o_O
    PVLeftMenuViewController *leftMenuViewController = [[PVLeftMenuViewController alloc] init];
    self.window.rootViewController = [leftMenuViewController configuredSlideNavigationAndMenuController];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

#pragma mark - Public methods
- (BOOL)isParseReachable
{
    return self.networkStatus != NotReachable;
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


#pragma mark - Reachability
- (void)_monitorReachability
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_reachabilityChanged:) name:kReachabilityChangedNotification object:nil];
        
        self.hostReach = [Reachability reachabilityWithHostname:@"api.parse.com"];
        [self.hostReach startNotifier];
        
        self.internetReach = [Reachability reachabilityForInternetConnection];
        [self.internetReach startNotifier];
        
        self.wifiReach = [Reachability reachabilityForLocalWiFi];
        [self.wifiReach startNotifier];
    });
}

// Called by Reachability whenever status changes.
- (void)_reachabilityChanged:(NSNotification *)note
{
    Reachability *curReach = (Reachability *)[note object];
    NSParameterAssert([curReach isKindOfClass:[Reachability class]]);
    self.networkStatus = [curReach currentReachabilityStatus];

    if (![self isParseReachable]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [PVStatusBarNotification showWithStatus:NSLocalizedString(@"PlayjaVu service is disconnected.", nil) customStyleName:PVStatusBarError];
        });
    } else {
        // back online!
        dispatch_async(dispatch_get_main_queue(), ^{
           [PVStatusBarNotification dismiss];
        });
    }
}

#pragma mark - Facebook and...
// Facebook oauth callback
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication
                        withSession:[PFFacebookUtils session]];
}

#pragma mark - PVAppDelegate
// ****************************************************************************
// App switching methods to support Facebook Single Sign-On.
// ****************************************************************************
- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
    [FBAppCall handleDidBecomeActiveWithSession:[PFFacebookUtils session]];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
    [[PFFacebookUtils session] close];
}

@end
