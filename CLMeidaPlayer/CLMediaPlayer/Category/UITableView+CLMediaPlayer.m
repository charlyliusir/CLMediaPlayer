//
//  UITableView+CLMediaPlayer.m
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/21.
//  Copyright © 2018年 charly. All rights reserved.
//

#import "UITableView+CLMediaPlayer.h"
#import "CLMediaPlayerUtils.h"
#import <objc/runtime.h>

static const char *kPlayerManager = "manager";
static const char *kTableViewHelper = "helper";

@interface UITableView ()

@property (nonatomic, strong, nullable) CLMediaPlayerTableViewHelper *helper;

@end

@implementation UITableView (CLMediaPlayer)

#pragma mark - getter and setter
- (void)setPlayerManager:(CLMediaPlayerManager *)playerManager
{
    objc_setAssociatedObject(self, kPlayerManager, playerManager, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (CLMediaPlayerManager *)playerManager
{
    return objc_getAssociatedObject(self, kPlayerManager);
}

- (UITableViewCell *)playVideoCell
{
    return self.helper.playVideoCell;
}

- (void)setVisiableTableViewFrame:(CGRect)visiableTableViewFrame
{
    self.helper.visiableTableViewFrame = visiableTableViewFrame;
}

- (CGRect)visiableTableViewFrame
{
    return self.helper.visiableTableViewFrame;
}

- (CLMediaPlayerTableViewHelper *)helper
{
    CLMediaPlayerTableViewHelper *_helper = objc_getAssociatedObject(self, kTableViewHelper);
    if (!_helper) {
        _helper = [[CLMediaPlayerTableViewHelper alloc] initWithTableView:self];
        objc_setAssociatedObject(self, kTableViewHelper, _helper, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    return _helper;
}

#pragma mark - Public Method
- (void)mp_initializtionVisibleCellPlaceCellTypeAfterReload
{
    [self.helper mp_initializtionVisibleCellPlaceCellTypeAfterReload];
}
/**
 * 初始化 Cell 的位置信息
 *
 * @param tableViewCell 被初始化的 Cell
 * @param indexPath     Cell 在 UITableView 中的位置
 */
- (void)mp_initializtionPlaceCellTypeWithUITableViewCell:(UITableViewCell *)tableViewCell
                                               indexPath:(NSIndexPath *)indexPath
{
    [self.helper mp_initializtionPlaceCellTypeWithUITableViewCell:tableViewCell indexPath:indexPath];
}

/**
 * 遍历查询最佳播放 Cell
 *
 * @return 最佳播放 Cell
 */
- (UITableViewCell *)mp_findBestPlayVideoCell
{
    return [self.helper mp_findBestPlayVideoCell];
}

/**
 * 播放器停止播放
 */
- (void)mp_stopPlayIfNeed
{
    [self.helper mp_stopPlayIfNeed];
}

- (void)mp_playVisibleCellIfNeed
{
    [self.helper mp_playVisibleCellIfNeed];
}

#pragma mark - UITableView ScrollViewDelegate
- (void)mp_scrollViewDidScroll
{
    [self.helper mp_scrollViewDidScroll];
}

- (void)mp_scrollViewDidEndDraggingWithDecelerate:(BOOL)decelerate
{
    [self.helper mp_scrollViewDidEndDraggingWithDecelerate:decelerate];
}

- (void)mp_scrollViewDidEndDecelerating
{
    [self.helper mp_scrollViewDidEndDecelerating];
}


@end
