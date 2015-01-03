//
//  PFFile+RACExtensions.h
//  Bar Golf
//
//  Created by Kerry Knight on 2/16/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//

#import <Parse/Parse.h>

@class RACSignal;

@interface PFFile (RACExtensions)


/*! File Data Operations */

/// Saves the PFFile.
///
/// @see -saveInBackgroundWithBlock:
///
/// @return A signal that completes on successful save.
- (RACSignal *)rac_save;

@end
