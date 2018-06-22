//
//  CLMediaPlayerUtils.m
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/21.
//  Copyright © 2018年 charly. All rights reserved.
//

#import "CLMediaPlayerUtils.h"
#import "UITableViewCell+CLMediaPlayer.h"
#import "UIView+CLMediaPlayer.h"
#import "NSObject+CLEmpty.h"

@implementation CLMediaPlayerLog

+ (void)logWithFlag:(CLMediaPlayerLogLevel)flag
           function:(const char *)function
         lineNumber:(NSUInteger)line
             format:(NSString *)format, ...
{
    if (flag > CLMediaPlayerLogLevelDebug) {
        return;
    }
    
    if (!format) {
        return;
    }
    
    va_list args;
    va_start(args, format);
    
    NSString *message = [[NSString alloc] initWithFormat:format arguments:args];
    
    NSString *logLevelFlag = @"DEBUG";
    switch (flag) {
        case CLMediaPlayerLogLevelError:
            logLevelFlag = @"ERROR";
            break;
        case CLMediaPlayerLogLevelWaring:
            logLevelFlag = @"WARING";
            break;
        case CLMediaPlayerLogLevelDebug:
            logLevelFlag = @"DEBUG";
            break;
        default:
            break;
    }
    
    NSString *threadNumber = [NSThread currentThread].description;
    threadNumber = [threadNumber componentsSeparatedByString:@">"].lastObject;
    threadNumber = [threadNumber componentsSeparatedByString:@","].firstObject;
    threadNumber = [threadNumber stringByReplacingOccurrencesOfString:@"{number = " withString:@""];
    
    /**
     * 格式 : [DEBUG] [LINE] FUNCTION => [thread: THREAD] : MESSAGE
     */
    NSString *logMessage = [NSString stringWithFormat:@"[%@] [%ld] %s  => [thread: %@]", logLevelFlag, line, function, threadNumber];
    if (![message isEqualToString:@""]) {
        logMessage = [logMessage stringByAppendingFormat:@" %@", message];
    }
    
    
    printf("%s\n", logMessage.UTF8String);
}

@end

@implementation CLMediaPlayerUtils

@end

@implementation CLMediaPlayerTableViewHelper

- (instancetype)initWithTableView:(UITableView *)tableView
{
    if (self = [super init]) {
        _tableView = tableView;
    }
    return self;
}

#pragma mark - Public Method

- (void)mp_initializtionVisibleCellPlaceCellTypeAfterReload
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.3 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UITableViewCell *cell in self.tableView.visibleCells) {
            [self mp_initializtionPlaceCellTypeWithUITableViewCell:cell indexPath:[self.tableView indexPathForCell:cell]];
        }
    });
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
    NSUInteger sections = [self.tableView numberOfSections];
    NSUInteger rows     = [self.tableView numberOfRowsInSection:sections - 1];
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        tableViewCell.placeCellType = CLMediaPlayerPlaceCellTypeTop;
    }
    else if (indexPath.section == sections - 1 && indexPath.row == rows - 1) {
        tableViewCell.placeCellType = CLMediaPlayerPlaceCellTypeBottom;
    }
    else {
        tableViewCell.placeCellType = CLMediaPlayerLogLevelNone;
    }
}

/**
 * 遍历查询最佳播放 Cell
 *
 * @return 最佳播放 Cell
 */
- (UITableViewCell *)mp_findBestPlayVideoCell
{
    if (CGRectIsEmpty(_visiableTableViewFrame)) {
        CLErrorLog(@"未赋值 visiableTableViewFrame");
        return nil;
    }
    
    CGFloat flag                = CGFLOAT_MAX;
    UITableViewCell *targetCell = nil;
    
    CGRect refrenceRect = [self.tableView.superview convertRect:_visiableTableViewFrame toView:nil];
    
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        
        if (![NSObject urlWithString:cell.videoUrl]) {
            continue;
        }
        
        UIView *playView = cell.mdPlayView;
        
        if (cell.placeCellType != CLMediaPlayerPlaceCellTypeNone) {
            if (cell.placeCellType == CLMediaPlayerPlaceCellTypeTop) {
                /// 判断第一个 Cell 的的底的起点是否在坐标系中
                CGPoint coordinatorPoint = playView.frame.origin;
                coordinatorPoint.y = coordinatorPoint.y + 10;
                coordinatorPoint   = [playView.superview convertPoint:coordinatorPoint toView:nil];
                if (CGRectContainsPoint(refrenceRect, coordinatorPoint)) {
                    targetCell = cell;
                    break;
                }
            }
            else {
                /// 判断最后一个 Cell 的顶是否在坐标系中
                CGPoint coordinatorPoint = playView.frame.origin;
                coordinatorPoint.y = CGRectGetMaxY(playView.frame) - 10;
                coordinatorPoint   = [playView.superview convertPoint:coordinatorPoint toView:nil];
                if (CGRectContainsPoint(refrenceRect, coordinatorPoint)) {
                    targetCell = cell;
                    break;
                }
            }
        }
        else {
            /// 判断哪个 Cell 距离中心点最近
            CGPoint coordinatorPoint = playView.center;
            coordinatorPoint = [playView.superview convertPoint:coordinatorPoint toView:nil];
            CGFloat tarFlag = fabs(coordinatorPoint.y - refrenceRect.size.height*.5 - refrenceRect.origin.y);
            if (tarFlag < flag) {
                flag = tarFlag;
                targetCell = cell;
            }
        }
    }
    
    return targetCell;
}

/**
 * 将要有一个视频在 Cell 中播放
 *
 * @param tableViewCell 将要播放视频的 Cell
 */
- (void)mp_willPlayVideoOnCell:(UITableViewCell *)tableViewCell
{
    [self mp_stopPlayIfNeed];
    
    _playVideoCell = tableViewCell;
    
#warning 此处后续添加公开调用播放回调
    [self videoPlayIfNeed];
}


/**
 * 播放器停止播放
 */
- (void)mp_stopPlayIfNeed
{
    if (_playVideoCell) {
        [self videoStopIfNeed];
    }
}

- (void)mp_playVisibleCellIfNeed
{
    if (_playVideoCell) {
        [self videoPlayIfNeed];
    }
    
    UITableViewCell *targetCell = nil;
    
    for (UITableViewCell *cell in self.tableView.visibleCells) {
        
        if ([NSObject urlWithString:cell.videoUrl]) {
            targetCell = cell;
            break;
        }
    }
    
    if (targetCell) {
        [self mp_willPlayVideoOnCell:targetCell];
    }
    
}

#pragma mark - UITableView ScrollViewDelegate
- (void)mp_scrollViewDidScroll
{
    if (!_playVideoCell) {
        return;
    }
    
    /// 判断当前播放的Cell是否在显示屏中
    if (![self viewIsVisibleInVisibleTableViewFrame:_playVideoCell.mdPlayView]) {
        [self mp_stopPlayIfNeed];
    }
}

- (void)mp_scrollViewDidEndDraggingWithDecelerate:(BOOL)decelerate
{
    if (decelerate == NO) {
        [self ifNeedStopScoll];
    }
}

- (void)mp_scrollViewDidEndDecelerating
{
    [self ifNeedStopScoll];
}

#pragma mark - Private Method
- (void)ifNeedStopScoll
{
    // 1. 遍历获得最佳播放视频的 Cell
    UITableViewCell *bestPlayVideoCell = [self mp_findBestPlayVideoCell];
    if (!bestPlayVideoCell) {
        return;
    }
    
    // 2. 如果最佳播放视频的 Cell 与当前播放视频的 Cell 是同一个, 则不进行任何操作
    if (_playVideoCell && [_playVideoCell isEqual:bestPlayVideoCell]) {
        return;
    }
    
    // 3. 播放视频
    [self mp_willPlayVideoOnCell:bestPlayVideoCell];
}

// 开始播放
- (void)videoPlayIfNeed
{
    [_playVideoCell.mdPlayView playerWithVideUrl:_playVideoCell.videoUrl
                                         options:CLMediaPlayerLayerVideoGravityResizeAspectFill
                                           muted:YES
                                       isRunLoop:YES
                             configureCompletion:nil];
}

// 停止播放
- (void)videoStopIfNeed
{
    [_playVideoCell.mdPlayView mp_stopVideo];
    _playVideoCell = nil;
}

// 判断视图是否在当前屏幕中显示
- (BOOL)viewIsVisibleInVisibleTableViewFrame:(UIView *)view
{
    // 1. 将 visiableTableViewFrame 转换到 父视图坐标系 [refrenceRect 参照坐标]
    CGRect refrenceRect = [self.tableView.superview convertRect:_visiableTableViewFrame toView:nil];
    
    // 2. 判断 view 的顶点坐标是否在参照坐标系中
    CGPoint viewFrameOrigin = view.frame.origin;
    viewFrameOrigin.y += 1;
    CGPoint topCoordinatePoint = [view.superview convertPoint:viewFrameOrigin toView:nil];
    BOOL isTopContain = CGRectContainsPoint(refrenceRect, topCoordinatePoint);
    
    // 3. 判断 view 的底部坐标是否在参照坐标系中
    viewFrameOrigin.y = CGRectGetMaxY(view.frame) - 1;
    CGPoint bottomCoordinatePoint = [view.superview convertPoint:viewFrameOrigin toView:nil];
    BOOL isBottomContain = CGRectContainsPoint(refrenceRect, bottomCoordinatePoint);
    
    if (!isTopContain && !isBottomContain) {
        return NO;
    }
    
    return YES;
}

@end
