//
//  CLMediaPlayerUtils.h
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/21.
//  Copyright © 2018年 charly. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLMediaPlayerCompent.h"

@interface CLMediaPlayerLog : NSObject

+ (void)logWithFlag:(CLMediaPlayerLogLevel)flag
           function:(const char *)function
         lineNumber:(NSUInteger)line
             format:(NSString *)format, ...;

@end

// 打印测试日志
#define CLDebugLog(fmt, ...)    CLLog(CLMediaPlayerLogLevelDebug, fmt, ##__VA_ARGS__)

// 打印警告日志
#define CLWaringLog(fmt, ...)   CLLog(CLMediaPlayerLogLevelWaring, fmt, ##__VA_ARGS__)

// 打印错误日志
#define CLErrorLog(fmt, ...)    CLLog(CLMediaPlayerLogLevelError, fmt, ##__VA_ARGS__)


#define NSLog(fmt, ...) CLDebugLog(fmt, ##__VA_ARGS__)
// 打印 log 日志
#define CLLog(flag, fmt, ...)   [CLMediaPlayerLog  logWithFlag:(flag) \
function:__func__ \
lineNumber:__LINE__ \
format:(fmt), ##__VA_ARGS__]

@interface CLMediaPlayerUtils : NSObject

@end

@interface CLMediaPlayerTableViewHelper : NSObject

@property (nonatomic, weak) UITableView *tableView;

@property (nonatomic, strong) UITableViewCell *playVideoCell;

@property (nonatomic, assign) CGRect visiableTableViewFrame;

- (instancetype)initWithTableView:(UITableView *)tableView;

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
