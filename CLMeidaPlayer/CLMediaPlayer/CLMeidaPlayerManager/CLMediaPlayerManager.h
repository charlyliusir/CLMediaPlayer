//
//  CLMediaPlayerManager.h
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/19.
//  Copyright © 2018年 charly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLMediaPlayerCompent.h"
#import "CLMediaPlayerProtocol.h"
@class CLMediaPlayer;

@interface CLMediaPlayerManager : NSObject <CLMediaPlayerPlaybackProtocol>

@property (nonatomic, assign) BOOL isRunLoop;

@property (nonatomic, readonly, strong, nullable) CLMediaPlayer *videoPlayer;


- (void)playVideoWithUrl:(NSString *)videoUrl
                 options:(CLMediaPlayerOptions)options
             onShowLayer:(CALayer *)showLayer
 configurationCompletion:(CLMediaPlayerConfigurationCompletion)completion;

@end
