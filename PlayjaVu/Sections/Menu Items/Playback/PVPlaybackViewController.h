//
//  PVPlaybackViewController.h
//  PlayjaVu
//
//  Created by Kerry Knight on 3/7/14.
//  Copyright (c) 2014 Kerry Knight. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "PVBaseSlidingViewController.h"

@interface PVPlaybackViewController : PVBaseSlidingViewController

/**
 * Reloads data from the data source and updates the player. If the player is currently playing, the playback is stopped.
 */
- (void)reloadData;

@end
