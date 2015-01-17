//
//  BeamMusicPlayerViewController.m
//  Part of BeamMusicPlayerViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Moritz Haarmann on 30.05.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//

#import "BeamMusicPlayerViewController.h"
#import "BeamMPMusicPlayerProvider.h"
#import "NSDateFormatter+Duration.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AutoScrollLabel.h"
#import <QuartzCore/QuartzCore.h>

@interface BeamMusicPlayerViewController()
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider; // Volume Slider
@property (weak, nonatomic) IBOutlet UISlider *progressSlider; // Progress Slider buried in the Progress View
@property (weak, nonatomic) IBOutlet AutoScrollLabel *trackTitleLabel; // The Title Label
@property (weak, nonatomic) IBOutlet AutoScrollLabel *albumTitleLabel; // Album Label
@property (weak, nonatomic) IBOutlet AutoScrollLabel *artistNameLabel; // Artist Name Label
@property (weak, nonatomic) IBOutlet UIToolbar *controlsToolbar; // Encapsulates the Play, Forward, Rewind buttons
@property (retain, nonatomic) IBOutlet UIBarButtonItem *actionButton; // retain, since controller keeps a reference while it might be detached from view hierarchy
@property (retain, nonatomic) IBOutlet UIBarButtonItem *backButton; // retain, since controller keeps a reference while it might be detached from view hierarchy
@property (weak, nonatomic) IBOutlet UIBarButtonItem *rewindButton; // Previous Track
@property (weak, nonatomic) IBOutlet UIBarButtonItem *fastForwardButton; // Next Track
@property (weak, nonatomic) IBOutlet UIBarButtonItem *playButton; // Play
@property (weak, nonatomic) IBOutlet UIButton *rewindButtonIPad; // Previous Track
@property (weak, nonatomic) IBOutlet UIButton *fastForwardButtonIPad; // Next Track
@property (weak, nonatomic) IBOutlet UIButton *playButtonIPad; // Play
@property (weak, nonatomic) IBOutlet UIImageView *albumArtImageView; // Album Art Image View
@property (weak, nonatomic) IBOutlet UIView *scrobbleOverlay; // Overlay that serves as a container for all components visible only in scrobble-mode
@property (weak, nonatomic) IBOutlet UILabel *timeElapsedLabel; // Elapsed Time Label
@property (weak, nonatomic) IBOutlet UILabel *timeRemainingLabel; // Remaining Time Label
@property (weak, nonatomic) IBOutlet UIButton *shuffleButton; // Shuffle Button
@property (weak, nonatomic) IBOutlet UIButton *repeatButton; // Repeat button
@property (weak, nonatomic) IBOutlet UILabel *scrobbleHelpLabel; // The Scrobble Usage hint Label
@property (weak, nonatomic) IBOutlet UILabel *numberOfTracksLabel; // Track x of y or the scrobble speed
@property (weak, nonatomic) IBOutlet UIImageView *scrobbleHighlightShadow; // It's reflection
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

/// The BeamMusicPlayerDelegate object that acts as the delegate of the receiving music player.
@property (assign, nonatomic) id <BeamMusicPlayerDelegate> delegate;
/// The BeamMusicPlayerDataSource object that acts as the data source of the receiving music player.
@property (assign, nonatomic) id <BeamMusicPlayerDataSource> dataSource;
/// --------------------------------
/// @name Controlling Playback and Sound
/// --------------------------------

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

/**
 * Plays a given track using the supplied options.
 *
 * @param track the track that's to be played
 * @param position the position in the track at which the playback should begin
 * @param volume the Volume of the playback
 */
- (void)playTrack:(NSUInteger)track atPosition:(CGFloat)position volume:(CGFloat)volume;

/**
 * Shows or Hides the scrobble overlay in 3.5 inch displays
 *
 * @param show Yes, to show, No to hide overlay
 * @param animated Yes, to smoothly fade overlay
 */
- (void)showScrobbleOverlay:(BOOL)show animated:(BOOL)animated;

/**
 * Starts playback. If the player is already playing, this method does nothing except wasting some cycles.
 */
- (void)play;

/**
 * Starts playing the specified track. If the track is already playing, this method does nothing.
 */
//- (void)playTrack:(NSUInteger)track;

/**
 * Pauses the player. If the player is already paused, this method does nothing except generating some heat.
 */
- (void)pause;

/**
 * Stops the Player. If the player is already stopped, this method does nothing but seeks to the beginning of the current song.
 */
- (void)stop;

/**
 * Skips to the next track.
 *
 * If there is no next track, this method does nothing, if there is, it skips one track forward and informs the delegate.
 * In case [BeamMusicPlayerDelegate musicPlayer:shouldChangeTrack:] returns NO, the track is not changed.
 */
- (void)next;

/**
 * Skips to the previous track.
 *
 * If there is no previous track, i.e. the current track number is 0, this method does nothing, if there is, it skips one track backward and informs the delegate.
 * In case the [BeamMusicPlayerDelegate musicPlayer:shouldChangeTrack:] returns NO, the track is not changed.
 */
- (void)previous;


/// --------------------------------
/// @name Controlling User Interaction
/// --------------------------------

/// If set to yes, the Previous-Track Button will be disabled if the first track of the set is played or set.
@property (nonatomic) BOOL shouldHidePreviousTrackButtonAtBoundary;

/// If set to yes, the Next-Track Button will be disabled if the last track of the set is played or set.
@property (nonatomic) BOOL shouldHideNextTrackButtonAtBoundary;

/// --------------------------------
/// @name Misc
/// --------------------------------

/// The preferred size for cover art in pixels
@property (nonatomic) CGSize preferredSizeForCoverArt;

/// yes, if data source provided cover art for current song
@property (nonatomic) BOOL customCovertArtLoaded;

/// Timespan before placeholder for albumart will be set (default is 0.5). Supports long loading times.
@property (nonatomic, assign) float placeholderImageDelay;
@property (nonatomic, strong) NSTimer *playbackTickTimer; // Ticks each seconds when playing.
@property (nonatomic, strong) UITapGestureRecognizer *coverArtGestureRecognizer; // Tap Recognizer used to dim in / out the scrobble overlay.
@property (nonatomic) CGFloat currentTrackLength; // The Length of the currently playing track
@property (nonatomic) NSInteger numberOfTracks; // Number of tracks, <0 if unknown
@property (nonatomic) BOOL numberOfTracksAvailable;
@property (nonatomic) BOOL scrobbling; // Whether the player is currently scrobbling
@property (nonatomic) BOOL lastDirectionChangePositive; // Whether the last direction change was positive.
@end

@implementation BeamMusicPlayerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.view.backgroundColor = [[UIColor alloc] initWithPatternImage:[UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/black_linen_v2"]];
    
    // Scrobble overlay should always be visible on tall phones
    if(IS_IPHONE_4_OR_LESS) {
        self.scrobbleOverlay.alpha = 0;
        self.coverArtGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverArtTapped:)];
        [self.albumArtImageView addGestureRecognizer:self.coverArtGestureRecognizer];
    }
    else {
        self.scrobbleOverlay.alpha = 1;
    }
    
    // Progess Slider
    UIImage *knob = [UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/VolumeKnob"];
    [self.progressSlider setThumbImage:knob forState:UIControlStateNormal];
    self.progressSlider.maximumTrackTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    
    // Volume Slider
    UIImage *minImg = [[UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/speakerSliderMinValue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
    UIImage *maxImg = [[UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/speakerSliderMaxValue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
    UIImage *knobImg = [UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/speakerSliderKnob.png"];
    [self.volumeSlider setThumbImage:knobImg forState:UIControlStateNormal];
    [self.volumeSlider setThumbImage:knobImg forState:UIControlStateHighlighted];
    [self.volumeSlider setMinimumTrackImage:minImg forState:UIControlStateNormal];
    [self.volumeSlider setMaximumTrackImage:maxImg forState:UIControlStateNormal];

    // The Original Toolbar is 48px high in the iPod/Music app
    CGRect toolbarRect = self.controlsToolbar.frame;
    toolbarRect.size.height = 48;
    self.controlsToolbar.frame = toolbarRect;

    // Set UI to non-scrobble
    [self setScrobbleUI:NO animated:NO];
    
    // Set up labels. These are autoscrolling and need code-base setup.
    [self.artistNameLabel setShadowColor:[UIColor blackColor]];
    [self.artistNameLabel setShadowOffset:CGSizeMake(0, -1)];
    
    [self.albumTitleLabel setShadowColor:[UIColor blackColor]];
    [self.albumTitleLabel setShadowOffset:CGSizeMake(0, -1)];

    [self.artistNameLabel setTextColor:[UIColor lightTextColor]];
    [self.artistNameLabel setFont:[UIFont boldSystemFontOfSize:12]];
    
    [self.albumTitleLabel setTextColor:[UIColor lightTextColor]];
    [self.albumTitleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    
    self.trackTitleLabel.textColor = [UIColor whiteColor];
    [self.trackTitleLabel setFont:[UIFont boldSystemFontOfSize:12]];
    
    self.placeholderImageDelay = 0.5;
    
    
    
    BeamMPMusicPlayerProvider *mpMusicPlayerProvider = [BeamMPMusicPlayerProvider new];
    mpMusicPlayerProvider.controller = self;
    NSAssert(self.delegate == mpMusicPlayerProvider, @"setController: sets itself as delegate");
    NSAssert(self.dataSource == mpMusicPlayerProvider, @"setController: sets itself as datasource");
    
    mpMusicPlayerProvider.musicPlayer = [MPMusicPlayerController systemMusicPlayer];
    
    MPMediaQuery *mq = [MPMediaQuery songsQuery];
    [MPMusicPlayerController.systemMusicPlayer setQueueWithQuery:mq];
    mpMusicPlayerProvider.mediaItems = mq.items;
//    self.exampleProvider = mpMusicPlayerProvider;
    mpMusicPlayerProvider.musicPlayer.nowPlayingItem = [mpMusicPlayerProvider.mediaItems objectAtIndex:2];
    
    self.shouldHideNextTrackButtonAtBoundary = YES;
    self.shouldHidePreviousTrackButtonAtBoundary = YES;
}

- (void)dealloc
{
    self.actionButton = nil;
    self.backButton = nil;
    self.coverArtGestureRecognizer = nil;
}


#pragma mark - Playback Management

- (BOOL)numberOfTracksAvailable
{
    return self.numberOfTracks >= 0;
}

- (void)setAlbumArtToPlaceholder
{
    self.albumArtImageView.image = [UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/noartplaceholder.png"];
}

/**
 * Updates the UI to match the current track by requesting the information from the datasource.
 */
- (void)updateUIForCurrentTrack
{
    //set VolumeSlider initially
    if ([self.dataSource respondsToSelector:@selector(volumeForMusicPlayer:)]) {
        [self setVolume:[self.dataSource volumeForMusicPlayer:self]];
    }
    
    self.artistNameLabel.text = [self.dataSource musicPlayer:self artistForTrack:self.currentTrack];
    self.trackTitleLabel.text = [self.dataSource musicPlayer:self titleForTrack:self.currentTrack];
    self.albumTitleLabel.text = [self.dataSource musicPlayer:self albumForTrack:self.currentTrack];

    // set coverart to placeholder at a later point in time. Might be cancelled if datasource provides different image (see below)
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAlbumArtToPlaceholder) object:nil];
    [self performSelector:@selector(setAlbumArtToPlaceholder) withObject:nil afterDelay:self.placeholderImageDelay];

    // We only request the coverart if the delegate responds to it.
    self.customCovertArtLoaded = NO;
    if ([self.dataSource respondsToSelector:@selector(musicPlayer:artworkForTrack:receivingBlock:)]) {
        
        // TODO: this transition needs to be overhauled before going live
//        CATransition* transition = [CATransition animation];
//        transition.type = kCATransitionPush;
//        transition.subtype = self.lastDirectionChangePositive ? kCATransitionFromRight : kCATransitionFromLeft;
//        [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//        [[self.albumArtImageView layer] addAnimation:transition forKey:@"SlideOutandInImagek"];
//
//        [[self.albumArtReflection layer] addAnimation:transition forKey:@"SlideOutandInImagek"];

        // Copy the current track to another variable, otherwise we would just access the current one.
        NSUInteger track = self.currentTrack;
        
        // Request the image.
        [self.dataSource musicPlayer:self artworkForTrack:self.currentTrack receivingBlock:^(UIImage *image, NSError *__autoreleasing *error) {
            
            if (track == self.currentTrack) {
            
                // If there is no image given, stay with the placeholder
                if (image  != nil) {

                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAlbumArtToPlaceholder) object:nil];
                        self.albumArtImageView.image = image;
                        self.customCovertArtLoaded = YES;
                    });
                }
            
            } else {
                DLog(@"Discarded CoverArt for track: %lu, current track already moved to %ld.", (unsigned long)track, (long)self.currentTrack);
            }
        }];
    }
}

- (void)play
{
    if (!self.playing) {
        self.playing = YES;
        
        self.playbackTickTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playbackTick:) userInfo:nil repeats:YES];
        
        if ([self.delegate respondsToSelector:@selector(musicPlayerDidStartPlaying:)]) {
            [self.delegate musicPlayerDidStartPlaying:self];
        }
        
        [self adjustPlayButtonState];
    }
}

- (void)pause
{
    if (self.playing) {
        self.playing = NO;
        [self.playbackTickTimer invalidate];
        self.playbackTickTimer = nil;
        
        if ([self.delegate respondsToSelector:@selector(musicPlayerDidStopPlaying:)]) {
            [self.delegate musicPlayerDidStopPlaying:self];
        }
        
        [self adjustPlayButtonState];
    }
}

- (void)stop
{
    [self pause];
    self.currentPlaybackPosition = 0;
    [self updateSeekUI];
}

- (void)next
{
    self.lastDirectionChangePositive = YES;
    [self changeTrack:self.currentTrack + 1];
}

- (void)previous
{
    self.lastDirectionChangePositive = NO;
    [self changeTrack:self.currentTrack - 1];
}

/*
 * Called when the player finished playing the current track. 
 */
- (void)currentTrackFinished
{
    // TODO: deactivate automatic actions via additional property
    // overhaul this method
    if (self.repeatMode != MPMusicRepeatModeOne) {
        // [self next];  - reactivate me

    }
    else {
        self.currentPlaybackPosition = 0;
        [self updateSeekUI];
    }
}

- (void)playTrack:(NSUInteger)track atPosition:(CGFloat)position volume:(CGFloat)volume
{
    self.volume = volume;
    [self changeTrack:track];
    self.currentPlaybackPosition = position;
    [self updateSeekUI];
    [self play];
}

- (void)updateUI
{
    // Slider
    self.progressSlider.maximumValue = self.currentTrackLength;
    self.progressSlider.minimumValue = 0;
    
    [self updateUIForCurrentTrack];
    [self updateSeekUI];
    [self updateTrackDisplay];
    [self adjustDirectionalButtonStates];
}

/*
 * Changes the track to the new track given.
 */
- (void)changeTrack:(NSInteger)newTrack
{
    BOOL shouldChange = YES;
    
    if ([self.delegate respondsToSelector:@selector(musicPlayer:shouldChangeTrack:)]) {
        shouldChange = [self.delegate musicPlayer:self shouldChangeTrack:newTrack];
    }
    
    if ([self.dataSource respondsToSelector:@selector(numberOfTracksInPlayer:)]) {
        self.numberOfTracks = [self.dataSource numberOfTracksInPlayer:self];
    }
    else {
        self.numberOfTracks = -1;
    }

    if (newTrack < 0 || (self.numberOfTracksAvailable && newTrack >= self.numberOfTracks)) {
        shouldChange = NO;
        // If we can't next, stop the playback.
        // TODO: notify delegate about the fact we felt off the playlist
        [self pause];
    }
    
    if (shouldChange) {
        if ([self.delegate respondsToSelector:@selector(musicPlayer:didChangeTrack:)]) {
            newTrack = [self.delegate musicPlayer:self didChangeTrack:newTrack];
        }
        
        if (newTrack == NSNotFound) {
            // TODO: notify delegate about the fact we felt off the playlist
            [self pause];
        }
        else {
            self.currentPlaybackPosition = 0;
            self.currentTrack = newTrack;
            
            self.currentTrackLength = [self.dataSource musicPlayer:self lengthForTrack:self.currentTrack];
            [self updateUI];
        }
    }
}

/**
 * Reloads data from the data source and updates the player.
 */
- (void)reloadData
{
    
    if([self.dataSource respondsToSelector:@selector(numberOfTracksInPlayer:)]) {
        self.numberOfTracks = [self.dataSource numberOfTracksInPlayer:self];
    }
    else {
        self.numberOfTracks = -1;
    }
    
    self.currentTrackLength = [self.dataSource musicPlayer:self lengthForTrack:self.currentTrack];
    [self updateUI];
}

/**
 * Tick method called each second when playing back.
 */
- (void)playbackTick:(id)unused
{
    // Only tick forward if not scrobbling.
    if (!self.scrobbling) {
        if (self.currentPlaybackPosition+1.0 > self.currentTrackLength ) {
            [self currentTrackFinished];
        }
        else {
            self.currentPlaybackPosition += 1.0f;
            [self updateSeekUI];
        }
    }
}

/*
 * Updates the remaining and elapsed time label, as well as the progress bar's value
 */
- (void)updateSeekUI
{
    NSString* elapsed = [NSDateFormatter formattedDuration:(long)self.currentPlaybackPosition];
    NSString* remaining = [NSDateFormatter formattedDuration:(self.currentTrackLength-self.currentPlaybackPosition)*-1];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timeElapsedLabel.text =elapsed;
        self.timeRemainingLabel.text =remaining;
        self.progressSlider.value = self.currentPlaybackPosition;
    });
}

/*
 * Updates the Track Display ( Track 10 of 10 )
 */
- (void)updateTrackDisplay
{
    if (!self.scrobbling ) {
        self.numberOfTracksLabel.text = [NSString stringWithFormat:@"Track %ld of %ld", self.currentTrack + 1, (long)self.numberOfTracks];
        self.numberOfTracksLabel.hidden = !self.numberOfTracksAvailable;
    }
}

- (void)updateRepeatButton
{
    MPMusicRepeatMode currentMode = self.repeatMode;
    NSString *imageName = nil;
    
    switch (currentMode) {
        case MPMusicRepeatModeOne:
            imageName = @"repeat_on_1.png";
            break;
        case MPMusicRepeatModeAll:
            imageName = @"repeat_on.png";
            break;
        case MPMusicRepeatModeDefault:
        case MPMusicRepeatModeNone:
            NSAssert(FALSE, @"Need to handle when repeat none is on");
            break;
    }
    
    if (imageName) {
            [self.repeatButton setImage:[UIImage imageNamed:[@"BeamMusicPlayerController.bundle/images/" stringByAppendingString:imageName]] forState:UIControlStateNormal];
    }
}

#pragma mark Repeat mode

- (void)setRepeatMode:(MPMusicRepeatMode)newRepeatMode
{
    self.repeatMode = newRepeatMode;
    [self updateRepeatButton];
}

#pragma mark Shuffling ( Every day I'm )

- (void)setShuffling:(BOOL)newShuffling
{
    self.shuffling = newShuffling;
    
    NSString *imageName = (self.shuffling ? @"shuffle_on.png" : @"shuffle_off.png");
    [self.shuffleButton setImage:[UIImage imageNamed:[@"BeamMusicPlayerController.bundle/images/" stringByAppendingString:imageName]] forState:UIControlStateNormal];
}

#pragma mark - Volume

/*
 * Setting the volume really just changes the slider
 */
- (void)setVolume:(CGFloat)volume
{
    self.volumeSlider.value = volume;
}

/*
 * The Volume value is the slider value
 */
- (CGFloat)volume
{
    return self.volumeSlider.value;
}

#pragma mark - User Interface ACtions

- (IBAction)playAction:(UIBarButtonItem *)sender
{
    if (self.playing) {
        [self pause];
    } else {
        [self play];
    }
}

- (IBAction)nextAction:(id)sender
{
    [self next];
}

- (IBAction)previousAction:(id)sender
{
    // TODO: handle skipToBeginning if playbacktime <= 3
    [self previous];
}

- (void)showScrobbleOverlay:(BOOL)show animated:(BOOL)animated
{
    if(!IS_IPHONE_4_OR_LESS)
        return;

    [UIView animateWithDuration:animated?0.25:0 animations:^{
        self.scrobbleOverlay.alpha = show ? 1 : 0;
    }];
}


/**
 * Called when the cover art is tapped. Either shows or hides the scrobble-ui
 */
- (IBAction)coverArtTapped:(id)sender
{
    [self showScrobbleOverlay:self.scrobbleOverlay.alpha == 0 animated:YES];
}



#pragma mark - Playback button state management

/*
 * Adjusts the directional buttons to comply with the shouldHide-Button settings.
 */
- (void)adjustDirectionalButtonStates
{
    if (self.numberOfTracksAvailable && self.currentTrack+1 == self.numberOfTracks && self.shouldHideNextTrackButtonAtBoundary ) {
        self.fastForwardButton.enabled = NO;
    }
    else {
        self.fastForwardButton.enabled = YES;
    }
    
    if (self.numberOfTracksAvailable && self.currentTrack == 0 && self.shouldHidePreviousTrackButtonAtBoundary ) {
        self.rewindButton.enabled = NO;
    }
    else {
        self.rewindButton.enabled = YES;
    }
}

/*
 * Adjusts the state of the play button to match the current state of the player
 */
- (void)adjustPlayButtonState
{
    if (!self.playing) {
        self.playButton.image = [UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/play.png"];
        [self.playButtonIPad setImage:[UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/play.png"] forState:UIControlStateNormal];
    }
    else {
        self.playButton.image = [UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/pause.png"];
        [self.playButtonIPad setImage:[UIImage imageNamed:@"BeamMusicPlayerController.bundle/images/pause.png"] forState:UIControlStateNormal];
    }
}

- (void)setShouldHideNextTrackButtonAtBoundary:(BOOL)newShouldHideNextTrackButtonAtBoundary
{
    self.shouldHideNextTrackButtonAtBoundary = newShouldHideNextTrackButtonAtBoundary;
    [self adjustDirectionalButtonStates];
}

- (void)setShouldHidePreviousTrackButtonAtBoundary:(BOOL)newShouldHidePreviousTrackButtonAtBoundary
{
    self.shouldHidePreviousTrackButtonAtBoundary = newShouldHidePreviousTrackButtonAtBoundary;
    [self adjustDirectionalButtonStates];
}

#pragma mark - scrubbing slider

/**
 * Called whenever the scrubber changes it's speed. Used to update the display of the scrobble speed.
 */
- (void)updateUIForScrubbingSpeed:(CGFloat)speed
{
    if (speed == 1.0 ) {
        self.numberOfTracksLabel.text = @"Hi-Speed Scrubbing";
    }
    else if (speed == 0.5){
        self.numberOfTracksLabel.text = @"Half-Speed Scrubbing";
        
    }
    else if (speed == 0.25){
        self.numberOfTracksLabel.text = @"Quarter-Speed Scrubbing";
        
    }
    else {
        self.numberOfTracksLabel.text = @"Fine Scrubbing";
    }
}

/**
 * Dims away the repeat and shuffle button
 */
- (IBAction)sliderDidBeginScrubbing:(id)sender
{
    self.scrobbling = YES;
    [self setScrobbleUI:YES animated:YES];
}

/**
 * Shows the repeat and shuffle button and hides the scrobble help
 */
- (IBAction)sliderDidEndScrubbing:(id)sender
{
    self.scrobbling = NO;
    [self setScrobbleUI:NO animated:YES];
    [self updateTrackDisplay];
}


/*
 * Updates the UI according to the current scrobble state given.
 */
- (void)setScrobbleUI:(BOOL)scrobbleState animated:(BOOL)animated
{
    float alpha = (scrobbleState ? 1 : 0);
    [UIView animateWithDuration:animated?0.25:0 animations:^{
        self.repeatButton.alpha = 1-alpha;
        self.shuffleButton.alpha = 1-alpha;
        self.scrobbleHelpLabel.alpha = alpha;
        self.scrobbleHighlightShadow.alpha = alpha;
    }];
}

/*
 * Action triggered by the continous track progress slider
 */
- (IBAction)sliderValueChanged:(id)slider
{
    self.currentPlaybackPosition = self.progressSlider.value;
    
//    [self updateUIForScrubbingSpeed: self.progressSlider.scrubbingSpeed];
    
    if ([self.delegate respondsToSelector:@selector(musicPlayer:didSeekToPosition:)]) {
        [self.delegate musicPlayer:self didSeekToPosition:self.currentPlaybackPosition];
    }
    
    [self updateSeekUI];
    
}

/*
 * Action triggered by the volume slider
 */
- (IBAction)volumeSliderValueChanged:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(musicPlayer:didChangeVolume:)]) {
        [self.delegate musicPlayer:self didChangeVolume:self.volumeSlider.value];
    }
}

/*
 * Action triggered by the repeat mode button
 */
- (IBAction)repeatModeButtonAction:(id)sender
{
    MPMusicRepeatMode currentMode = self.repeatMode;
    
    switch (currentMode) {
        case MPMusicRepeatModeDefault:
            self.repeatMode = MPMusicRepeatModeAll;
            break;
        case MPMusicRepeatModeOne:
            self.repeatMode = MPMusicRepeatModeDefault;
            break;
        case MPMusicRepeatModeAll:
            self.repeatMode = MPMusicRepeatModeOne;
            break;
        default:
            self.repeatMode = MPMusicRepeatModeOne;
            break;
    }
    
    if ([self.delegate respondsToSelector:@selector(musicPlayer:didChangeRepeatMode:)]) {
        [self.delegate musicPlayer:self didChangeRepeatMode:self.repeatMode];
    }
}

/*
 * Changes the shuffle mode and calls the delegate
 */
- (IBAction)shuffleButtonAction:(id)sender
{
    self.shuffling = !self.shuffling;
    if ([self.delegate respondsToSelector:@selector(musicPlayer:didChangeShuffleState:)]) {
        [self.delegate musicPlayer:self didChangeShuffleState:self.shuffling];
    }
}

- (IBAction)backButtonAction:(id)sender
{
    DLog(@"");
}

/*
 * Just forward the action message to the delegate
 */
- (IBAction)actionButtonAction:(id)sender
{
    DLog(@"");
}

#pragma mark Cover Art resolution handling

- (CGSize)preferredSizeForCoverArt
{
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize points = self.albumArtImageView.frame.size;
    return  CGSizeMake(points.width * scale, points.height * scale);
}

- (CGFloat)displayScale
{
    return [UIScreen mainScreen].scale;
}


@end
