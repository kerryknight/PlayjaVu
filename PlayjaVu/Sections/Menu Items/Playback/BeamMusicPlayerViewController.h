//
//  BeamMusicPlayerViewController.h
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Moritz Haarmann on 30.05.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "PVBaseSlidingViewController.h"

/**
 * The Music Player component. This is a drop-in view controller and provides the UI for a music player.
 * It does not actually play music, just visualize music that is played somewhere else. The data to display
 * is provided using the datasource property, events can be intercepted using the delegate-property.
 */
@interface BeamMusicPlayerViewController : PVBaseSlidingViewController

/**
 * Reloads data from the data source and updates the player. If the player is currently playing, the playback is stopped.
 */
- (void)reloadData;

@end
