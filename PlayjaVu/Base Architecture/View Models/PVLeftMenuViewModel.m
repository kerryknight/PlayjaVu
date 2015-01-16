//
//  PVLeftMenuViewModel.m
//  PlayjaVu
//
//  Created by Kerry Knight on 1/6/15.
//  Copyright (c) 2015 Kerry Knight. All rights reserved.
//

#import "PVLeftMenuViewModel.h"

@interface PVLeftMenuViewModel ()
@property (strong, nonatomic, readwrite) NSArray *menuItems;
@end

@implementation PVLeftMenuViewModel

#pragma mark - Public Methods
- (NSString *)displayStringForMenuRow:(PVMenuRow)row
{
    switch (row) {
        case PVMenuRowNowPlaying:
            return NSLocalizedString(@"Now Playing", @"Now Playing");
        case PVMenuRowMyProfile:
            return NSLocalizedString(@"My Profile", @"My Profile");
        case PVMenuRowLogOut:
            return NSLocalizedString(@"Log Out", @"Log Out");
        default:
            NSAssert(FALSE, @"We should always have as many row name strings as rows.");
            return nil;
    }
}

#pragma mark = Private Methods


@end
