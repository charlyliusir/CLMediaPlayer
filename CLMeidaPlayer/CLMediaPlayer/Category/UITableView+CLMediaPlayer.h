//
//  UITableView+CLMediaPlayer.h
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/21.
//  Copyright © 2018年 charly. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UITableViewCell+CLMediaPlayer.h"

@interface UITableView (CLMediaPlayer)

@property (nonatomic, readonly, strong) CLMediaPlayerManager *playerManager;

@property (nonatomic, readonly, strong) UITableViewCell *playVideoCell;

@property (nonatomic, assign) CGRect visiableTableViewFrame;

#pragma mark - Public Method
- (void)mp_initializtionVisibleCellPlaceCellTypeAfterReload;
/**
 * 初始化 Cell 的位置信息
 *
 * @param tableViewCell 被初始化的 Cell
 * @param indexPath     Cell 在 UITableView 中的位置
 */
- (void)mp_initializtionPlaceCellTypeWithUITableViewCell:(UITableViewCell *)tableViewCell
                                               indexPath:(NSIndexPath *)indexPath;

/**
 * 遍历查询最佳播放 Cell
 *
 * @return 最佳播放 Cell
 */
- (UITableViewCell *)mp_findBestPlayVideoCell;

/**
 * 播放器停止播放
 */
- (void)mp_stopPlayIfNeed;

- (void)mp_playVisibleCellIfNeed;

#pragma mark - UITableView ScrollViewDelegate
- (void)mp_scrollViewDidScroll;
- (void)mp_scrollViewDidEndDraggingWithDecelerate:(BOOL)decelerate;
- (void)mp_scrollViewDidEndDecelerating;

@end
