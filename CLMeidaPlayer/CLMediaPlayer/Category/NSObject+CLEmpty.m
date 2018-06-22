//
//  NSObject+CLEmpty.m
//  CLMeidaPlayer
//
//  Created by youplus on 2018/6/19.
//  Copyright © 2018年 charly. All rights reserved.
//

#import "NSObject+CLEmpty.h"

@implementation NSObject (CLEmpty)

/**
 * 判断字符串是否为空字符串
 * @param string 字符串
 * @return 是否为空字符串
 */
+ (BOOL)stringIsEmpty:(NSString *)string
{
    if (!string) {
        return YES;
    }
    if ([string isEqualToString:@""]) {
        return YES;
    }
    if ([string isEqualToString:@" "]) {
        return YES;
    }
    if ([string isEqualToString:@"\n"]) {
        return YES;
    }
    if ([string isEqualToString:@"\t"]) {
        return YES;
    }
    return NO;
}

/**
 * 根据提供字符串
 *
 * @param urlString 视频/音频/图片 字符串地址
 * @return 视频/音频/图片 地址
 */
+ (NSURL *)urlWithString:(NSString *)urlString
{
    NSURL *url = nil;
    
    if (![NSObject stringIsEmpty:urlString] &&
        ([urlString hasPrefix:@"http://"] ||
         [urlString hasPrefix:@"https://"])) {
        url = [NSURL URLWithString:urlString];
    }
    
    return url;
}

@end
