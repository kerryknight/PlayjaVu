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
@property (weak, nonatomic) IBOutlet UISlider *progressSlider; // Progress Slider buried in the Progress View
@property (weak, nonatomic) IBOutlet AutoScrollLabel *trackTitleLabel; // The Title Label
@property (weak, nonatomic) IBOutlet AutoScrollLabel *albumTitleLabel; // Album Label
@property (weak, nonatomic) IBOutlet AutoScrollLabel *artistNameLabel; // Artist Name Label
@property (weak, nonatomic) IBOutlet UIToolbar *controlsToolbar; // Encapsulates the Play, Forward, Rewind buttons
@property (retain, nonatomic) IBOutlet UIBarButtonItem *actionButton; // retain, since controller keeps a reference while it might be detached from view hierarchy
@property (retain, nonatomic) IBOutlet UIBarButtonItem *backButton; // retain, since controller keeps a reference while it might be detached from view hierarchy
@property (weak, nonatomic) IBOutlet UIButton *previousButton; // Previous Track
@property (weak, nonatomic) IBOutlet UIButton *nextButton; // Next Track
@property (weak, nonatomic) IBOutlet UIButton *playButton; // Play
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
@property (strong, nonatomic) NSDate *startTime;
@end

@implementation PVPlaybackViewController

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // add our gesture recognizer
    self.coverArtGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(coverArtTapped:)];
    [self.albumArtImageView addGestureRecognizer:self.coverArtGestureRecognizer];
    
    // set up our UI
    [self configureUI];
    
    // set up our view model once the view loads
    [self configureViewModel];
}

- (void)dealloc
{
    self.actionButton = nil;
    self.backButton = nil;
    self.coverArtGestureRecognizer = nil;
}

- (void)configureUI
{
    self.view.backgroundColor = kMedGray;
    
    // Scrobble overlay
    self.scrobbleOverlay.alpha = 1;
    
    // Progess Slider
    UIImage *knob = [UIImage imageNamed:@"PVPlaybackController.bundle/images/VolumeKnob"];
    [self.progressSlider setThumbImage:knob forState:UIControlStateNormal];
    self.progressSlider.maximumTrackTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
    
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

- (void)configureViewModel
{
    _viewModel = [[PVPlaybackViewModel alloc] init];
    _viewModel.placeholderImageDelay = 0.5;
    
    // subscribe to our updates method
    [[_viewModel.updatePlaybackUISignal deliverOn:[RACScheduler mainThreadScheduler]] subscribeNext:^(id x) {
        [self updateUI];
    }];

    // subscribe to our play signal
    [_viewModel.playSignal subscribeNext:^(NSNumber *trackIndex) {
        [self playOrResume];
    }];
    
    _viewModel.active = YES;
}

#pragma mark - Playback Management

- (void)setAlbumArtToPlaceholder
{
    self.albumArtImageView.image = [UIImage imageNamed:@"PVPlaybackController.bundle/images/noartplaceholder.png"];
}

- (void)updateUI
{
    DLogYellow(@"");
    os_activity_initiate("updateUI", OS_ACTIVITY_FLAG_DETACHED, ^{
        // Slider
        self.progressSlider.maximumValue = [self.viewModel trackLength];
        self.progressSlider.minimumValue = 0;
        
        [self updateUIForCurrentTrack];
        [self updateSeekUI];
        [self adjustDirectionalButtonStates];
        
        DLogRed(@"prev button: %@", NSStringFromCGRect(self.previousButton.frame));
        DLogRed(@"play button: %@", NSStringFromCGRect(self.playButton.frame));
        DLogRed(@"next button: %@", NSStringFromCGRect(self.nextButton.frame));
    });
}

/*
 * Updates the remaining and elapsed time label, as well as the progress bar's value
 */
- (void)updateSeekUI
{
    NSString *elapsed = [NSDateFormatter formattedDuration:(long)self.viewModel.currentPlaybackPosition];
    NSString *remaining = [NSDateFormatter formattedDuration:([self.viewModel trackLength] - self.viewModel.currentPlaybackPosition) * -1];
    
    // update labels and slider
    dispatch_async(dispatch_get_main_queue(), ^{
        self.timeElapsedLabel.text = elapsed;
        self.timeRemainingLabel.text = remaining;
        self.progressSlider.value = self.viewModel.currentPlaybackPosition;
    });
}

/**
 * Updates the UI to match the current track by requesting the information from the datasource.
 */
- (void)updateUIForCurrentTrack
{
    dispatch_async(dispatch_get_main_queue(), ^{
        os_activity_set_breadcrumb("updateUIForCurrentTrack:updateText");
        self.artistNameLabel.text = [self.viewModel trackArtist];
        self.trackTitleLabel.text = [self.viewModel trackTitle];
        self.albumTitleLabel.text = [self.viewModel trackAlbum];
        
        DLogGreen(@"ARTIST: %@", self.artistNameLabel.text);
        
        // set cover art to placeholder at a later point in time. Might be cancelled if datasource provides different image (see below)
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAlbumArtToPlaceholder) object:nil];
        [self performSelector:@selector(setAlbumArtToPlaceholder) withObject:nil afterDelay:self.viewModel.placeholderImageDelay];
        
        NSDate *endTime = [NSDate date];
        NSTimeInterval executionTime = [endTime timeIntervalSinceDate:self.startTime];
        DLogYellow(@"updateUIForCurrentTrack execution time = %f", executionTime);
    });

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        os_activity_set_breadcrumb("updateUIForCurrentTrack:getArtwork");
        // We only request the coverart if the delegate responds to it.
        self.viewModel.customCovertArtLoaded = NO;
        
        // Copy the current track to another variable, otherwise we would just access the current one.
        NSUInteger track = self.viewModel.currentTrack;
        
        // Request the image.
        [self.viewModel artworkForCurrentTrackWithCompletion:^(MPMediaItemArtwork *mediaArt, NSError *__autoreleasing *error) {
            os_activity_set_breadcrumb("updateUIForCurrentTrack:gotArtwork");
            
            if (track == self.viewModel.currentTrack) {
                
                // If there is no image given, stay with the placeholder
                if (mediaArt) {
                    
                    DLogPurple(@"self.preferredSizeForCoverArt: %@", NSStringFromCGSize(self.preferredSizeForCoverArt));
                    UIImage *artwork = [mediaArt imageWithSize:self.preferredSizeForCoverArt];
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(setAlbumArtToPlaceholder) object:nil];
                        self.albumArtImageView.image = artwork;
                        self.viewModel.customCovertArtLoaded = YES;
                    });
                }
                
            } else {
                DLog(@"Discarded CoverArt for track: %lu, current track already moved to %ld.", (unsigned long)track, (long)self.viewModel.currentTrack);
            }
        }];
    });
}

- (void)updateRepeatButton
{
    NSAssert([[NSThread currentThread] isMainThread], @"-updateRepeatButton must be called from main thread.");
    
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

/**
 * Starts playback. If the player is already playing, this method does nothing except wasting some cycles.
 */
- (void)playOrResume
{
    os_activity_initiate("Play/Resume Track", OS_ACTIVITY_FLAG_DETACHED, ^{
        // if we aren't currently, we were stopped an hit the Play button
        if (!self.viewModel.playing) {
            // start playing new
            self.viewModel.playing = YES;
            [self.viewModel startPlaying];
        }
        else {
            // else, we were already playing music when we opened the app
            // so we'll just continue playing and don't need to do anything here
        }
        
        [self adjustPlayButtonState];
        [self.viewModel.playbackTickTimer invalidate];
        self.viewModel.playbackTickTimer = nil;
        self.viewModel.playbackTickTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playbackTick:) userInfo:nil repeats:YES];
        self.viewModel.playbackTickTimer.tolerance = 1.0; // 1 second tolerance
    });
}

/**
 * Pauses the player. If the player is already paused, this method does nothing except generating some heat.
 */
- (void)pause
{
    os_activity_initiate("Pause Track", OS_ACTIVITY_FLAG_DETACHED, ^{
        if (self.viewModel.playing) {
            self.viewModel.playing = NO;
            [self.viewModel.playbackTickTimer invalidate];
            self.viewModel.playbackTickTimer = nil;
            
            [self.viewModel stopPlaying];
            
            [self adjustPlayButtonState];
        }
    });
}

/**
 * Stops the Player. If the player is already stopped, this method does nothing but seeks to the beginning of the current song.
 */
- (void)stop
{
    os_activity_initiate("Stop Track", OS_ACTIVITY_FLAG_DETACHED, ^{
        [self pause];
        self.viewModel.currentPlaybackPosition = 0;
        [self updateSeekUI];
    });
}

/**
 * Skips to the next track.
 *
 * If there is no next track, this method does nothing, if there is, it skips one track forward and informs the delegate.
 */
- (void)next
{
    os_activity_initiate("Next Track", OS_ACTIVITY_FLAG_DETACHED, ^{
        [self changeToTrack:self.viewModel.currentTrack + 1];
    });
}

/**
 * Skips to the previous track.
 *
 * If there is no previous track, i.e. the current track number is 0, this method does nothing, if there is, it skips one track backward and informs the delegate.
 * In case the [PVPlaybackDelegate musicPlayer:shouldChangeTrack:] returns NO, the track is not changed.
 */
- (void)previous
{
    os_activity_initiate("Previous Track", OS_ACTIVITY_FLAG_DETACHED, ^{
        // only skip backwards if we're less than 2 seconds from the start of the song;
        // otherwise, simply skip back to the start of the song
        NSInteger numberOfTracksToMove = self.viewModel.currentPlaybackPosition <= 2 ? 1 : 0;
        [self changeToTrack:self.viewModel.currentTrack - numberOfTracksToMove];
    });
}

/*
 * Called when the player finished playing the current track.
 */
- (void)currentTrackFinished
{
    if (self.viewModel.repeatMode != MPMusicRepeatModeOne) {
        [self next];
    }
    else {
        self.viewModel.currentPlaybackPosition = 0;
    }
    
    [self updateUI];
}

/*
 * Changes the track to the new track given.
 */
- (void)changeToTrack:(NSInteger)track
{
    os_activity_set_breadcrumb("changeToTrack:");
    __block NSInteger newTrack = track;
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // benchmarking
        self.startTime = [NSDate date];
        
        BOOL shouldChange = YES;
        
        if (newTrack < 0 || (self.viewModel.tracksAreAvailable && newTrack >= self.viewModel.numberOfTracks)) {
            shouldChange = NO;
            os_activity_set_breadcrumb("changeToTrack:paused");
            // If we can't next, stop the playback.
            // TODO: notify delegate about the fact we fell off the playlist
            [self pause];
        }
        
        if (shouldChange) {
            newTrack = [self.viewModel didChangeTrack:newTrack];
            
            if (newTrack == NSNotFound) {
                os_activity_set_breadcrumb("changeToTrack:newTrack:NotFound");
                // TODO: notify delegate about the fact we felt off the playlist
                [self pause];
            }
            else {
                os_activity_set_breadcrumb("changeToTrack:newTrack:Found");
                self.viewModel.currentPlaybackPosition = 0;
                self.viewModel.currentTrack = newTrack;
            }
        }
        
#warning BE SURE TO REMOVE ALL THESE TIMERS
        NSDate *endTime = [NSDate date];
        NSTimeInterval executionTime = [endTime timeIntervalSinceDate:self.startTime];
        DLogYellow(@"changeToTrack: execution time = %f", executionTime);
    });
}

/**
 * Tick method called each second when playing back.
 */
- (void)playbackTick:(id)unused
{
    // Only tick forward if not scrobbling.
    if (!self.viewModel.scrobbling) {
        if (self.viewModel.currentPlaybackPosition + 1.0 > [self.viewModel trackLength]) {
            [self currentTrackFinished];
        }
        else {
            self.viewModel.currentPlaybackPosition += 1.0f;
            [self updateSeekUI];
        }
    }
}

#pragma mark Repeat mode

- (void)setRepeatMode:(MPMusicRepeatMode)newRepeatMode
{
    DLogOrange(@"");
//    self.repeatMode = newRepeatMode;
//    [self updateRepeatButton];
}

#pragma mark Shuffling ( Every day I'm )

- (void)setShuffling:(BOOL)newShuffling
{
    NSAssert([[NSThread currentThread] isMainThread], @"-setShuffling must be called from main thread.");
    self.shuffling = newShuffling;
    
    NSString *imageName = (self.viewModel.shuffling ? @"shuffle_on.png" : @"shuffle_off.png");
    [self.shuffleButton setImage:[UIImage imageNamed:[@"PVPlaybackController.bundle/images/" stringByAppendingString:imageName]] forState:UIControlStateNormal];
}

#pragma mark - Volume

#pragma mark - User Interface Actions
- (IBAction)playAction:(id)sender
{
    if (self.viewModel.playing) {
        [self pause];
    } else {
        [self playOrResume];
    }
}

- (IBAction)nextAction:(id)sender
{
    [self next];
}

- (IBAction)previousAction:(id)sender
{
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
    [UIView animateWithDuration:animated ? 0.25 : 0 animations:^{
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
//    if (self.viewModel.tracksAreAvailable && self.viewModel.currentTrack + 1 == self.viewModel.numberOfTracks && self.shouldHideNextTrackButtonAtBoundary) {
//        self.nextButton.enabled = NO;
//    }
//    else {
//        self.nextButton.enabled = YES;
//    }
//    
//    if (self.viewModel.tracksAreAvailable && self.viewModel.currentTrack == 0 && self.shouldHidePreviousTrackButtonAtBoundary) {
//        self.previousButton.enabled = NO;
//    }
//    else {
//        self.previousButton.enabled = YES;
//    }
//    
//    NSDate *endTime = [NSDate date];
//    NSTimeInterval executionTime = [endTime timeIntervalSinceDate:self.startTime];
//    DLogYellow(@"adjustDirectionalButtonStates execution time = %f", executionTime);
}

/*
 * Adjusts the state of the play button to match the current state of the player
 */
- (void)adjustPlayButtonState
{
    if (!self.viewModel.playing) {
        self.playButton.imageView.image = [UIImage imageNamed:@"playButton"];
    }
    else {
        self.playButton.imageView.image = [UIImage imageNamed:@"pauseButton"];
    }
}

#pragma mark - scrubbing slider

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
}

/*
 * Updates the UI according to the current scrobble state given.
 */
- (void)setScrobbleUI:(BOOL)scrobbleState animated:(BOOL)animated
{
    float alpha = (scrobbleState ? 1 : 0);
    
    [UIView animateWithDuration:animated ? 0.25 : 0 animations:^{
        self.repeatButton.alpha = 1 - alpha;
        self.shuffleButton.alpha = 1 - alpha;
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
    [self.viewModel didSeekToPosition:self.viewModel.currentPlaybackPosition];
    [self updateSeekUI];
}

/*
 * Action triggered by the repeat mode button
 */
- (IBAction)repeatModeButtonAction:(id)sender
{
    DLogOrange(@"");
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
    DLogOrange(@"");
    self.viewModel.shuffling = !self.viewModel.shuffling;
    [self.viewModel didChangeShuffleState:self.viewModel.shuffling];
}

- (IBAction)backButtonAction:(id)sender
{
    DLogOrange(@"");
}

/*
 * Just forward the action message to the delegate
 */
- (IBAction)actionButtonAction:(id)sender
{
    DLogOrange(@"");
}

#pragma mark Cover Art resolution handling

- (CGSize)preferredSizeForCoverArt
{
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize points = self.albumArtImageView.frame.size;
    return  CGSizeMake(points.width * scale, points.height * scale);
}

@end
