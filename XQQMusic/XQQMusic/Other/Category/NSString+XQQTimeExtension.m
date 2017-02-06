//
//  NSString+XQQTimeExtension.m
//  XQQMusic
//
//  Created by XQQ on 16/9/19.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import "NSString+XQQTimeExtension.h"

@implementation NSString (XQQTimeExtension)
+ (NSString *)stringWithTime:(NSTimeInterval)time
{
    NSInteger min = time / 60;
    NSInteger sec = (int)round(time) % 60;
    return [NSString stringWithFormat:@"%02ld:%02ld",min,sec];
}
@end
