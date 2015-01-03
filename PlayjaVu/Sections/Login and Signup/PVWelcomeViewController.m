//
//  PVWelcomeViewController.m
//  PlayjaVu
//
//  Created by Kerry on 12/4/12.
//  Copyright (c) 2012 Kerry Knight. All rights reserved.
//

#import "PVWelcomeViewController.h"
#import "PVAppDelegate.h"
#import "PVLoginViewController.h"
#import "PVSignUpViewController.h"

@implementation PVWelcomeViewController

#pragma mark - View Life Cycle
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    /**************************************************************************************************/
    //HERE IS WHERE I COULD CHECK TO SEE IF THE USER HAS EVER OPENED THE APP AND SHOW A WALKTHROUGH
    //TUTORIAL PRIOR TO GETTING THEM TO LOG IN; I SHOULD ALLOW THEM TO SKIP IT AND GO STRAIGHT TO THE
    //LOGIN OR SIGN-UP VIEW CONTROLLER FROM THIS TOO  //TODO:
    /**************************************************************************************************/

//#warning remove this bogus logout when dev for login complete
//    [PFUser logOut];
    
    /**************************************************************************************************/
    /**************************************************************************************************/
    
    
    // If not logged in, present login view controller
    if (![PFUser currentUser]) {
        DLogOrange(@"no current user at welcome so show login view");
        [self presentLoginViewControllerAnimated:NO];
        return;
    } else {
        //post a notification that our main interface should show which our
        //menu view controller will observe and load as needed
        [[NSNotificationCenter defaultCenter] postNotificationName:kMenuShouldShowMainInterfaceNotification object:nil];
    }
    
    // Refresh current user with server side data -- checks if user is still valid and so on
    [[PFUser currentUser] fetchInBackgroundWithTarget:self selector:@selector(refreshCurrentUserCallbackWithResult:error:)];
}

#pragma mark - Private Methods

- (void)refreshCurrentUserCallbackWithResult:(PFObject *)refreshedObject error:(NSError *)error
{
    // A kPFErrorObjectNotFound error on currentUser refresh signals a deleted user
    if (error && error.code == kPFErrorObjectNotFound) {
        DLog(@"User does not exist.");
        [PVAD logOut];
        return;
    }
    
    //check what type of login we have
    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        //we're logged in with Facebook
        // Check if user is missing a Facebook ID
        if ([PVUtility userHasValidFacebookData:[PFUser currentUser]]) {
            // User has Facebook ID.
            
            DLogGreen(@"user has facebook id so request friend list");
//            // refresh Facebook friends on each launch
//            PF_FBRequest *request = [PF_FBRequest requestForMyFriends];
//            [request setDelegate:(PVAppDelegate*)[[UIApplication sharedApplication] delegate]];
//            [request startWithCompletionHandler:nil];
        } else {
            DLogGreen(@"User missing Facebook ID; Should check to see if they connected via Facebook first before querying again.");
//            PF_FBRequest *request = [PF_FBRequest requestForGraphPath:@"me/?fields=name,picture,email"];
//            [request setDelegate:(PVAppDelegate*)[[UIApplication sharedApplication] delegate]];
//            [request startWithCompletionHandler:nil];
        }
        /*else if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]] ) {
         //we're logged in with Twitter //TODO:
         } */
    } else {
        DLogSuccess(@"LOGGED IN WITH PARSE");
        //we're logged with via a Parse account
    }
}

- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
    DLogGreen(@"");
    
    if ([PVUtility userHasValidFacebookData:[PFUser currentUser]]) {
        DLogGreen(@"User has valid Facebook data, granting permission to use app.");
        //        [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
        //        [self presentTabBarController];
        
        [self.navigationController dismissViewControllerAnimated:YES completion:^{
            //
        }];
        
        return YES;
    }
    
    return NO;
}

- (void)presentLoginViewControllerAnimated:(BOOL)animated
{
    PVLoginViewController *loginViewController = [[PVLoginViewController alloc] init];
    
    //main queue
    dispatch_async(dispatch_get_main_queue(), ^{
        // Present the log in view controller
        [self showViewController:loginViewController sender:self];
//        [self.navigationController pushViewController:loginViewController animated:NO];
    });
}

@end
