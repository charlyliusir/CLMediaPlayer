//
//  CLMediaPlayerManager.m
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/19.
//  Copyright © 2018年 charly. All rights reserved.
//

#import "CLMediaPlayerManager.h"
#import "CLMediaPlayer.h"
#import "NSObject+CLEmpty.h"
#import "CLMediaPlayerUtils.h"

@interface CLMediaPlayerManager() <CLMediaPlayerDelegate>

@property (nonatomic, readwrite, strong, nullable) CLMediaPlayer *videoPlayer;

@end

@implementation CLMediaPlayerManager

- (instancetype)init
{
    if (self = [super init]) {
        [self initilitation];
        self.videoPlayer = [[CLMediaPlayer alloc] init];
        self.videoPlayer.delegate = self;
    }
    return self;
}

- (void)initilitation
{
    
}

- (void)playVideoWithUrl:(NSString *)videoUrl
                 options:(CLMediaPlayerOptions)options
             onShowLayer:(CALayer *)showLayer
 configurationCompletion:(CLMediaPlayerConfigurationCompletion)completion
{
    
    if ([NSObject stringIsEmpty:videoUrl] || !showLayer) {
        return;
    }
    NSURL *url = nil;
    if ((url = [NSURL URLWithString:videoUrl]) && url == nil) {
        return;
    }
    
    [_videoPlayer playWithVideoUrl:videoUrl
                           options:options
                         showLayer:showLayer
                        completion:completion];
}

#pragma mark - CLMediaPlayerProtocol
- (float)rate
{
    return self.videoPlayer.rate;
}

- (void)setRate:(float)rate
{
    self.videoPlayer.rate = rate;
}

- (BOOL)muted
{
    return self.videoPlayer.muted;
}

- (void)setMuted:(BOOL)muted
{
    self.videoPlayer.muted = muted;
}

- (float)volume
{
    return self.videoPlayer.volume;
}

- (void)setVolume:(float)volume
{
    self.videoPlayer.volume = volume;
}

- (CMTime)currentTime
{
    return self.videoPlayer.currentTime;
}

- (NSTimeInterval)loadedSeconds
{
    return self.videoPlayer.loadedSeconds;
}

- (NSTimeInterval)elapsedSeconds
{
    return self.videoPlayer.elapsedSeconds;
}

- (NSTimeInterval)totalSeconds
{
    return self.videoPlayer.totalSeconds;
}

- (void)resume
{
    [self.videoPlayer resume];
}

- (void)pause
{
    [self.videoPlayer pause];
}

- (void)seekToTime:(CMTime)time {
    [self.videoPlayer seekToTime:time];
}


- (void)stopPlay {
    [self initilitation];
    [self.videoPlayer stopPlay];
}

#pragma mark - CLMediaPlayerDelegate
/**
 * 视频是否需要重新播放
 *
 * @param player    播放器
 * @param videoUrl  当前播放视频的链接
 * @return 是否需要重新播放
 */
- (BOOL)mediaPlayer:(CLMediaPlayer *)player shouldAutoReplayVideoWithUrl:(NSURL *)videoUrl
{
    return _isRunLoop;
}

/**
 * 播放器播放状态发生改变
 *
 * @param player 播放器
 * @param status 当前状态
 */
- (void)mediaPlayer:(CLMediaPlayer *)player didChangePlayStatus:(CLMediaPlayerStatus)status
{
    NSLog(@"%lu", (unsigned long)status);
}

/**
 * 视频播放进度发生变化
 *
 * @param player 播放器
 * @param elapsedSeconds 已播放时间
 * @param totalSeconds   视频总长度
 */
- (void)mediaPlayerWithPlayerProgressDidChange:(CLMediaPlayer *)player
                                elapsedSeconds:(NSTimeInterval)elapsedSeconds
                                  totalSeconds:(NSTimeInterval)totalSeconds
{
    NSLog(@"--- %.2f --- %.2f", elapsedSeconds, totalSeconds);
}

/**
 * 视频缓冲数据发生变化
 *
 * @param player 播放器
 * @param currentTime 当前播放时间
 * @param loadedTime  缓冲总时长
 */
- (void)mediaPlayerWithPlayerLoadedTimeDidChange:(CLMediaPlayer *)player
                                     currentTime:(NSTimeInterval)currentTime
                                      loadedTime:(NSTimeInterval)loadedTime
{
    NSLog(@"--- %.2f --- %.2f", currentTime, loadedTime);
}

@end
