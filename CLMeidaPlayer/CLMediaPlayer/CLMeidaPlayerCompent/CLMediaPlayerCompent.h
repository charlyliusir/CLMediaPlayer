//
//  CLMediaPlayerCompent.h
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/20.
//  Copyright © 2018年 charly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@class CLMediaPlayerModel;

#pragma mark - 枚举

typedef NS_ENUM(NSUInteger, CLMediaPlayerStatus) {
    /**
     * 初始状态, 未知
     */
    CLMediaPlayerStatusUnkonw = 0,
    
    /**
     * 视频加载中
     */
    CLMediaPlayerStatusBuffering,
    
    /**
     * 视频可以开始播放
     */
    CLMediaPlayerStatusReadyToPlay,
    
    /**
     * 视频正在播放中
     */
    CLMediaPlayerStatusPlaying,
    
    /**
     * 视频暂停
     */
    CLMediaPlayerStatusPause,
    
    /**
     * 视频播放失败
     */
    CLMediaPlayerStatusFailed,
    
    /**
     * 视频停止播放
     */
    CLMediaPlayerStatusStop
};

typedef NS_ENUM(NSUInteger, CLMediaPlayerOptions) {
    /**
     * 静音播放
     */
    CLMediaPlayerMutedPlay = 1 << 0,
    
    /**
     * 非均匀模式。两个维度完全填充至整个视图区域
     */
    CLMediaPlayerLayerVideoGravityResize = 1 << 1,
    
    /**
     * 等比例填充，直到一个维度到达区域边界
     */
    CLMediaPlayerLayerVideoGravityResizeAspect = 1 << 2,
    
    /**
     * 等比例填充，直到填充满整个视图区域，其中一个维度的部分区域会被裁剪
     */
    CLMediaPlayerLayerVideoGravityResizeAspectFill = 1 << 3,
};

typedef NS_ENUM(NSUInteger, CLMediaPlayerLogLevel) {
    /**
     * 不输出任何日志
     */
    CLMediaPlayerLogLevelNone,
    /**
     * 日志
     */
    CLMediaPlayerLogLevelLog,
    /**
     * 输出错误日志
     */
    CLMediaPlayerLogLevelError,
    /**
     * 输出警告日志
     */
    CLMediaPlayerLogLevelWaring,
    /**
     * 输出开发日志
     */
    CLMediaPlayerLogLevelDebug
};

#pragma mark - 定义字符串名称

/**
 * 监听视频播放状态属性
 */
UIKIT_EXTERN NSString *const CLPlayerItemStatusName;

/**
 * 监听视频缓冲进度属性
 */
UIKIT_EXTERN NSString *const CLPlayerItemLoadedTimeRangesName;

/**
 * 视频播放速率
 */
UIKIT_EXTERN NSString *const kCLMediaPlayerRateName;


#pragma mark - Block
/**
 * 播放器初始配置成功后的回调
 */
typedef void(^CLMediaPlayerConfigurationCompletion) (UIView *view, CLMediaPlayerModel *model);

@interface CLMediaPlayerCompent : NSObject

@end
