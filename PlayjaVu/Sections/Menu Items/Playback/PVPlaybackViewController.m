//
//  PVPlaybackViewController.m
//  Part of PVPlaybackViewController (license: New BSD)
//  -> https://github.com/BeamApp/MusicPlayerViewController
//
//  Created by Moritz Haarmann on 30.05.12.
//  Copyright (c) 2012 BeamApp UG. All rights reserved.
//

#import "PVPlaybackViewController.h"
#import "PVPlaybackViewModel.h"
#import "SlideNavigationController.h"
#import "NSDateFormatter+Duration.h"
#import <MediaPlayer/MediaPlayer.h>
#import "AutoScrollLabel.h"
#import <QuartzCore/QuartzCore.h>

@interface PVPlaybackViewController()
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
@property (strong, nonatomic) UITapGestureRecognizer *coverArtGestureRecognizer; // Tap Recognizer used to dim in / out the scrobble overlay.
/// If set to yes, the Previous-Track Button will be disabled if the first track of the set is played or set.
@property (nonatomic) BOOL shouldHidePreviousTrackButtonAtBoundary;
/// If set to yes, the Next-Track Button will be disabled if the last track of the set is played or set.
@property (nonatomic) BOOL shouldHideNextTrackButtonAtBoundary;
@property (strong, nonatomic) PVPlaybackViewModel *viewModel;
@end

@implementation PVPlaybackViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self configureViewModel];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Scrobble overlay
    self.scrobbleOverlay.alpha = 1;
    self.coverArtGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverArtTapped:)];
    [self.albumArtImageView addGestureRecognizer:self.coverArtGestureRecognizer];
    
    // Progess Slider
    UIImage *knob = [UIImage imageNamed:@"PVPlaybackController.bundle/images/VolumeKnob"];
    [self.progressSlider setThumbImage:knob forState:UIControlStateNormal];
    self.progressSlider.maximumTrackTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    
    // Volume Slider
    UIImage *minImg = [[UIImage imageNamed:@"PVPlaybackController.bundle/images/speakerSliderMinValue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
    UIImage *maxImg = [[UIImage imageNamed:@"PVPlaybackController.bundle/images/speakerSliderMaxValue.png"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16)];
    UIImage *knobImg = [UIImage imageNamed:@"PVPlaybackController.bundle/images/speakerSliderKnob.png"];
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
    
    self.shouldHideNextTrackButtonAtBoundary = YES;
    self.shouldHidePreviousTrackButtonAtBoundary = YES;
}

- (void)dealloc
{
    self.actionButton = nil;
    self.backButton = nil;
    self.coverArtGestureRecognizer = nil;
}

- (void)configureViewModel
{
    _viewModel = [[PVPlaybackViewModel alloc] init];
    _viewModel.placeholderImageDelay = 0.5;
}

#pragma mark - Playback Management

- (void)setAlbumArtToPlaceholder
{
    self.albumArtImageView.image = [UIImage imageNamed:@"PVPlaybackController.bundle/images/noartplaceholder.png"];
}

/**
 * Updates the UI to match the current track by requesting the information from the datasource.
 */
- (void)updateUIForCurrentTrack
{
    //set VolumeSlider initially
#warning is this correct?
    [self.viewModel setVolume:[self.viewModel volume]];
    
    self.artistNameLabel.text = [self.viewModel artistForTrack:self.viewModel.currentTrack];
    self.trackTitleLabel.text = [self.viewModel titleForTrack:self.viewModel.currentTrack];
    self.albumTitleLabel.text = [self.viewModel albumForTrack:self.viewModel.currentTrack];

    // set coverart to placeholder at a later point in time. Might be cancelled if datasource provides different image (see below)
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAlbumArtToPlaceholder) object:nil];
    [self performSelector:@selector(setAlbumArtToPlaceholder) withObject:nil afterDelay:self.viewModel.placeholderImageDelay];

    // We only request the coverart if the delegate responds to it.
    self.viewModel.customCovertArtLoaded = NO;
    
//    // TODO: this transition needs to be overhauled before going live
//    CATransition* transition = [CATransition animation];
//    transition.type = kCATransitionPush;
//    transition.subtype = self.lastDirectionChangePositive ? kCATransitionFromRight : kCATransitionFromLeft;
//    [transition setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut]];
//    [[self.albumArtImageView layer] addAnimation:transition forKey:@"SlideOutandInImagek"];
//    
//    [[self.albumArtReflection layer] addAnimation:transition forKey:@"SlideOutandInImagek"];
    
    // Copy the current track to another variable, otherwise we would just access the current one.
    NSUInteger track = self.viewModel.currentTrack;
    
    // Request the image.
    [self.viewModel artworkForTrack:self.viewModel.currentTrack receivingBlock:^(UIImage *image, NSError *__autoreleasing *error) {
        
        if (track == self.viewModel.currentTrack) {
            
            // If there is no image given, stay with the placeholder
            if (image  != nil) {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAlbumArtToPlaceholder) object:nil];
                    self.albumArtImageView.image = image;
                    self.viewModel.customCovertArtLoaded = YES;
                });
            }
            
        } else {
            DLog(@"Discarded CoverArt for track: %lu, current track already moved to %ld.", (unsigned long)track, (long)self.viewModel.currentTrack);
        }
    }];
}

/**
 * Starts playback. If the player is already playing, this method does nothing except wasting some cycles.
 */
- (void)play
{
    if (!self.viewModel.playing) {
        self.viewModel.playing = YES;
        
        self.viewModel.playbackTickTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playbackTick:) userInfo:nil repeats:YES];
        
        [self.viewModel startPlaying];
        
        [self adjustPlayButtonState];
    }
}

/**
 * Pauses the player. If the player is already paused, this method does nothing except generating some heat.
 */
- (void)pause
{
    if (self.viewModel.playing) {
        self.viewModel.playing = NO;
        [self.viewModel.playbackTickTimer invalidate];
        self.viewModel.playbackTickTimer = nil;
        
        [self.viewModel stopPlaying];
        
        [self adjustPlayButtonState];
    }
}

/**
 * Stops the Player. If the player is already stopped, this method does nothing but seeks to the beginning of the current song.
 */
- (void)stop
{
    [self pause];
    self.viewModel.currentPlaybackPosition = 0;
    [self updateSeekUI];
}

/**
 * Skips to the next track.
 *
 * If there is no next track, this method does nothing, if there is, it skips one track forward and informs the delegate.
 * In case [PVPlaybackDelegate musicPlayer:shouldChangeTrack:] returns NO, the track is not changed.
 */
- (void)next
{
    self.viewModel.lastDirectionChangePositive = YES;
    [self changeTrack:self.viewModel.currentTrack + 1];
}

/**
 * Skips to the previous track.
 *
 * If there is no previous track, i.e. the current track number is 0, this method does nothing, if there is, it skips one track backward and informs the delegate.
 * In case the [PVPlaybackDelegate musicPlayer:shouldChangeTrack:] returns NO, the track is not changed.
 */
- (void)previous
{
    self.viewModel.lastDirectionChangePositive = NO;
    [self changeTrack:self.viewModel.currentTrack - 1];
}

/*
 * Called when the player finished playing the current track. 
 */
- (void)currentTrackFinished
{
    // TODO: deactivate automatic actions via additional property
    // overhaul this method
    if (self.viewModel.repeatMode != MPMusicRepeatModeOne) {
        // [self next];  - reactivate me

    }
    else {
        self.viewModel.currentPlaybackPosition = 0;
        [self updateSeekUI];
    }
}

/**
 * Plays a given track using the supplied options.
 *
 * @param track the track that's to be played
 * @param position the position in the track at which the playback should begin
 * @param volume the Volume of the playback
 */
- (void)playTrack:(NSUInteger)track atPosition:(CGFloat)position volume:(CGFloat)volume
{
    self.volume = volume;
    [self changeTrack:track];
    self.viewModel.currentPlaybackPosition = position;
    [self updateSeekUI];
    [self play];
}

- (void)updateUI
{
    // Slider
    self.progressSlider.maximumValue = self.viewModel.currentTrackLength;
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
    
    shouldChange = [self.viewModel shouldChangeTrack:newTrack];
    
#warning review this too
    self.viewModel.numberOfTracks = [self.viewModel numberOfTracks];
    

    if (newTrack < 0 || (self.viewModel.tracksAreAvailable && newTrack >= self.viewModel.numberOfTracks)) {
        shouldChange = NO;
        // If we can't next, stop the playback.
        // TODO: notify delegate about the fact we felt off the playlist
        [self pause];
    }
    
    if (shouldChange) {
        newTrack = [self.viewModel didChangeTrack:newTrack];
        
        if (newTrack == NSNotFound) {
            // TODO: notify delegate about the fact we felt off the playlist
            [self pause];
        }
        else {
            self.viewModel.currentPlaybackPosition = 0;
            self.viewModel.currentTrack = newTrack;
            
#warning review this
            self.viewModel.currentTrackLength = [self.viewModel lengthForTrack:self.viewModel.currentTrack];
            [self updateUI];
        }
    }
}

/**
 * Reloads data from the data source and updates the player.
 */
- (void)reloadData
{
    
//#warning review these two
//    self.viewModel.numberOfTracks = [self.viewModel numberOfTracks];
    self.viewModel.currentTrackLength = [self.viewModel lengthForTrack:self.viewModel.currentTrack];
    
    [self updateUI];
}

/**
 * Tick method called each second when playing back.
 */
- (void)playbackTick:(id)unused
{
    // Only tick forward if not scrobbling.
    if (!self.viewModel.scrobbling) {
        if (self.viewModel.currentPlaybackPosition + 1.0 > self.viewModel.currentTrackLength ) {
            [self currentTrackFinished];
        }
        else {
            self.viewModel.currentPlaybackPosition += 1.0f;
            [self updateSeekUI];
        }
    }
}

/*
 * Updates the remaining and elapsed time label, as well as the progress bar's value
 */
- (void)updateSeekUI
{
    NSString *elapsed = [NSDateFormatter formattedDuration:(long)self.viewModel.currentPlaybackPosition];
    NSString *remaining = [NSDateFormatter formattedDuration:(self.viewModel.currentTrackLength - self.viewModel.currentPlaybackPosition) * -1];
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timeElapsedLabel.text = elapsed;
        self.timeRemainingLabel.text = remaining;
        self.progressSlider.value = self.viewModel.currentPlaybackPosition;
    });
}

/*
 * Updates the Track Display ( Track 10 of 10 )
 */
- (void)updateTrackDisplay
{
    if (!self.viewModel.scrobbling ) {
        self.numberOfTracksLabel.text = [NSString stringWithFormat:@"Track %ld of %ld", self.viewModel.currentTrack + 1, (long)self.viewModel.numberOfTracks];
        self.numberOfTracksLabel.hidden = !self.viewModel.tracksAreAvailable;
    }
}

- (void)updateRepeatButton
{
    MPMusicRepeatMode currentMode = self.viewModel.repeatMode;
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
            [self.repeatButton setImage:[UIImage imageNamed:[@"PVPlaybackController.bundle/images/" stringByAppendingString:imageName]] forState:UIControlStateNormal];
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
    
    NSString *imageName = (self.viewModel.shuffling ? @"shuffle_on.png" : @"shuffle_off.png");
    [self.shuffleButton setImage:[UIImage imageNamed:[@"PVPlaybackController.bundle/images/" stringByAppendingString:imageName]] forState:UIControlStateNormal];
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
    if (self.viewModel.playing) {
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

/**
 * Shows or Hides the scrobble overlay in 3.5 inch displays
 *
 * @param show Yes, to show, No to hide overlay
 * @param animated Yes, to smoothly fade overlay
 */
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
    DLogPurple(@"");
    if (self.viewModel.tracksAreAvailable && self.viewModel.currentTrack + 1 == self.viewModel.numberOfTracks && self.shouldHideNextTrackButtonAtBoundary) {
        self.fastForwardButton.enabled = NO;
    }
    else {
        self.fastForwardButton.enabled = YES;
    }
    
    if (self.viewModel.tracksAreAvailable && self.viewModel.currentTrack == 0 && self.shouldHidePreviousTrackButtonAtBoundary) {
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
    if (!self.viewModel.playing) {
        self.playButton.image = [UIImage imageNamed:@"PVPlaybackController.bundle/images/play.png"];
        [self.playButtonIPad setImage:[UIImage imageNamed:@"PVPlaybackController.bundle/images/play.png"] forState:UIControlStateNormal];
    }
    else {
        self.playButton.image = [UIImage imageNamed:@"PVPlaybackController.bundle/images/pause.png"];
        [self.playButtonIPad setImage:[UIImage imageNamed:@"PVPlaybackController.bundle/images/pause.png"] forState:UIControlStateNormal];
    }
}

//- (void)setShouldHideNextTrackButtonAtBoundary:(BOOL)newShouldHideNextTrackButtonAtBoundary
//{
//    self.shouldHideNextTrackButtonAtBoundary = newShouldHideNextTrackButtonAtBoundary;
//    [self adjustDirectionalButtonStates];
//}
//
//- (void)setShouldHidePreviousTrackButtonAtBoundary:(BOOL)newShouldHidePreviousTrackButtonAtBoundary
//{
//    self.shouldHidePreviousTrackButtonAtBoundary = newShouldHidePreviousTrackButtonAtBoundary;
//    [self adjustDirectionalButtonStates];
//}

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
    self.viewModel.scrobbling = YES;
    [self setScrobbleUI:YES animated:YES];
}

/**
 * Shows the repeat and shuffle button and hides the scrobble help
 */
- (IBAction)sliderDidEndScrubbing:(id)sender
{
    self.viewModel.scrobbling = NO;
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
    self.viewModel.currentPlaybackPosition = self.progressSlider.value;
    
//    [self updateUIForScrubbingSpeed: self.progressSlider.scrubbingSpeed];
    
    [self.viewModel didSeekToPosition:self.viewModel.currentPlaybackPosition];
    
    [self updateSeekUI];
    
}

/*
 * Action triggered by the volume slider
 */
- (IBAction)volumeSliderValueChanged:(id)sender
{
    [self.viewModel didChangeVolume:self.volumeSlider.value];
}

/*
 * Action triggered by the repeat mode button
 */
- (IBAction)repeatModeButtonAction:(id)sender
{
    MPMusicRepeatMode currentMode = self.viewModel.repeatMode;
    
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
    
    [self.viewModel didChangeRepeatMode:self.viewModel.repeatMode];
}

/*
 * Changes the shuffle mode and calls the delegate
 */
- (IBAction)shuffleButtonAction:(id)sender
{
    self.viewModel.shuffling = !self.viewModel.shuffling;
    [self.viewModel didChangeShuffleState:self.viewModel.shuffling];
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
