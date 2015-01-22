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
#import <QuartzCore/QuartzCore.h>

@interface PVPlaybackViewController()
@property (weak, nonatomic) IBOutlet UISlider *progressSlider; // Progress Slider buried in the Progress View
@property (weak, nonatomic) IBOutlet UILabel *trackTitleLabel; // The Title Label
@property (weak, nonatomic) IBOutlet UILabel *artistAndAlbumLabel; // combined artist and album Label
@property (weak, nonatomic) IBOutlet UIButton *previousButton; // Previous Track
@property (weak, nonatomic) IBOutlet UIButton *nextButton; // Next Track
@property (weak, nonatomic) IBOutlet UIButton *playButton; // Play
@property (weak, nonatomic) IBOutlet UIImageView *albumArtImageView; // Album Art Image View
@property (weak, nonatomic) IBOutlet UILabel *timeElapsedLabel; // Elapsed Time Label
@property (weak, nonatomic) IBOutlet UILabel *timeRemainingLabel; // Remaining Time Label
@property (weak, nonatomic) IBOutlet UIView *controlView;
@property (strong, nonatomic) PVPlaybackViewModel *viewModel;
@end

@implementation PVPlaybackViewController

#pragma mark - Life Cycle
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // set up our view model once the view loads
    [self configureViewModel];
    
    // set up our UI
    [self configureUI];
    
    // attach our observers; this must happen after we create our
    // view model to ensure properties are available for observing
    [self configureRACObservers];
}

- (void)configureUI
{
    self.view.backgroundColor = kMedGray;
    
    // Progess Slider
    UIImage *knob = [UIImage imageNamed:@"PVPlaybackController.bundle/images/VolumeKnob"];
    [self.progressSlider setThumbImage:knob forState:UIControlStateNormal];
    self.progressSlider.maximumTrackTintColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:1];
}

- (void)configureViewModel
{
    _viewModel = [[PVPlaybackViewModel alloc] init];
    _viewModel.albumArtSize = self.albumArtImageView.frame.size;
    _viewModel.active = YES;
}

#pragma mark - Playback Management
- (void)configureRACObservers
{
    @weakify(self);
    // go ahead and load our two button images into memory
    // as we'll set our play button based on playing status
    UIImage *playImage = [UIImage imageNamed:@"playButton"];
    UIImage *pauseImage = [UIImage imageNamed:@"pauseButton"];
    
    // track info labels
    RAC(self.trackTitleLabel, text) = [RACObserve(self.viewModel, trackTitle) deliverOn:RACScheduler.mainThreadScheduler];
    RAC(self.artistAndAlbumLabel, text) = [RACObserve(self.viewModel, trackAlbumAndArtist) deliverOn:RACScheduler.mainThreadScheduler];
    
    // track progress slider
    RAC(self.progressSlider, maximumValue) = [RACObserve(self.viewModel, trackLength) deliverOn:RACScheduler.mainThreadScheduler];
    RAC(self.progressSlider, value) = [RACObserve(self.viewModel, currentPlaybackPosition) deliverOn:RACScheduler.mainThreadScheduler];
    
    // track progress labels; updated on timer at 1-second intervals
    [RACObserve(self.viewModel, currentPlaybackPosition) subscribeNext:^(id x) {
        @strongify(self);
        self.timeElapsedLabel.text = [NSDateFormatter formattedDuration:(long)self.viewModel.currentPlaybackPosition];
        self.timeRemainingLabel.text = [NSDateFormatter formattedDuration:([self.viewModel trackLength] - self.viewModel.currentPlaybackPosition) * -1];
    }];
    
    // button controls; enabled only if we can go forward/backward
    RAC(self.nextButton, enabled) = self.viewModel.nextButtonEnabledSignal;
    RAC(self.previousButton, enabled) = self.viewModel.previousButtonEnabledSignal;
    
    // play button image; update it anytime we hit play/pause
    RAC(self.playButton.imageView, image) = [[[RACObserve(self.viewModel, playing) throttle:0.1]
                                              map:^id(id isPlaying) {
                                                  return [isPlaying boolValue] ? pauseImage : playImage;
                                              }] deliverOn:RACScheduler.mainThreadScheduler];
    
    // dynamic album art background; updated anytime we change tracks
    RAC(self.albumArtImageView, image) = [RACObserve(self.viewModel, albumArt) deliverOn:RACScheduler.mainThreadScheduler];
}

#pragma mark - User Interface Actions
- (IBAction)playAction:(id)sender
{
    [self.viewModel shouldPlayOrPauseTrack];
}

- (IBAction)nextAction:(id)sender
{
    [self.viewModel goToNextTrack];
}

- (IBAction)previousAction:(id)sender
{
    [self.viewModel goToPreviousTrack];
}

#pragma mark - scrubbing slider
- (IBAction)sliderDidBeginScrubbing:(id)sender
{
    self.viewModel.scrobbling = YES;
}

- (IBAction)sliderDidEndScrubbing:(id)sender
{
    self.viewModel.scrobbling = NO;
}

- (IBAction)sliderValueChanged:(id)slider
{
    self.viewModel.currentPlaybackPosition = self.progressSlider.value;
    [self.viewModel didSeekToPosition:self.viewModel.currentPlaybackPosition];
}

@end
