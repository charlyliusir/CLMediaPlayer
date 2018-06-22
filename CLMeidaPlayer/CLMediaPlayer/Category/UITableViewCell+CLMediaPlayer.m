//
//  UITableViewCell+CLMediaPlayer.m
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/21.
//  Copyright © 2018年 charly. All rights reserved.
//

#import "UITableViewCell+CLMediaPlayer.h"
#import <objc/runtime.h>

static const char *kMPPlayerView        = "mpPlayerView";
static const char *kMPVideoUrl          = "videoUrl";
static const char *kMPPlaceCellType     = "placeCellType";

@implementation UITableViewCell (CLMediaPlayer)

static Class _mdPlayerViewClass;

+ (void)load
{
    _mdPlayerViewClass = [UIView class];
}

+ (void)registerMediaPlayerView:(Class)class
{
    _mdPlayerViewClass = class;
}

- (void)setMdPlayView:(UIView *)mdPlayView
{
    objc_setAssociatedObject(self, kMPPlayerView, mdPlayView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (UIView *)mdPlayView
{
    return objc_getAssociatedObject(self, kMPPlayerView);
}

- (void)setVideoUrl:(NSString *)videoUrl
{
    objc_setAssociatedObject(self, kMPVideoUrl, videoUrl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (NSString *)videoUrl
{
    return objc_getAssociatedObject(self, kMPVideoUrl);
}

- (void)setPlaceCellType:(CLMediaPlayerPlaceCellType)placeCellType
{
    objc_setAssociatedObject(self, kMPPlaceCellType, @(placeCellType), OBJC_ASSOCIATION_ASSIGN);
}

- (CLMediaPlayerPlaceCellType)placeCellType
{
    return [objc_getAssociatedObject(self, kMPPlaceCellType) unsignedIntegerValue];
}


#pragma mark - lazy mpPlayerView method
- (void)lazyLoadMdPlayerVier
{
    if (!self.mdPlayView) {
        self.mdPlayView = [[_mdPlayerViewClass alloc] init];
    }
}

@end
