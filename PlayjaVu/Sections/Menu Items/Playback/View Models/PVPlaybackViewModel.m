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
@end

@implementation PVPlaybackViewModel

#pragma mark - Life Cycle
- (id)init
{
    self = [super init];
    if (self) {
        // This HACK hides the volume overlay when changing the volume.
        // It's insipired by http://stackoverflow.com/questions/3845222/iphone-sdk-how-to-disable-the-volume-indicator-view-if-the-hardware-buttons-ar
        _view = [MPVolumeView new];
        // Put it far offscreen
        _view.frame = CGRectMake(1000, 1000, 120, 12);
        
        [[UIApplication sharedApplication].keyWindow addSubview:_view];
        
        _musicPlayer = [MPMusicPlayerController systemMusicPlayer];
        
        MPMediaQuery *mq = [MPMediaQuery songsQuery];
        [MPMusicPlayerController.systemMusicPlayer setQueueWithQuery:mq];
        _mediaItems = mq.items;
        _musicPlayer.nowPlayingItem = _mediaItems[0];
    }
    
    return self;
}

#pragma mark - Private Methods
- (void)handleVolumeDidChangeNotification
{
//    self.controller.volume = self.musicPlayer.volume;
}

- (void)setMusicPlayer:(MPMusicPlayerController *)value
{
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    
    [nc removeObserver:self name:MPMusicPlayerControllerNowPlayingItemDidChangeNotification object:self.musicPlayer];
    [nc removeObserver:self name:MPMusicPlayerControllerPlaybackStateDidChangeNotification object:self.musicPlayer];
    [nc removeObserver:self name:MPMusicPlayerControllerVolumeDidChangeNotification object:self.musicPlayer];
    [self.musicPlayer endGeneratingPlaybackNotifications];
    
    self.musicPlayer = value;
    
    [nc addObserver: self
           selector: @selector (propagateMusicPlayerState)
               name: MPMusicPlayerControllerNowPlayingItemDidChangeNotification
             object: self.musicPlayer];
    [nc addObserver: self
           selector: @selector (propagateMusicPlayerState)
               name: MPMusicPlayerControllerPlaybackStateDidChangeNotification
             object: self.musicPlayer];
    [nc addObserver: self
           selector: @selector (handleVolumeDidChangeNotification)
               name: MPMusicPlayerControllerVolumeDidChangeNotification
             object: self.musicPlayer];
    
    [self.musicPlayer beginGeneratingPlaybackNotifications];
    
    [self propagateMusicPlayerState];
}

- (void)setMediaItems:(NSArray *)value
{
    self.mediaItems = [value copy];
//    [self.controller reloadData];
}

- (MPMediaItem *)mediaItemAtIndex:(NSUInteger)index
{
    if(self.mediaItems == nil || self.mediaItems.count == 0)
        return self.musicPlayer.nowPlayingItem;
    else
        return [self.mediaItems objectAtIndex:index];
}

- (void)dealloc
{
    // explicit call of setters with nil to deregister from objects
    self.musicPlayer = nil;
//    self.controller = nil;
}

#pragma mark - Public Methods
#pragma mark - Data
- (void)propagateMusicPlayerState
{
//    if(self.controller && self.musicPlayer) {
//        self.controller.delegate = nil;
//        
//        // refactor: playing property in musicplayer? and/or setter method differently
//        [self.controller playTrack:self.musicPlayer.indexOfNowPlayingItem atPosition:self.musicPlayer.currentPlaybackTime volume:self.musicPlayer.volume];
//        if(self.musicPlayer.playbackState == MPMusicPlaybackStatePlaying) {
//            [self.controller play];
//        } else {
//            [self.controller pause];
//        }
//        
//        self.controller.delegate = self;
//    }
}

- (NSString *)albumForTrack:(NSUInteger)trackNumber
{
    MPMediaItem *item = [self mediaItemAtIndex:trackNumber];
    return [item valueForProperty:MPMediaItemPropertyAlbumTitle];
}

- (NSString *)artistForTrack:(NSUInteger)trackNumber
{
    MPMediaItem *item = [self mediaItemAtIndex:trackNumber];
    return [item valueForProperty:MPMediaItemPropertyArtist];
}

- (NSString *)titleForTrack:(NSUInteger)trackNumber
{
    MPMediaItem *item = [self mediaItemAtIndex:trackNumber];
    return [item valueForProperty:MPMediaItemPropertyTitle];
}

- (CGFloat)lengthForTrack:(NSUInteger)trackNumber
{
    MPMediaItem *item = [self mediaItemAtIndex:trackNumber];
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

- (void)artworkForTrack:(NSUInteger)trackNumber receivingBlock:(void (^)(UIImage *image, NSError **error))receivingBlock
{
    DLogPurple(@"");
    
    MPMediaItem *item = [self mediaItemAtIndex:trackNumber];
    MPMediaItemArtwork *artwork = [item valueForProperty:MPMediaItemPropertyArtwork];
//    if (artwork) {
//        UIImage *foo = [artwork imageWithSize:player.preferredSizeForCoverArt];
//        receivingBlock(foo, nil);
//    } else {
//        receivingBlock(nil,nil);
//    }
}

#pragma mark Delegate-like
- (void)startPlaying
{
    DLogPurple(@"");
    [self.musicPlayer play];
}

- (BOOL)shouldStartPlaying
{
    DLogPurple(@"");
    return YES;
}

- (void)stopPlaying
{
    DLogPurple(@"");
    [self.musicPlayer pause];
}

- (void)didStopPlayingLastTrack
{
    DLogPurple(@"");
}

- (BOOL)shouldStopPlaying
{
    DLogPurple(@"");
    return YES;
}

- (void)didSeekToPosition:(CGFloat)position
{
    DLogPurple(@"");
    [self.musicPlayer setCurrentPlaybackTime:position];
}

- (BOOL)shouldChangeTrack:(NSUInteger)track
{
    DLogPurple(@"");
    return YES;
}

- (NSInteger)didChangeTrack:(NSUInteger)track
{
    if (self.mediaItems) {
        [self.musicPlayer setNowPlayingItem:[self mediaItemAtIndex:track]];
    } else {
        DLogPurple(@"");
        NSInteger delta = track - self.musicPlayer.indexOfNowPlayingItem;
        if(delta > 0)
            [self.musicPlayer skipToNextItem];
        if(delta == 0)
            [self.musicPlayer skipToBeginning];
        if(delta < 0)
            [self.musicPlayer skipToPreviousItem];
    }
    return self.musicPlayer.indexOfNowPlayingItem;
}

- (void)didChangeVolume:(CGFloat)volume
{
    DLogPurple(@"");
    [self.musicPlayer setVolume:volume];
}

- (void)didChangeShuffleState:(BOOL)shuffling
{
    DLogPurple(@"");
}

- (void)didChangeRepeatMode:(MPMusicRepeatMode)repeatMode
{
    DLogPurple(@"");
}

@end
