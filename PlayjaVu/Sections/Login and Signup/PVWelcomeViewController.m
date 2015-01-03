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

@interface PVWelcomeViewController ()
- (void)setDisplayNameEqualToAdditionalField;
@end

@implementation PVWelcomeViewController

#pragma mark - View Life Cycle
- (void)viewDidLoad
{
    DLogOrange(@"");
    [super viewDidLoad];
}

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
    DLogRed(@"");
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
        //we're logged with via a Parse account so set the displayName
        [self setDisplayNameEqualToAdditionalField];
    }
}

- (void)setDisplayNameEqualToAdditionalField
{
    DLogRed(@"");
    //check if it's a parse signee; if so, set their displayName field to the additional field from signup
    //check what type of login we have
    if (![PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
        //the user signed up via Parse so set their displayName field which we don't set otherwise
        PFUser *user = [PFUser currentUser];
        PFQuery *query = [PFQuery queryWithClassName:@"_User"];//use the _User table name in Parse
        [query whereKey:@"objectId" equalTo:user.objectId];
        query.limit = 1;
        
        [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                if (objects.count > 0) {
                    DLog(@"Here in PlayjaVu is where we were setting the Additional field for the user");
//                    PFObject *_user = [objects objectAtIndex:0];
//                    
//                    //check if display name is equal to the additional field; if not, save it that way
//                    if ([[_user objectForKey:kUserAdditionalKey] isEqualToString:[_user objectForKey:kUserDisplayNameKey]]) {
//                        //names are equal
////                        DLog(@"display names are equal");
//                    } else {
//                        //names not equal
////                        DLog(@"display names are not equal, so attempt to save");
//                        [_user setObject:[_user objectForKey:kUserAdditionalKey] forKey:kUserDisplayNameKey];
//                        [_user saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                            if (!error) {
//                                //success so can update UI appropriately now
////                                DLog(@"saved displayName successfully");
//                                //in lieu of making an ADDITIONAL query to Parse for what we just set, go ahead and set it locally to display name
//                                [[PFUser currentUser] setObject:[_user objectForKey:kUserAdditionalKey] forKey:kUserDisplayNameKey];
//                            } else {
//                                //error saving displayName back to Parse
//                            }
//                        }];
//                    }
                }
            }
        }];
    }
}

//- (BOOL)shouldProceedToMainInterface:(PFUser *)user {
//    DLogGreen(@"");
//    
//    if ([PVUtility userHasValidFacebookData:[PFUser currentUser]]) {
//        DLogGreen(@"User has valid Facebook data, granting permission to use app.");
//        //        [MBProgressHUD hideHUDForView:self.navController.presentedViewController.view animated:YES];
//        //        [self presentTabBarController];
//        
//        [self.navigationController dismissViewControllerAnimated:YES completion:^{
//            //
//        }];
//        
//        return YES;
//    }
//    
//    return NO;
//    
//}

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

//#pragma mark - PFLogInViewControllerDelegate
//- (BOOL)logInViewController:(PFLogInViewController *)logInController shouldBeginLogInWithUsername:(NSString *)username password:(NSString *)password {
//    DLogGreen(@"email: %@ and password: %@", username, password);
//    return YES;
//}
//
//// Called on successful login. This is likely to be the place where we register
//// the user to the "user_xxxxxxxx" channel
//- (void)logInViewController:(PFLogInViewController *)logInController didLogInUser:(PFUser *)user {
//    DLogGreen(@"");
//    
//    //check what type of login we have
//    if ([PFFacebookUtils isLinkedWithUser:[PFUser currentUser]]) {
//        // user has logged in - we need to fetch all of their Facebook data before we let them in if they logged in with FB
//        if (![self shouldProceedToMainInterface:user]) {
//            //            self.hud = [MBProgressHUD showHUDAddedTo:self.navController.presentedViewController.view  animated:YES];
//            //            self.hud.color = kMint4;
//            //            [self.hud setDimBackground:YES];
//            //            [self.hud setLabelText:@"Loading"];
//        }
//        //        //we're logged in with Facebook so request the user's name and pic data
//        //        PF_FBRequest *request = [PF_FBRequest requestForGraphPath:@"me/?fields=name,picture"];
//        //        [request setDelegate:self];
//        //        [request startWithCompletionHandler:NULL];
//        
//        
//        // Create request for user's Facebook data
//        FBRequest *request = [FBRequest requestForMe];
//        
//        // Send request to Facebook
//        [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
//            // handle response
//            DLog(@"FB request completion: %@", result);
//        }];
//        
//        
//        
//        
//    } /*else if ([PFTwitterUtils isLinkedWithUser:[PFUser currentUser]] ) {
//       //we're logged in with Twitter //TODO:
//       DLog(@"logged into twitter, now retrieve twitter name and picture");
//       } */else {
//           //we're logged with via a Parse account so dismiss the overlay
//           //           [self presentTabBarController];
//           [self.navigationController dismissViewControllerAnimated:YES completion:^{
//               //
//           }];
//       }
//    
//    // Subscribe to private push channel
//    if (user) {
//        DLog(@"subscribe to private push channel");
//        NSString *privateChannelName = [NSString stringWithFormat:@"user_%@", [user objectId]];
//        // Add the user to the installation so we can track the owner of the device
//        [[PFInstallation currentInstallation] setObject:user forKey:kInstallationUserKey];
//        //        [[PFInstallation currentInstallation] setObject:[PFUser currentUser] forKey:kInstallationUserKey];
//        // Subscribe user to private channel
//        [[PFInstallation currentInstallation] addUniqueObject:privateChannelName forKey:kInstallationChannelsKey];
//        // Save installation object
//        [[PFInstallation currentInstallation] saveEventually];
//        [user setObject:privateChannelName forKey:kUserPrivateChannelKey];
//    }
//}

//// Sent to the delegate when the log in attempt fails.
//- (void)logInViewController:(PFLogInViewController *)logInController didFailToLogInWithError:(NSError *)error {
//    
//    DLogRed(@"Failed to log in with error: %@", error);
//    alertMessage(@"Uh oh. Something happened and logging in failed with error: %@. Please try again.", [error localizedDescription]);
//}
//
//#pragma mark - PFSignUpViewControllerDelegate
//
//// Sent to the delegate to determine whether the sign up request should be submitted to the server.
//- (BOOL)signUpViewController:(PFSignUpViewController *)signUpController shouldBeginSignUp:(NSDictionary *)info {
//    DLogGreen(@"");
//    BOOL informationComplete = YES;
//    
//    for (id key in info) {
//        NSString *field = [info objectForKey:key];
//        //make sure all fields are filled in
//        if (!field || field.length == 0) {
//            informationComplete = NO;
//            break;
//        }
//        //ensure password is long enough
//        if ([key isEqualToString:@"password"] && field.length < kMinimumPasswordLength) {
//            alertMessage(@"Password must be at least %i characters.", kMinimumPasswordLength);
//            informationComplete = NO;
//            return informationComplete;
//        }
//        
//        //check the characters used in the password field; new passwords must contain at least 1 digit
//        NSCharacterSet *set = [NSCharacterSet characterSetWithCharactersInString:@"0123456789"];
//        
//        if ([key isEqualToString:@"password"] && [field rangeOfCharacterFromSet:set].location == NSNotFound) {
//            //no numbers found
//            alertMessage(@"Password must contain at least one number");
//            informationComplete = NO;
//            return informationComplete;
//        }
//        
//        //ensure our display name doesn't include any special characters so we don't get lots of dicks and stuff for names 8======D
//        set = [[NSCharacterSet characterSetWithCharactersInString:@"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLKMNOPQRSTUVWXYZ0123456789"] invertedSet];
//        
//        if ([key isEqualToString:@"password"] && [field rangeOfCharacterFromSet:set].location != NSNotFound) {
//            //special characters found
//            alertMessage(@"Display names can only contain letters and numbers.");
//            informationComplete = NO;
//            return informationComplete;
//        }
//    }
//    
//    if (!informationComplete) {
//        
//        //knightka replaced a regular alert view with our custom subclass
//        SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Missing Information", nil) andMessage:NSLocalizedString(@"Make sure you fill out all of the information!", nil)];
//        [alertView addButtonWithTitle:@"OK"
//                                 type:SIAlertViewButtonTypeCancel
//                              handler:^(SIAlertView *alert) {
//                                  NSLog(@"OK Clicked");
//                              }];
//        
//        alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
//        [alertView show];
//    }
//    
//    return informationComplete;
//}
//
//// Sent to the delegate when a PFUser is signed up.
//- (void)signUpViewController:(PFSignUpViewController *)signUpController didSignUpUser:(PFUser *)user {
//    DLogRed(@"");
//    [self.navigationController dismissViewControllerAnimated:YES completion:NULL];
//    
//    //knightka replaced a regular alert view with our custom subclass
//    SIAlertView *alertView = [[SIAlertView alloc] initWithTitle:NSLocalizedString(@"Success!", nil) andMessage:NSLocalizedString(@"Please look for an email asking you to verify your email address to get the most from PlayjaVu.", nil)];
//    [alertView addButtonWithTitle:@"OK"
//                             type:SIAlertViewButtonTypeCancel
//                          handler:^(SIAlertView *alert) {
//                              NSLog(@"OK Clicked");
//                          }];
//    
//    alertView.transitionStyle = SIAlertViewTransitionStyleBounce;
//    [alertView show];
//    
//}
//
//// Sent to the delegate when the sign up attempt fails.
//- (void)signUpViewController:(PFSignUpViewController *)signUpController didFailToSignUpWithError:(NSError *)error {
//    DLog(@"Failed to sign up...");
//}
//
//// Sent to the delegate when the sign up screen is dismissed.
//- (void)signUpViewControllerDidCancelSignUp:(PFSignUpViewController *)signUpController {
//    DLog(@"User dismissed the signUpViewController");
//}

@end
