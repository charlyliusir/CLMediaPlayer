//
//  CLMediaPlayerProtocol.h
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/19.
//  Copyright © 2018年 charly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@protocol CLMediaPlayerProtocol <NSObject>

@end

@protocol CLMediaPlayerPlaybackProtocol <NSObject>

@required

/**
 * 播放速率 0-暂停/停止 1-播放[1 倍速率] 2-播放[2 倍速率]
 */
@property (nonatomic) float rate;

/**
 * 消音 [视频是否有声音]
 */
@property (nonatomic) BOOL muted;

/**
 * 视频播放声音 0-1
 */
@property (nonatomic) float volume;



/**
 * 获取视频总时长
 */
- (NSTimeInterval)totalSeconds;

/**
 * 获取视频已经播放的时长
 */
- (NSTimeInterval)elapsedSeconds;

/**
 * 获取视频缓冲进度
 */
- (NSTimeInterval)loadedSeconds;

/**
 * 视频当前时间
 */
- (CMTime)currentTime;

/**
 * 暂停操作
 */
- (void)pause;

/**
 * 播放&重播操作
 */
- (void)resume;

/**
 * 快进&快退
 *
 * @param time 目标时间
 */
- (void)seekToTime:(CMTime)time;

/**
 * 停止播放
 */
- (void)stopPlay;

@end
