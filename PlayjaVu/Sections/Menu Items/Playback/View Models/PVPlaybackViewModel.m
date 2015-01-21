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
@property (strong, nonatomic, readwrite) RACSignal *updatePlaybackUISignal;
@property (strong, nonatomic, readwrite) RACSignal *playSignal;
@end

@implementation PVPlaybackViewModel

#pragma mark - Life Cycle
- (id)init
{
    self = [super init];
    if (self) {
        _updatePlaybackUISignal = [[RACSubject subject] setNameWithFormat:@"PVPlaybackViewModel updatePlaybackUISignal"];
        _playSignal = [[RACSubject subject] setNameWithFormat:@"PVPlaybackViewModel playSignal"];
        
        // This HACK hides the volume overlay when changing the volume.
        // It's insipired by http://stackoverflow.com/questions/3845222/iphone-sdk-how-to-disable-the-volume-indicator-view-if-the-hardware-buttons-ar
        _volumeView = [MPVolumeView new];
        // Put it far offscreen
        _volumeView.frame = CGRectMake(1000, 1000, 120, 12);
        
        [[UIApplication sharedApplication].keyWindow addSubview:_volumeView];
        
        _musicPlayer = [MPMusicPlayerController systemMusicPlayer];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
//            [nc addObserver:self
//                   selector:@selector(propagateMusicPlayerState:)
//                       name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification
//                     object:self.musicPlayer];
            [nc addObserver:self
                   selector:@selector(propagateMusicPlayerState:)
                       name:MPMusicPlayerControllerPlaybackStateDidChangeNotification
                     object:self.musicPlayer];
            
            [_musicPlayer beginGeneratingPlaybackNotifications];
            
            MPMediaQuery *mq = [MPMediaQuery songsQuery];
            _mediaItems = [mq.items copy];
            
            // update our UI once everything is set up properly
            [[self didBecomeActiveSignal] subscribeNext:^(id x) {
                [self propagateMusicPlayerState:nil];
            }];
        });
    }
    
    return self;
}

#pragma mark - Private Methods
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

- (NSString *)trackAlbum
{
    MPMediaItem *item = self.musicPlayer.nowPlayingItem;
    return [item valueForProperty:MPMediaItemPropertyAlbumTitle];
}

- (NSString *)trackArtist
{
    MPMediaItem *item = self.musicPlayer.nowPlayingItem;
    return [item valueForProperty:MPMediaItemPropertyArtist];
}

- (NSString *)trackTitle
{
    MPMediaItem *item = self.musicPlayer.nowPlayingItem;
    return [item valueForProperty:MPMediaItemPropertyTitle];
}

- (CGFloat)trackLength
{
    MPMediaItem *item = self.musicPlayer.nowPlayingItem;
    return [[item valueForProperty:MPMediaItemPropertyPlaybackDuration] longValue];
}

- (NSInteger)numberOfTracks
{
    return self.mediaItems ? self.mediaItems.count : -1;
}

- (BOOL)tracksAreAvailable
{
    return self.numberOfTracks >= 0;
}

- (void)artworkForCurrentTrackWithCompletion:(void (^)(MPMediaItemArtwork *mediaArt, NSError **error))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        MPMediaItem *item = self.musicPlayer.nowPlayingItem;
        MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
        completion(artwork, nil);
    });
}

#pragma mark Delegate-like
- (void)startPlaying
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.musicPlayer play];
    });
}

- (void)stopPlaying
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.musicPlayer pause];
    });
}

- (void)didSeekToPosition:(CGFloat)position
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self.musicPlayer setCurrentPlaybackTime:position];
    });
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

@end
