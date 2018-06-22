//
//  NSObject+CLEmpty.h
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/19.
//  Copyright © 2018年 charly. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (CLEmpty)

/**
 * 判断字符串是否为空字符串
 * @param string 字符串
 * @return 是否为空字符串
 */
+ (BOOL)stringIsEmpty:(NSString *)string;

/**
 * 根据提供字符串
 *
 * @param urlString 视频/音频/图片 字符串地址
 * @return 视频/音频/图片 地址
 */
+ (NSURL *)urlWithString:(NSString *)urlString;

@end
