//
//  UITableViewCell+CLMediaPlayer.h
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/21.
//  Copyright © 2018年 charly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UIView+CLMediaPlayer.h"

/**
 * Cell 的样式, 用来判断播放逻辑
 *
 * - CLMediaPlayerCellTypeNone: 表示 Cell 在顶, 如果 Cell 显示中则直接播放
 - CLMediaPlayerCellTypeTop:    表示 Cell 在底, 如果 Cell 显示中则直接播放
 - CLMediaPlayerCellTypeBottom: 表示 Cell 在中间, 靠近中心点的 Cell 优先播放
 */
typedef NS_ENUM(NSUInteger, CLMediaPlayerPlaceCellType) {
    CLMediaPlayerPlaceCellTypeNone,
    CLMediaPlayerPlaceCellTypeTop,
    CLMediaPlayerPlaceCellTypeBottom
};

@interface UITableViewCell (CLMediaPlayer)

@property (nonatomic, strong, nullable) UIView *mdPlayView;

@property (nonatomic, copy, nullable) NSString *videoUrl;

@property (nonatomic, assign) CLMediaPlayerPlaceCellType placeCellType;

+ (void)registerMediaPlayerView:(Class)class;

@end
