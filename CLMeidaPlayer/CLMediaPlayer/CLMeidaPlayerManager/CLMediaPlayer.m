//
//  CLMediaPlayer.m
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/19.
//  Copyright © 2018年 charly. All rights reserved.
//

#import "CLMediaPlayer.h"
#import <AVFoundation/AVFoundation.h>
#import "NSObject+CLEmpty.h"
#import "CLMediaPlayerUtils.h"

static char * kCLPlayerItemStatusKey;
static char * kCLPlayerItemLoadedTimeRangesKey;
static char * kCLMediaPlayerRateKey;

@interface CLMediaPlayerModel ()

/**
 * 视频地址
 */
@property (nonatomic, strong, nullable) NSURL *url;

/**
 * 根据视频地址创建的AVURLAsset
 */
@property (nonatomic, strong, nullable) AVURLAsset *videoURLAsset;

/**
 * 视频播放的可选参数, 主要对视频播放的样式做操作
 */
@property (nonatomic, assign) CLMediaPlayerOptions options;

/**
 * 视频展示层
 */
@property (nonatomic, strong, nullable) CALayer *showLayer;

/**
 * 当前播放视频的图层.
 */
@property (nonatomic, readwrite, strong, nullable) AVPlayerLayer *playerLayer;

/**
 * 播放器.
 */
@property (nonatomic, readwrite, strong, nullable) AVPlayer *player;

/**
 * 当前播放资源
 */
@property (nonatomic, strong, nullable) AVPlayerItem *playerItem;


/**
 * 是否已经被销毁
 */
@property (nonatomic, assign, getter=isCancelled) BOOL cancelled;

/**
 * 视频播放进度的监听者
 */
@property (nonatomic, strong) id timeObserver;

@property (nonatomic, assign) NSTimeInterval lastTime;


/**
 * 当前播放器控制类
 */
@property (nonatomic, weak) CLMediaPlayer *videoPlayer;
@property (nonatomic, assign) NSTimeInterval totalSeconds;
@property (nonatomic, assign) NSTimeInterval elapsedSeconds;
@property (nonatomic, assign) NSTimeInterval loadedSeconds;

@end

@implementation CLMediaPlayerModel

- (float)rate
{
    return self.player.rate;
}

- (void)setRate:(float)rate
{
    self.player.rate = rate;
}

- (BOOL)muted
{
    return self.player.muted;
}

- (void)setMuted:(BOOL)muted
{
    self.player.muted = muted;
}

- (float)volume
{
    return self.player.volume;
}

- (void)setVolume:(float)volume
{
    self.player.volume = volume;
}

- (CMTime)currentTime
{
    return self.player.currentTime;
}

- (void)resume
{
    [self.player play];
}

- (void)pause
{
    [self.player pause];
}

- (void)seekToTime:(CMTime)time
{
    
}

- (void)stopPlay
{
    self.cancelled = YES;
    [self initilitation];
}

- (void)initilitation
{
    /** 1. 移除图层*/
    if (self.playerLayer.superlayer) {
        [self.playerLayer removeFromSuperlayer];
    }
    
    /** 2. 移除监听 */
    [self.playerItem removeObserver:self.videoPlayer forKeyPath:CLPlayerItemStatusName context:&kCLPlayerItemStatusKey];
    [self.playerItem removeObserver:self.videoPlayer forKeyPath:CLPlayerItemLoadedTimeRangesName context:&kCLPlayerItemLoadedTimeRangesKey];
    [self.player removeTimeObserver:self.timeObserver];
    [self.player removeObserver:self.videoPlayer forKeyPath:kCLMediaPlayerRateName context:&kCLMediaPlayerRateKey];
    
    /** 3. 移除播放器&设置 */
    [self.player pause];
    [self.player cancelPendingPrerolls];
    self.playerItem     = nil;
    self.player         = nil;
    self.playerLayer    = nil;
    self.elapsedSeconds = 0.0f;
    self.totalSeconds   = 0.0f;
    self.loadedSeconds  = 0.0f;
}

@end

@interface CLMediaPlayer()
/**
 * 视频播放状态
 */
@property (nonatomic, assign) CLMediaPlayerStatus playerStatus;

/**
 * 当前视频资源数据模型
 */
@property (nonatomic, strong, nullable) CLMediaPlayerModel *model;

/**
 * 视频唤醒计时器
 */
@property (nonatomic, strong, nullable) NSTimer *loadBufferingTimer;

@end

@implementation CLMediaPlayer

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (instancetype)init
{
    if (self = [super init]) {
        _playerStatus = CLMediaPlayerStatusUnkonw;
        [self addNotifications];
    }
    return self;
}

#pragma mark - paly method
- (CLMediaPlayerModel *)playWithVideoUrl:(NSString *)url
                 options:(CLMediaPlayerOptions)options
               showLayer:(CALayer *)showLayer
              completion:(CLMediaPlayerConfigurationCompletion)completion
{
    NSAssert(![NSObject stringIsEmpty:url], @"视频地址字符串不能为空！");
    NSAssert(showLayer, @"视频展示图层不能为空！");
    
    if ([NSObject stringIsEmpty:url] || showLayer == nil) {
        return nil;
    }
    
    NSURL *videoUrl = [NSObject urlWithString:url];
    
    if (!videoUrl) {
        CLErrorLog(@"视频地址读取不到, 请传入正确的视频地址");
        return nil;
    }
    
    // 移除上一次残留的视频模型
    if (self.model) {
        [self.model initilitation];
        self.model = nil;
    }
    
    AVURLAsset *videoAsset      = [AVURLAsset assetWithURL:videoUrl];
    AVPlayerItem *playerItem    = [AVPlayerItem playerItemWithAsset:videoAsset automaticallyLoadedAssetKeys:nil];
    CLMediaPlayerModel *model   = [self playModelWithUrl:videoUrl playerItem:playerItem options:options showLayer:showLayer];
    self.model = model;
    
    completion ? completion([UIView new], model) : nil;
    
    return model;
}

#pragma mark - private method
- (CLMediaPlayerModel *)playModelWithUrl:(NSURL *)url
                              playerItem:(AVPlayerItem *)playerItem
                                 options:(CLMediaPlayerOptions)options
                               showLayer:(CALayer *)showLayer
{
    CLMediaPlayerModel *model = [CLMediaPlayerModel new];
    model.url           = url;
    model.options       = options;
    model.playerItem    = playerItem;
    model.showLayer     = showLayer;
    
    [model.playerItem addObserver:self forKeyPath:CLPlayerItemStatusName options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&kCLPlayerItemStatusKey];
    [model.playerItem addObserver:self forKeyPath:CLPlayerItemLoadedTimeRangesName options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&kCLPlayerItemLoadedTimeRangesKey];
    
    model.player = [AVPlayer playerWithPlayerItem:model.playerItem];
    [model.player addObserver:self forKeyPath:kCLMediaPlayerRateName options:NSKeyValueObservingOptionNew | NSKeyValueObservingOptionOld context:&kCLMediaPlayerRateKey];
    if ([model.player respondsToSelector:@selector(automaticallyWaitsToMinimizeStalling)]) {
        /** 10.0 以后添加的属性, 防止播放卡死 */
        model.player.automaticallyWaitsToMinimizeStalling = NO;
    }
    
    model.playerLayer = [AVPlayerLayer playerLayerWithPlayer:model.player];
    [self setVideoGravityWithOptions:model.options withPlayerModel:model];
    
    model.videoPlayer = self;
    
    self.playerStatus = CLMediaPlayerStatusUnkonw;
    [self startCheckBufferingTimer];
    
    if (options & CLMediaPlayerMutedPlay) {
        self.model.muted = YES;
    }
    
    __weak typeof(model)weakModel = model;
    __weak typeof(self)weakSelf = self;
    [model.player addPeriodicTimeObserverForInterval:CMTimeMake(1.0, 1.0) queue:dispatch_get_main_queue() usingBlock:^(CMTime time) {
        __strong typeof(weakModel)strongModel = weakModel;
        __strong typeof(weakSelf)strongSelf = weakSelf;
        double elapsedSeconds = CMTimeGetSeconds(time);
        double totalSeconds   = CMTimeGetSeconds(strongModel.playerItem.duration);
        
        strongSelf.model.elapsedSeconds = elapsedSeconds;
        strongSelf.model.totalSeconds   = totalSeconds;
        
        if (totalSeconds == 0 || isnan(totalSeconds) || elapsedSeconds > totalSeconds) {
            return ;
        }
        
        if (strongSelf.delegate && [strongSelf.delegate respondsToSelector:@selector(mediaPlayerWithPlayerProgressDidChange:elapsedSeconds:totalSeconds:)]) {
            [strongSelf.delegate mediaPlayerWithPlayerProgressDidChange:strongSelf elapsedSeconds:elapsedSeconds totalSeconds:totalSeconds];
        }
        
    }];
    
    return model;
}

- (void)setVideoGravityWithOptions:(CLMediaPlayerOptions)options withPlayerModel:(CLMediaPlayerModel *)model
{
    AVLayerVideoGravity videoGravity = nil;
    
    if (options & CLMediaPlayerLayerVideoGravityResize) {
        videoGravity = AVLayerVideoGravityResize;
    }
    else if (options & CLMediaPlayerLayerVideoGravityResizeAspect) {
        videoGravity = AVLayerVideoGravityResizeAspect;
    }
    else if (options & CLMediaPlayerLayerVideoGravityResizeAspectFill) {
        videoGravity = AVLayerVideoGravityResizeAspectFill;
    }
    
    [model.playerLayer setVideoGravity:videoGravity];
}

#pragma mark - 缓冲
- (void)startCheckBufferingTimer
{
    [self endCheckBufferTimerIfNeed];
    
    _loadBufferingTimer = [NSTimer timerWithTimeInterval:0.5 target:self selector:@selector(checkBufferingTime:) userInfo:nil repeats:YES];
    [NSRunLoop.mainRunLoop addTimer:_loadBufferingTimer forMode:NSRunLoopCommonModes];
}

- (void)endCheckBufferTimerIfNeed
{
    if (_loadBufferingTimer) {
        [_loadBufferingTimer invalidate];
        _loadBufferingTimer = nil;
    }
}

- (void)checkBufferingTime:(id)sender
{
    NSTimeInterval time = CMTimeGetSeconds(self.model.currentTime);
    
    if (time != 0 && time >= self.model.lastTime + 0.3) {
        self.model.lastTime = time;
        [self endAwakenWhenReadyToPlay];
        if (self.playerStatus == CLMediaPlayerStatusPlaying) {
            return;
        }
        self.playerStatus = CLMediaPlayerStatusPlaying;
    }
    else {
        if (self.playerStatus == CLMediaPlayerStatusBuffering) {
            [self startAwakenWhenBuffering];
            return;
        }
        self.playerStatus = CLMediaPlayerStatusBuffering;
    }
    
    [self callDelegateChangedStatus];
}


#pragma mark - 唤醒
// 唤醒时间
static NSTimeInterval _awakenTimeInterval = 3.0f;

/**
 * 重置唤醒时间
 */
- (void)resetAwakenWatingTimeInterval
{
    _awakenTimeInterval = 3.0f;
}

/**
 * 更新唤醒时间
 */
- (void)updateAwakenWatingTimeInterval
{
    _awakenTimeInterval += 2.0f;
    if (_awakenTimeInterval >= 12.0f) {
        _awakenTimeInterval = 12.0f;
    }
}

//  是否已经开启了唤醒
static BOOL _isOpenAwakenWhenBuffering = NO;

/**
 * 当视频开始加载的时候开启唤醒机制
 */
- (void)startAwakenWhenBuffering
{
    if (!_isOpenAwakenWhenBuffering) {
        _isOpenAwakenWhenBuffering = YES;
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(_awakenTimeInterval * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            
            if (!_isOpenAwakenWhenBuffering) {
                [self endAwakenWhenReadyToPlay];
                return ;
            }
            
            [self.model pause];
            [self updateAwakenWatingTimeInterval];
            [self.model resume];
        });
    }
}

/**
 * 当视频缓冲足够的时候, 关闭唤醒机制
 */
- (void)endAwakenWhenReadyToPlay
{
    if (_isOpenAwakenWhenBuffering) {
        _isOpenAwakenWhenBuffering = NO;
        [self resetAwakenWatingTimeInterval];
    }
}

#pragma mark - 代理回调
/**
 * 更新状态
 */
- (void)callDelegateChangedStatus
{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:didChangePlayStatus:)]) {
            [self.delegate mediaPlayer:self didChangePlayStatus:self.playerStatus];
        }
    });
}

#pragma mark - 通知
- (void)addNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didEndPlayingVideo:) name:AVPlayerItemDidPlayToEndTimeNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appDidReceiveMemoryWarning:) name:UIApplicationDidReceiveMemoryWarningNotification object:nil];
}

- (void)didEndPlayingVideo:(NSNotification *)notifcation
{
    AVPlayerItem *playerIten = (AVPlayerItem *)notifcation.object;
    if (playerIten != self.model.playerItem) {
        return;
    }
    
    self.playerStatus = CLMediaPlayerStatusStop;
    [self endCheckBufferTimerIfNeed];
    [self endAwakenWhenReadyToPlay];
    [self callDelegateChangedStatus];
    
    /// 判断是否需要自动重新播放
    if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayer:shouldAutoReplayVideoWithUrl:)]) {
        if ([self.delegate mediaPlayer:self shouldAutoReplayVideoWithUrl:self.model.url]) {
            /// 重新播放
            [self seekToOriginWhenResume];
        }
    }
}

- (void)appDidReceiveMemoryWarning:(id)sender
{
    [self stopPlay];
}

#pragma mark - 观察者
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    
    CLDebugLog(@"");
    if (context == &kCLPlayerItemStatusKey) {
        AVPlayerItem *playerItem  = (AVPlayerItem *)object;
        AVPlayerItemStatus status = playerItem.status;
        switch (status) {
            case AVPlayerItemStatusUnknown:
                self.playerStatus = CLMediaPlayerStatusUnkonw;
                [self callDelegateChangedStatus];
                break;
            case AVPlayerItemStatusReadyToPlay:
                self.playerStatus = CLMediaPlayerStatusReadyToPlay;
                if (!self.model) {
                    return;
                }
                [self callDelegateChangedStatus];
                [self.model resume];
                [self displayVideoPicturesOnShowLayer];
                break;
            case AVPlayerItemStatusFailed:
                self.playerStatus = CLMediaPlayerStatusFailed;
                [self endCheckBufferTimerIfNeed];
                [self endAwakenWhenReadyToPlay];
                [self callDelegateChangedStatus];
                break;
            default:
                break;
        }
    }
    else if (context == &kCLPlayerItemLoadedTimeRangesKey) {
        // 更新缓冲进度
        AVPlayerItem *playerItem  = (AVPlayerItem *)object;
        NSArray *loadedTimeRanges = playerItem.loadedTimeRanges;
        CMTime startTime   = [loadedTimeRanges.firstObject CMTimeValue];
        CMTime durtionTime = [loadedTimeRanges.lastObject CMTimeValue];
        
        NSTimeInterval loadedTimes = CMTimeGetSeconds(startTime) + CMTimeGetSeconds(durtionTime);
        self.model.loadedSeconds = loadedTimes;
        
        if (loadedTimes == 0 || isnan(loadedTimes) || loadedTimes <= self.model.lastTime) {
            return;
        }
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(mediaPlayerWithPlayerLoadedTimeDidChange:currentTime:loadedTime:)]) {
            [self.delegate mediaPlayerWithPlayerLoadedTimeDidChange:self currentTime:CMTimeGetSeconds(self.currentTime) loadedTime:loadedTimes];
        }
    }
    else if (context == &kCLMediaPlayerRateKey) {
        AVPlayer *player = (AVPlayer *)object;
        /// 开始加载后的播放状态改变
        if (player.rate != 0 && (self.playerStatus == CLMediaPlayerStatusReadyToPlay)) {
            self.playerStatus = CLMediaPlayerStatusPlaying;
            [self callDelegateChangedStatus];
        }
    }
}

#pragma mark - 操作功能
- (float)rate
{
    if (!self.model) {
        return 0.0f;
    }
    return self.model.rate;
}

- (void)setRate:(float)rate
{
    if (!self.model) {
        return ;
    }
    self.model.rate = rate;
}

- (BOOL)muted
{
    if (!self.model) {
        return NO;
    }
    return self.model.muted;
}

- (void)setMuted:(BOOL)muted
{
    if (!self.model) {
        return ;
    }
    self.model.muted = muted;
}

- (float)volume
{
    if (!self.model) {
        return 0.0f;
    }
    return self.model.volume;
}

- (void)setVolume:(float)volume
{
    if (!self.model) {
        return ;
    }
    self.model.volume = volume;
}

- (CMTime)currentTime
{
    if (!self.model) {
        return kCMTimeZero;
    }
    return self.model.currentTime;
}

- (NSTimeInterval)loadedSeconds
{
    if (!self.model) {
        return 0.0f;
    }
    return self.model.loadedSeconds;
}

- (NSTimeInterval)elapsedSeconds
{
    if (!self.model) {
        return 0.0f;
    }
    return self.model.elapsedSeconds;
}

- (NSTimeInterval)totalSeconds
{
    if (!self.model) {
        return 0.0f;
    }
    return self.model.totalSeconds;
}

- (void)resume
{
    if (!self.model || self.playerStatus == CLMediaPlayerStatusPlaying) {
        return;
    }
    if (self.playerStatus == CLMediaPlayerStatusStop) {
        self.playerStatus = CLMediaPlayerStatusUnkonw;
        [self seekToOriginWhenResume];
        return;
    }
    [self internalResumeWithNeedCallDelegate:YES];
}

- (void)pause
{
    if (!self.model || self.playerStatus == CLMediaPlayerStatusPause) {
        return;
    }
    [self internalPauseWithNeedCallDelegate:YES];
}

- (void)seekToTime:(CMTime)time {
    if (!self.model) {
        return;
    }
    BOOL needResume = self.rate != 0;
    self.model.lastTime = 0.0f;
    
    [self internalPauseWithNeedCallDelegate:NO];
    
    __weak typeof(self)weakSelf = self;
    [self.model.player seekToTime:time completionHandler:^(BOOL finished) {
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (finished && needResume) {
            [strongSelf internalResumeWithNeedCallDelegate:NO];
        }
    }];
    
}


- (void)stopPlay {
    if (!self.model) {
        return;
    }
    [self.model stopPlay];
    [self endCheckBufferTimerIfNeed];
    [self resetAwakenWatingTimeInterval];
    self.model = nil;
    
    self.playerStatus = CLMediaPlayerStatusStop;
    [self callDelegateChangedStatus];
}


#pragma mark - CLMediaPlayerPlaybackProtocol
- (void)seekToOriginWhenResume
{
    __weak typeof(self.model)weakModel = self.model;
    __weak typeof(self)weakSelf = self;
        
    [self.model.player seekToTime:CMTimeMake(0.0, 1.0) completionHandler:^(BOOL finished) {
        __strong typeof(weakModel)strongModel = weakModel;
        __strong typeof(weakSelf)strongSelf = weakSelf;
        if (!strongModel) return ;
        strongModel.lastTime = 0.0f;
        [strongModel resume];
        [strongSelf startCheckBufferingTimer];
        
    }];
}

- (void)internalResumeWithNeedCallDelegate:(BOOL)needCallDelegate
{
    [self.model resume];
    [self startCheckBufferingTimer];
    self.playerStatus = CLMediaPlayerStatusPlaying;
    if (needCallDelegate) {
        [self callDelegateChangedStatus];
    }
}

- (void)internalPauseWithNeedCallDelegate:(BOOL)needCallDelegate
{
    [self.model pause];
    [self endCheckBufferTimerIfNeed];
    self.playerStatus = CLMediaPlayerStatusPause;
    if (needCallDelegate) {
        [self callDelegateChangedStatus];
    }
}

- (void)displayVideoPicturesOnShowLayer
{
    self.model.playerLayer.frame = self.model.showLayer.bounds;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.01 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.model.showLayer addSublayer:self.model.playerLayer];
    });
}


@end
