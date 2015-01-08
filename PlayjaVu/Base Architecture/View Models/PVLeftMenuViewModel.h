//
//  PVLeftMenuViewModel.h
//  PlayjaVu
//
//  Created by Kerry Knight on 1/6/15.
//  Copyright (c) 2015 Kerry Knight. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, PVMenuRow) {
    PVMenuRowNowPlaying = 0,
    PVMenuRowMyProfile,
    PVMenuRowLogOut,
    PVMenuRowCount // this is a handy accessor for the total row count
};

@interface PVLeftMenuViewModel : NSObject

- (NSString *)displayStringForMenuRow:(PVMenuRow)row;

@end
