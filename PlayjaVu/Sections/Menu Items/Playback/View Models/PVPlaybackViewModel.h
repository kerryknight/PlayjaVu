//
//  PVPlaybackViewModel.h
//  PlayjaVu
//
//  Created by Kerry Knight on 1/7/15.
//  Copyright (c) 2015 Kerry Knight. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface PVPlaybackViewModel : NSObject

@property (strong, nonatomic) MPVolumeView *volumeView;

@property (copy, nonatomic) NSArray *mediaItems;

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

/// The Volume of the player. Valid values range from 0.0f to 1.0f
@property (nonatomic) CGFloat volume;

/// The preferred size for cover art in pixels
@property (nonatomic) CGSize preferredSizeForCoverArt;

/// yes, if data source provided cover art for current song
@property (nonatomic) BOOL customCovertArtLoaded;

/// Timespan before placeholder for albumart will be set (default is 0.5). Supports long loading times.
@property (nonatomic, assign) float placeholderImageDelay;
@property (nonatomic, strong) NSTimer *playbackTickTimer; // Ticks each seconds when playing.
@property (nonatomic) CGFloat currentTrackLength; // The Length of the currently playing track
@property (nonatomic) NSInteger numberOfTracks; // Number of tracks, <0 if unknown
@property (nonatomic) BOOL scrobbling; // Whether the player is currently scrobbling
@property (nonatomic) BOOL lastDirectionChangePositive; // Whether the last direction change was positive.

- (void)propagateMusicPlayerState;

/**
 * Returns the title of the given track and player as a NSString. You can return nil for no title.
 * @param trackNumber the track number this request is for.
 * @return A string to use as the title of the track. If you return nil, this track will have no title.
 */
- (NSString *)titleForTrack:(NSUInteger)trackNumber;

/**
 * Returns the artist for the given track.
 * @param trackNumber the track number this request is for.
 * @return A string to use as the artist name of the track. If you return nil, this track will have no artist name.
 */
- (NSString *)artistForTrack:(NSUInteger)trackNumber;

/**
 * Returns the album for the given track
 * @param trackNumber the track number this request is for.
 * @return A string to use as the album name of the track. If you return nil, this track will have no album name.
 */
- (NSString *)albumForTrack:(NSUInteger)trackNumber;

/**
 * Returns the length for the given track. Your implementation must provide a
 * value larger than 0.
 * @param trackNumber the track number this request is for.
 * @return length in seconds
 */
- (CGFloat)lengthForTrack:(NSUInteger)trackNumber;

/**
 * Returns the volume
 * @return volume A float holding the volume on a range from 0.0f to 1.0f
 */
- (CGFloat)volume;

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
 * @param trackNumber the index of the track for which the artwork is requested.
 * @param receivingBlock a block of type void(^)(MPMediaItemArtwork *mediaArt, NSError **error) that needs to be called when the image is prepared by the receiver.
 * @see [PVPlaybackViewController preferredSizeForCoverArt]
 */
- (void)artworkForTrack:(NSUInteger)trackNumber receivingBlock:(void(^)(MPMediaItemArtwork *mediaArt, NSError **error))receivingBlock;

/**
 * Called by the player after the player started playing a song.
 * @param player the PVPlaybackViewController sending the message
 */
- (void)startPlaying;

/**
 * Called after a user presses the "play"-button but before the player actually starts playing.
 * @param player the PVPlaybackViewController sending the message
 * @return  If the value returned is NO, the player won't start playing. YES, tells the player to starts. Default is YES.
 */
- (BOOL)shouldStartPlaying;

/**
 * Called after the player stopped playing. This method is called both when the current song ends
 * and if the user stops the playback.
 * @param player the PVPlaybackViewController sending the message
 */
- (void)stopPlaying;

/**
 * Called after the player stopped playing the last track.
 * @param player the PVPlaybackViewController sending the message
 */
- (void)didStopPlayingLastTrack;

/**
 * Called before the player stops playing but after the user initiated the stop action.
 * @param player the PVPlaybackViewController sending the message
 * @return By returning NO here, the delegate may prevent the player from stopping the playback. Default YES.
 */
- (BOOL)shouldStopPlaying;

/**
 * Called after the player seeked or scrubbed to a new position. This is mostly the result of a user interaction.
 * @param player the PVPlaybackViewController sending the message
 * @param position new position in seconds
 */
- (void)didSeekToPosition:(CGFloat)position;

/**
 * Called before the player actually skips to the next song, but after the user initiated that action.
 *
 * If an implementation returns NO, the track will not be changed, if it returns YES the track will be changed. If you do not implement this method, YES is assumed.
 * @param player the PVPlaybackViewController sending the message
 * @param track a NSUInteger containing the number of the new track
 * @return YES if the track can be changed, NO if not. Default YES.
 */
- (BOOL)shouldChangeTrack:(NSUInteger)track;

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
 * Called when the player's volume changed
 *
 * Note that this not actually change the volume of anything, but is rather a result of a change in the internal state of the PVPlaybackViewController. If you want to change the volume of a playback module, you can implement this method.
 * @param player The PVPlaybackViewController changing the volume
 * @param volume A float holding the volume on a range from 0.0f to 1.0f
 */
- (void)didChangeVolume:(CGFloat)volume;

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
