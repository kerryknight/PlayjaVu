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

/// The index of the currently set track
@property (nonatomic) NSInteger currentTrack;

/// YES, if the player is in play-state
@property (nonatomic) BOOL playing;

/// The Current Playback position in seconds
@property (nonatomic) CGFloat currentPlaybackPosition;

/// The current repeat mode of the player.
@property (nonatomic) MPMusicRepeatMode repeatMode;

/// YES, if the player is shuffling
@property (nonatomic) BOOL shuffling;

@property (strong, nonatomic) MPVolumeView *volumeView;
/// The Volume of the player. Valid values range from 0.0f to 1.0f
@property (nonatomic) CGFloat volume;

/// The preferred size for cover art in pixels
@property (nonatomic) CGSize preferredSizeForCoverArt;

/// yes, if data source provided cover art for current song
@property (nonatomic) BOOL customCovertArtLoaded;

/// Timespan before placeholder for albumart will be set (default is 0.5). Supports long loading times.
@property (nonatomic, assign) float placeholderImageDelay;
@property (nonatomic, strong) NSTimer *playbackTickTimer; // Ticks each seconds when playing.
@property (nonatomic) NSInteger numberOfTracks; // Number of tracks, <0 if unknown
@property (nonatomic) BOOL scrobbling; // Whether the player is currently scrobbling
@property (strong, nonatomic, readonly) RACSignal *updatePlaybackUISignal;
@property (strong, nonatomic, readonly) RACSignal *playSignal;

/**
 * Returns the title of the given track and player as a NSString. You can return nil for no title.
 * @return A string to use as the title of the track. If you return nil, this track will have no title.
 */
- (NSString *)trackTitle;

/**
 * Returns the artist for the given track.
 * @return A string to use as the artist name of the track. If you return nil, this track will have no artist name.
 */
- (NSString *)trackArtist;

/**
 * Returns the album for the given track
 * @return A string to use as the album name of the track. If you return nil, this track will have no album name.
 */
- (NSString *)trackAlbum;

/**
 * Returns the length for the given track. Your implementation must provide a
 * value larger than 0.
 * @return length in seconds
 */
- (CGFloat)trackLength;

/**
 * Returns the number of tracks for the given player. If you do not implement this method
 * or return anything smaller than 2, one track is assumed and the skip-buttons are disabled.
 * @return number of available tracks, -1 if unknown
 */
- (NSInteger)numberOfTracks;

- (BOOL)tracksAreAvailable;

/**
 * Returns the artwork for a given track.
 *
 * The artwork is returned using a receiving block void(^)(MPMediaItemArtwork *mediaArt, NSError **error) that takes an MPMediaItemArtwork and an optional error. If you supply nil as an image, a placeholder will be shown.
 * @param completion a block of type void(^)(MPMediaItemArtwork *mediaArt, NSError **error) that needs to be called when the image is prepared by the receiver.
 * @see [PVPlaybackViewController preferredSizeForCoverArt]
 */
- (void)artworkForCurrentTrackWithCompletion:(void (^)(MPMediaItemArtwork *mediaArt, NSError **error))completion;

/**
 * Called by the player after the player started playing a song.
 * @param player the PVPlaybackViewController sending the message
 */
- (void)startPlaying;

/**
 * Called after the player stopped playing. This method is called both when the current song ends
 * and if the user stops the playback.
 * @param player the PVPlaybackViewController sending the message
 */
- (void)stopPlaying;

/**
 * Called after the player seeked or scrubbed to a new position. This is mostly the result of a user interaction.
 * @param player the PVPlaybackViewController sending the message
 * @param position new position in seconds
 */
- (void)didSeekToPosition:(CGFloat)position;

/**
 * Called after the music player changed to a new track
 *
 * You can implement this method if you need to react to the player changing tracks.
 * @param player the PVPlaybackViewController changing the track
 * @param track a NSUInteger containing the number of the new track
 * @return the actual track the delegate has changed to
 */
- (NSInteger)didChangeTrack:(NSUInteger)track;

/**
 * Called when the player changes it's shuffle state.
 *
 * YES indicates the player is shuffling now, i.e. randomly selecting a next track from the valid range of tracks, NO
 * means there is no shuffling.
 * @param player The PVPlaybackViewController that changes the shuffle state
 * @param shuffling YES if shuffling, NO if not
 */
- (void)didChangeShuffleState:(BOOL)shuffling;

/**
 * Called when the player changes it's repeat mode.
 *
 * The repeat modes are taken from MediaPlayer framework and indicate whether the player is in No Repeat, Repeat Once or Repeat All mode.
 * @param player The PVPlaybackViewController that changes the repeat mode.
 * @param repeatMode a MPMusicRepeatMode indicating the currently active mode.
 */
- (void)didChangeRepeatMode:(MPMusicRepeatMode)repeatMode;

@end
