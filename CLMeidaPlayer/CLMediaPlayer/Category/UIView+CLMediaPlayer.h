//
//  UIView+CLMediaPlayer.h
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/21.
//  Copyright © 2018年 charly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CLMediaPlayerUtils.h"
#import "CLMediaPlayerCompent.h"
#import "CLMediaPlayerManager.h"

@interface UIView (CLMediaPlayer)

@property (nonatomic, strong) CLMediaPlayerManager *playerManager;

- (void)playerWithVideUrl:(NSString *)url
                  options:(CLMediaPlayerOptions)options
                    muted:(BOOL)muted
                isRunLoop:(BOOL)isRunLoop
      configureCompletion:(CLMediaPlayerConfigurationCompletion)completion;

- (void)mp_stopVideo;

@end
