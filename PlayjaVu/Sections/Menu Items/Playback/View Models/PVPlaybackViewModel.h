//
//  PVPlaybackViewModel.h
//  PlayjaVu
//
//  Created by Kerry Knight on 1/7/15.
//  Copyright (c) 2015 Kerry Knight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>
#import "RVMViewModel.h"

@interface PVPlaybackViewModel : RVMViewModel

/// The unique id of the currently set track
@property (copy, nonatomic, readonly) NSString *currentTrackId;

/// YES, if the player is in play-state
@property (nonatomic) BOOL playing;

/// The Current Playback position in seconds
@property (nonatomic) CGFloat currentPlaybackPosition;

@property (strong, nonatomic) MPVolumeView *volumeView;
/// The Volume of the player. Valid values range from 0.0f to 1.0f
@property (nonatomic) CGFloat volume;

@property (assign, nonatomic) CGSize albumArtSize;
@property (strong, nonatomic, readonly) UIImage *albumArt;
@property (assign, nonatomic) BOOL scrobbling; // Whether the player is currently scrobbling
@property (copy, nonatomic, readonly) NSString *trackTitle;
@property (copy, nonatomic, readonly) NSString *trackAlbumAndArtist;
@property (assign, nonatomic, readonly) CGFloat trackLength;
@property (strong, nonatomic, readonly) RACSignal *nextButtonEnabledSignal;
@property (strong, nonatomic, readonly) RACSignal *previousButtonEnabledSignal;
@property (strong, nonatomic, readonly) dispatch_queue_t userInteractiveQueue;
@property (strong, nonatomic, readonly) dispatch_queue_t userInitiatedQueue;
@property (strong, nonatomic, readonly) dispatch_queue_t utilityQueue;
@property (strong, nonatomic, readonly) dispatch_queue_t backgroundQueue;

/**
 * Called after the player seeked or scrubbed to a new position. This is mostly the result of a user interaction.
 * @param position new position in seconds
 */
- (void)didSeekToPosition:(CGFloat)position;

- (void)shouldPlayOrPauseTrack;

- (void)goToNextTrack;

- (void)goToPreviousTrack;

@end
