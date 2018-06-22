//
//  UIView+CLMediaPlayer.m
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/21.
//  Copyright © 2018年 charly. All rights reserved.
//

#import "UIView+CLMediaPlayer.h"
#import <objc/runtime.h>

static const char *kPlayerManager = "manager";

@implementation UIView (CLMediaPlayer)

#pragma mark - getter and setter
- (void)setPlayerManager:(CLMediaPlayerManager *)playerManager
{
    objc_setAssociatedObject(self, kPlayerManager, playerManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CLMediaPlayerManager *)playerManager
{
    return objc_getAssociatedObject(self, kPlayerManager);
}

#pragma mark - public method
- (void)playerWithVideUrl:(NSString *)url
                  options:(CLMediaPlayerOptions)options
                    muted:(BOOL)muted
                isRunLoop:(BOOL)isRunLoop
      configureCompletion:(CLMediaPlayerConfigurationCompletion)completion
{
    [self lazyLoadMediaPlayer];
    
    self.playerManager.isRunLoop = isRunLoop;
    
    CLMediaPlayerConfigurationCompletion cp = completion ? completion : ^(UIView *view, CLMediaPlayerModel *model) {
        self.playerManager.muted = muted;
    };
    
    [self.playerManager playVideoWithUrl:url
                                 options:options
                             onShowLayer:self.layer
                 configurationCompletion:cp];
}

- (void)mp_stopVideo
{
    [self.playerManager stopPlay];
}

#pragma mark - lazy method
- (void)lazyLoadMediaPlayer
{
    if (!self.playerManager) {
        self.playerManager = [[CLMediaPlayerManager alloc] init];
    }
}

@end
