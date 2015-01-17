//
//  PFFacebookUtils+RACExtensions.h
//  PlayjaVu
//
//  Created by Kerry Knight on 2/16/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>

@class RACSignal;

@interface PFFacebookUtils (RACExtensions)

/// Makes a request to log in view Facebook with the given permissions set.
///
/// This method delegates to the Facebook SDK to authenticate
/// the user, and then automatically logs in (or creates, in the case where it is a new user)
/// a PFUser.
///
/// @see +logInWithPermissions: block:
///
/// @param permissions The permissions required for Facebook log in. This passed to the
/// authorize method on the Facebook instance.
/// @return A signal that completes on success.
+ (RACSignal *)rac_logInWithPermissions:(NSArray *)permissions;

@end
