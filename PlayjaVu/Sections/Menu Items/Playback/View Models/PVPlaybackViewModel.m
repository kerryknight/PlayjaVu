//
//  PVPlaybackViewModel.m
//  PlayjaVu
//
//  Created by Kerry Knight on 1/7/15.
//  Copyright (c) 2015 Kerry Knight. All rights reserved.
//

#import "PVPlaybackViewModel.h"

@interface PVPlaybackViewModel()
@property (strong, nonatomic) MPMusicPlayerController *musicPlayer; // An instance of an itunes music player
@property (copy, nonatomic) NSArray *mediaItems;
@property (nonatomic, strong) NSTimer *playbackTickTimer; // Ticks each seconds when playing.
@property (assign, nonatomic) NSInteger currentTrackIndex;
@property (copy, nonatomic, readwrite) NSString *currentTrackId;
@property (copy, nonatomic, readwrite) NSString *trackTitle;
@property (copy, nonatomic, readwrite) NSString *trackAlbumAndArtist;
@property (assign, nonatomic, readwrite) CGFloat trackLength;
@property (strong, nonatomic, readwrite) RACSignal *nextButtonEnabledSignal;
@property (strong, nonatomic, readwrite) RACSignal *previousButtonEnabledSignal;
@property (strong, nonatomic, readwrite) dispatch_queue_t userInteractiveQueue;
@property (strong, nonatomic, readwrite) dispatch_queue_t userInitiatedQueue;
@property (strong, nonatomic, readwrite) dispatch_queue_t utilityQueue;
@property (strong, nonatomic, readwrite) dispatch_queue_t backgroundQueue;
@property (strong, nonatomic, readwrite) UIImage *albumArt;
@end

@implementation PVPlaybackViewModel

#pragma mark - Life Cycle
- (id)init
{
    self = [super init];
    if (self) {
        
        _userInteractiveQueue = dispatch_get_global_queue(QOS_CLASS_USER_INTERACTIVE, 0);
        _userInitiatedQueue = dispatch_get_global_queue(QOS_CLASS_USER_INITIATED, 0);
        _utilityQueue = dispatch_get_global_queue(QOS_CLASS_UTILITY, 0);
        _backgroundQueue = dispatch_get_global_queue(QOS_CLASS_BACKGROUND, 0);
        
        // This HACK hides the volume overlay when changing the volume.
        // It's insipired by http://stackoverflow.com/questions/3845222/iphone-sdk-how-to-disable-the-volume-indicator-view-if-the-hardware-buttons-ar
        _volumeView = [MPVolumeView new];
        // Put it far offscreen
        _volumeView.frame = CGRectMake(1000, 1000, 120, 12);
        
        [[UIApplication sharedApplication].keyWindow addSubview:_volumeView];
        
        _musicPlayer = [MPMusicPlayerController systemMusicPlayer];
        
        [self configureRACObservers];
        
        NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];

        [nc addObserver:self
               selector:@selector(didChangeNowPlaying:)
                   name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                 object:self.musicPlayer];
        
        [nc addObserver:self
               selector:@selector(propagateMusicPlayerState:)
                   name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                   // name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
                 object:self.musicPlayer];
        
        MPMediaQuery *mq = [MPMediaQuery songsQuery];
        _mediaItems = [mq.items copy];
        
        // update our UI once everything is set up properly
        [[self didBecomeActiveSignal] subscribeNext:^(id x) {
            // start listening for playback notifications
            [_musicPlayer beginGeneratingPlaybackNotifications];
        }];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.musicPlayer endGeneratingPlaybackNotifications];
    self.musicPlayer = nil;
}

#pragma mark - Public Methods
- (void)shouldPlayOrPauseTrack
{
    if (self.playing) {
        // pause track
        os_activity_initiate("Pause Track", OS_ACTIVITY_FLAG_DETACHED, ^{
            [self pauseTrack];
        });
    }
    else {
        os_activity_initiate("Play Track", OS_ACTIVITY_FLAG_DETACHED, ^{
            // start playing new
            [self playTrack];
        });
    }
}

- (void)goToNextTrack
{
    os_activity_initiate("Next Track", OS_ACTIVITY_FLAG_DETACHED, ^{
        [self changeToTrack:self.currentTrackIndex + 1];
    });
}

- (void)goToPreviousTrack
{
    DLogPurple(@"");
    os_activity_initiate("Previous Track", OS_ACTIVITY_FLAG_DETACHED, ^{
        // only skip backwards if we're less than 2 seconds from the start of the song;
        // otherwise, simply skip back to the start of the song
        NSInteger numberOfTracksToMove = self.currentPlaybackPosition <= 2 ? 1 : 0;
        [self changeToTrack:self.currentTrackIndex - numberOfTracksToMove];
    });
}

#pragma mark - Private Methods
- (void)playTrack
{
    [self.musicPlayer play];
}

- (void)pauseTrack
{
    [self.musicPlayer pause];
}

- (void)stopTrack
{
    [self.musicPlayer stop];
}

- (void)shouldStartPlayTimer:(BOOL)start
{
    self.playing = start;
    start ? [self startTimer] : [self stopTimer];
}

- (void)configureRACObservers
{
    @weakify(self);
    // throttle our signal as paused/next notifications happen together
    // and we set our
    [RACObserve(self, currentTrackId) subscribeNext:^(id x) {
        @strongify(self);
        // anytime self.currentTrack changes, update the following properties
        self.trackTitle = [self valueForMediaItemProperty:MPMediaItemPropertyTitle];
        self.trackLength = [[self valueForMediaItemProperty:MPMediaItemPropertyPlaybackDuration] longValue];
        
        // combine artist and album into a single row like native Music app
        NSString *trackArtist = [self valueForMediaItemProperty:MPMediaItemPropertyArtist] ?: @"";
        NSString *trackAlbum = [self valueForMediaItemProperty:MPMediaItemPropertyAlbumTitle] ?: @"";
        self.trackAlbumAndArtist = [NSString stringWithFormat:@"%@ - %@", trackArtist, trackAlbum];
        
        // no hyphen if we don't have both items populated
        if (!trackArtist.length && trackAlbum.length) {
            self.trackAlbumAndArtist = [NSString stringWithFormat:@"%@", trackAlbum];
        }
        else if (trackArtist.length && !trackAlbum.length) {
            self.trackAlbumAndArtist = [NSString stringWithFormat:@"%@", trackArtist];
        }
        else if (!trackArtist.length && !trackAlbum.length) {
            self.trackAlbumAndArtist = @"";
        }
        
        BOOL previousEnabled = YES;
        BOOL nextEnabled = YES;
        
        // determine previous button's status
        if (self.tracksAreAvailable && self.currentTrackIndex == 0) {
            previousEnabled = NO;
        }
        
        // determine next button's status
        if (self.tracksAreAvailable && self.currentTrackIndex + 1 == self.numberOfTracks) {
            nextEnabled = NO;
        }
        
        self.previousButtonEnabledSignal = [RACSignal return:@(previousEnabled)];
        self.nextButtonEnabledSignal = [RACSignal return:@(nextEnabled)];
        
        // update album art
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(clearAlbumArtImage) object:nil];
        [self performSelector:@selector(clearAlbumArtImage) withObject:nil afterDelay:0.5];
        
        // Copy the current track to another variable, otherwise we would just access the current one.
        NSUInteger track = self.currentTrackIndex;
        
        // Request the image.
        [self artworkForCurrentTrackWithCompletion:^(MPMediaItemArtwork *mediaArt) {
            os_activity_set_breadcrumb("updateUIForCurrentTrack:gotArtwork");
            
            if (track == self.currentTrackIndex) {
                
                // If there is no image given, stay with the placeholder
                if (mediaArt) {
                    UIImage *artwork = [mediaArt imageWithSize:self.preferredSizeForCoverArt];
                    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(clearAlbumArtImage) object:nil];
                    self.albumArt = artwork;
                }
                
            } else {
                DLog(@"Discarded CoverArt for track: %lu, current track already moved to %ld.", (unsigned long)track, (long)self.currentTrackIndex);
            }
        }];
    }];
}

- (CGSize)preferredSizeForCoverArt
{
    CGFloat scale = UIScreen.mainScreen.scale;
    CGSize points = self.albumArtSize;
    return  CGSizeMake(points.width * scale, points.height * scale);
}

- (void)startTimer
{
    [self.playbackTickTimer invalidate];
    self.playbackTickTimer = nil;
    self.playbackTickTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(playbackTick:) userInfo:nil repeats:YES];
    self.playbackTickTimer.tolerance = 1.0; // 1 second tolerance
}

- (void)stopTimer
{
    [self.playbackTickTimer invalidate];
    self.playbackTickTimer = nil;
}

- (void)didChangeNowPlaying:(NSNotification *)notification
{
    // this is called whenever we change tracks
    NSString *trackId = [NSString stringWithFormat:@"%@", [notification userInfo][@"MPMusicPlayerControllerNowPlayingItemPersistentIDKey"]];
    
    // only update everything if it's different
    if (trackId) {
        // check if we even have a currentTrackId (we won't if view just loaded)
        if (!self.currentTrackId || ![trackId isEqualToString:self.currentTrackId]) {
            self.currentTrackId = trackId;
        }
    }
}

- (void)clearAlbumArtImage
{
    self.albumArt = nil;
}

- (void)propagateMusicPlayerState:(NSNotification *)notification
{
    // this is called whenever we change playback of current track
    NSDictionary *userInfo = [notification userInfo];
    
    if (userInfo[@"MPMusicPlayerControllerPlaybackStateKey"]) {
        MPMusicPlaybackState playbackState = (MPMusicPlaybackState)[userInfo[@"MPMusicPlayerControllerPlaybackStateKey"] integerValue];
        
        if (self.musicPlayer) {
            
            // tell our player UI to update itself with our new data
            self.currentPlaybackPosition = self.musicPlayer.currentPlaybackTime;
            // make sure we keep track of our currently playing track's index
            self.currentTrackIndex = self.musicPlayer.indexOfNowPlayingItem;
            
            switch (playbackState) {
                case MPMusicPlaybackStateStopped: {
                    DLogOrange(@"MPMusicPlaybackStateStopped");
                    [self shouldStartPlayTimer:NO];
                    return;
                }
                case MPMusicPlaybackStatePlaying: {
                    [self shouldStartPlayTimer:YES];
                    break;
                }
                case MPMusicPlaybackStatePaused: {
                    [self shouldStartPlayTimer:NO];
                    return;
                }
                case MPMusicPlaybackStateInterrupted:
                    DLogOrange(@"MPMusicPlaybackStateInterrupted");
                    [self shouldStartPlayTimer:NO];
                    break;
                case MPMusicPlaybackStateSeekingForward:
                case MPMusicPlaybackStateSeekingBackward:
                default:
                    NSAssert(FALSE, @"Conditional error; these shouldn't happen.");
                    break;
            }
        }
    }
}

- (id)valueForMediaItemProperty:(NSString *)property
{
    __block id newValue;
    
    MPMediaItem *item = self.musicPlayer.nowPlayingItem;
    newValue = [item valueForProperty:property];
    
    return newValue;
}

- (NSInteger)numberOfTracks
{
    return self.mediaItems ? self.mediaItems.count : -1;
}

- (BOOL)tracksAreAvailable
{
    return self.numberOfTracks >= 0;
}

- (void)artworkForCurrentTrackWithCompletion:(void (^)(MPMediaItemArtwork *mediaArt))completion
{
    // make this an async request with callback as there's potential
    // we could move to the next track prior to retrieving the image
    MPMediaItem *item = self.musicPlayer.nowPlayingItem;
    MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
    completion(artwork);
}

- (void)currentTrackFinished
{
    if (self.musicPlayer.repeatMode != MPMusicRepeatModeOne) {
        [self goToNextTrack];
    }
    else {
        self.currentPlaybackPosition = 0;
    }
}

/**
 * Tick method called each second when playing back.
 */
- (void)playbackTick:(id)unused
{
    // Only tick forward if not scrobbling.
    if (!self.scrobbling) {
        if (self.currentPlaybackPosition + 1.0 > self.trackLength) {
            [self currentTrackFinished];
        }
        else {
            self.currentPlaybackPosition += 1.0f;
        }
    }
}

#pragma mark Delegate-like
- (void)didSeekToPosition:(CGFloat)position
{
    [self.musicPlayer setCurrentPlaybackTime:position];
}

- (void)changeToTrack:(NSInteger)track
{
    os_activity_set_breadcrumb("changeToTrack:");
    __block NSInteger newTrack = track;
    
    BOOL shouldChange = YES;
    
    if (newTrack < 0 || (self.tracksAreAvailable && newTrack >= self.numberOfTracks)) {
        shouldChange = NO;
        os_activity_set_breadcrumb("changeToTrack:paused");
        // If we can't next, stop the playback.
        // TODO: we fell off the playlist
        [self pauseTrack];
    }
    
    if (shouldChange) {
        newTrack = [self didChangeTrack:newTrack];
        
        if (newTrack == NSNotFound) {
            os_activity_set_breadcrumb("changeToTrack:newTrack:NotFound");
            // TODO: we fell off the playlist
            [self pauseTrack];
        }
        else {
            os_activity_set_breadcrumb("changeToTrack:newTrack:Found");
            self.currentPlaybackPosition = 0;
            self.currentTrackIndex = newTrack;
        }
    }
}

- (NSInteger)didChangeTrack:(NSUInteger)track
{
    NSInteger delta = track - self.musicPlayer.indexOfNowPlayingItem;
    
    if (delta > 0) {
        [self.musicPlayer skipToNextItem];
    }
    else if (delta == 0) {
        [self.musicPlayer skipToBeginning];
    }
    else if (delta < 0) {
        [self.musicPlayer skipToPreviousItem];
    }
    
    return self.musicPlayer.indexOfNowPlayingItem;
}

@end
