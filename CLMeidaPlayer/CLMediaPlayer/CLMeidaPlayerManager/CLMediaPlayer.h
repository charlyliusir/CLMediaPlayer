//
//  CLMediaPlayer.h
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/19.
//  Copyright © 2018年 charly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import "CLMediaPlayerProtocol.h"
#import "CLMediaPlayerCompent.h"

@protocol CLMediaPlayerDelegate;

/**
 * 视频资源数据模型
 * Why : 为什么使用这个模型？
 * Answer : 一个视频对应一个模型, 方便创建&销毁, 保证不会同时存在多个视频播放.
 */
@interface CLMediaPlayerModel : NSObject <CLMediaPlayerPlaybackProtocol>

/**
 * 当前播放视频的图层.
 */
@property (nonatomic, readonly, strong, nonnull) AVPlayerLayer *playerLayer;

/**
 * 播放器.
 */
@property (nonatomic, readonly, strong, nonnull) AVPlayer *player;

@end

@interface CLMediaPlayer : NSObject <CLMediaPlayerPlaybackProtocol>

@property (nonatomic, weak, nullable) id <CLMediaPlayerDelegate> delegate;

#pragma mark - 初始化方法

/**
 *
 *
 * @param url 视频地址
 * @param options 可选项
 * @param showLayer 展示视频图片的图层
 * @return 当前播放视频的数据模型
 */
- (CLMediaPlayerModel *)playWithVideoUrl:(NSString *)url
                                 options:(CLMediaPlayerOptions)options
                               showLayer:(CALayer *)showLayer
                              completion:(CLMediaPlayerConfigurationCompletion)completion;

@end

@protocol CLMediaPlayerDelegate <NSObject>

/**
 * 视频是否需要重新播放
 *
 * @param player    播放器
 * @param videoUrl  当前播放视频的链接
 * @return 是否需要重新播放
 */
- (BOOL)mediaPlayer:(CLMediaPlayer *)player shouldAutoReplayVideoWithUrl:(NSURL *)videoUrl;

/**
 * 播放器播放状态发生改变
 *
 * @param player 播放器
 * @param status 当前状态
 */
- (void)mediaPlayer:(CLMediaPlayer *)player didChangePlayStatus:(CLMediaPlayerStatus)status;

/**
 * 视频播放进度发生变化
 *
 * @param player 播放器
 * @param elapsedSeconds 已播放时间
 * @param totalSeconds   视频总长度
 */
- (void)mediaPlayerWithPlayerProgressDidChange:(CLMediaPlayer *)player
                                elapsedSeconds:(NSTimeInterval)elapsedSeconds
                                  totalSeconds:(NSTimeInterval)totalSeconds;

/**
 * 视频缓冲数据发生变化
 *
 * @param player 播放器
 * @param currentTime 当前播放时间
 * @param loadedTime  缓冲总时长
 */
- (void)mediaPlayerWithPlayerLoadedTimeDidChange:(CLMediaPlayer *)player
                                     currentTime:(NSTimeInterval)currentTime
                                      loadedTime:(NSTimeInterval)loadedTime;

@end
