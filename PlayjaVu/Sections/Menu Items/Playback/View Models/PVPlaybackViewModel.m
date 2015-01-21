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
@property (copy, nonatomic, readwrite) NSString *trackTitle;
@property (copy, nonatomic, readwrite) NSString *trackArtist;
@property (copy, nonatomic, readwrite) NSString *trackAlbum;
@property (assign, nonatomic, readwrite) CGFloat trackLength;
@property (strong, nonatomic, readwrite) RACSignal *updatePlaybackUISignal;
@property (strong, nonatomic, readwrite) RACSignal *playSignal;
@property (strong, nonatomic, readwrite) RACSignal *nextButtonEnabledSignal;
@property (strong, nonatomic, readwrite) RACSignal *previousButtonEnabledSignal;
@property (strong, nonatomic, readwrite) dispatch_queue_t userInteractiveQueue;
@property (strong, nonatomic, readwrite) dispatch_queue_t userInitiatedQueue;
@property (strong, nonatomic, readwrite) dispatch_queue_t utilityQueue;
@property (strong, nonatomic, readwrite) dispatch_queue_t backgroundQueue;
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
        
        _updatePlaybackUISignal = [[RACSubject subject] setNameWithFormat:@"PVPlaybackViewModel updatePlaybackUISignal"];
        _playSignal = [[RACSubject subject] setNameWithFormat:@"PVPlaybackViewModel playSignal"];
        
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

#pragma mark - Private Methods
- (void)configureRACObservers
{
    @weakify(self);
    [RACObserve(self.musicPlayer, nowPlayingItem) subscribeNext:^(id x) {
        @strongify(self);
        self.trackTitle = [self valueForMediaItemProperty:MPMediaItemPropertyTitle];
        self.trackArtist = [self valueForMediaItemProperty:MPMediaItemPropertyArtist];
        self.trackAlbum = [self valueForMediaItemProperty:MPMediaItemPropertyAlbumTitle];
        self.trackLength = [[self valueForMediaItemProperty:MPMediaItemPropertyPlaybackDuration] longValue];
    }];
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self.musicPlayer endGeneratingPlaybackNotifications];
    self.musicPlayer = nil;
}

#pragma mark - Public Methods
#pragma mark - Data
- (void)propagateMusicPlayerState:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    
    if (userInfo[@"MPMusicPlayerControllerPlaybackStateKey"]) {
        MPMusicPlaybackState playbackState = (MPMusicPlaybackState)[userInfo[@"MPMusicPlayerControllerPlaybackStateKey"] integerValue];
        
        if (self.musicPlayer) {
            // tell our player UI to update itself with our new data
            self.currentPlaybackPosition = self.musicPlayer.currentPlaybackTime;
            // make sure we keep track of our currently playing track's index
            self.currentTrack = self.musicPlayer.indexOfNowPlayingItem;
            
            switch (playbackState) {
                case MPMusicPlaybackStateStopped: {
                    DLogOrange(@"MPMusicPlaybackStateStopped");
                    return;
                }
                case MPMusicPlaybackStatePlaying: {
                    DLogOrange(@"MPMusicPlaybackStatePlaying");
                    [(RACSubject *)self.playSignal sendNext:nil];
                    break;
                }
                case MPMusicPlaybackStatePaused: {
                    DLogOrange(@"MPMusicPlaybackStatePaused");
                    return;
                }
                case MPMusicPlaybackStateInterrupted:
                    DLogOrange(@"MPMusicPlaybackStateInterrupted");
                    break;
                case MPMusicPlaybackStateSeekingForward:
                    DLogOrange(@"MPMusicPlaybackStateSeekingForward");
                    break;
                case MPMusicPlaybackStateSeekingBackward:
                    DLogOrange(@"MPMusicPlaybackStateSeekingBackward");
                    break;
                default:
                    break;
            }
            
            [(RACSubject *)self.updatePlaybackUISignal sendNext:@(self.musicPlayer.indexOfNowPlayingItem)];
        }
    }
}

- (id)valueForMediaItemProperty:(NSString *)property// completion:(void(^)(id value))completion
{
    __block id newValue;
    
//    dispatch_async(self.userInitiatedQueue, ^{
        MPMediaItem *item = self.musicPlayer.nowPlayingItem;
        newValue = [item valueForProperty:property];
//    });
    
    DLogOrange(@"newValue: %@", newValue);
    
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

#warning I THINK THIS CAN BE RAC OBSERVED TOO
- (void)artworkForCurrentTrackWithCompletion:(void (^)(MPMediaItemArtwork *mediaArt, NSError **error))completion
{
//    dispatch_async(self.utilityQueue, ^{
        MPMediaItem *item = self.musicPlayer.nowPlayingItem;
        MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
        completion(artwork, nil);
//    });
}

#pragma mark Delegate-like
- (void)startPlaying
{
//    dispatch_async(self.userInitiatedQueue, ^{
        [self.musicPlayer play];
//    });
}

- (void)stopPlaying
{
//    dispatch_async(self.userInitiatedQueue, ^{
        [self.musicPlayer pause];
//    });
}

- (void)didSeekToPosition:(CGFloat)position
{
//    dispatch_async(self.userInitiatedQueue, ^{
        [self.musicPlayer setCurrentPlaybackTime:position];
//    });
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

- (void)didChangeShuffleState:(BOOL)shuffling
{
    DLogYellow(@"");
}

- (void)didChangeRepeatMode:(MPMusicRepeatMode)repeatMode
{
    DLogYellow(@"");
}

- (RACSignal *)nextButtonEnabledSignal
{
    if (!_nextButtonEnabledSignal) {
        @weakify(self);
        
#warning this isn't firing on every item switch
        _nextButtonEnabledSignal = [RACSignal combineLatest:@[RACObserve(self.musicPlayer, nowPlayingItem)] reduce:^id{
            @strongify(self);
            BOOL enabled = YES;
            
            if (self.tracksAreAvailable && self.currentTrack + 1 == self.numberOfTracks) {
                enabled = NO;
            }
            
            DLogCyan(@"next enabled: %i", enabled);
            return @(enabled);
        }];
    }
    return _nextButtonEnabledSignal;
}

- (RACSignal *)previousButtonEnabledSignal
{
    if (!_previousButtonEnabledSignal) {
        @weakify(self);
        
#warning this isn't firing on every item switch
        _previousButtonEnabledSignal = [[RACSignal combineLatest:@[RACObserve(self.musicPlayer, nowPlayingItem)]] map:^(id x) {
            @strongify(self);
            BOOL enabled = YES;
            
            if (self.tracksAreAvailable && self.currentTrack == 0) {
                enabled = NO;
            }
            
            DLogCyan(@"previous enabled: %i", enabled);
            return @(enabled);
        }];
    }
    return _previousButtonEnabledSignal;
}

@end
