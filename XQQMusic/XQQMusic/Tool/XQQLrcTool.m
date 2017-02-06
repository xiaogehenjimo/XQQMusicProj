//
//  XQQLrcTool.m
//  XQQMusic
//
//  Created by XQQ on 16/9/19.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import "XQQLrcTool.h"
#import "XQQLrcModel.h"
@implementation XQQLrcTool
+ (NSArray *)lrcToolWithLrcName:(NSString *)lrcName{
    NSString * path = [[NSBundle mainBundle] pathForResource:lrcName ofType:nil];
    NSString * lrcStr = [NSString stringWithContentsOfFile:path encoding:NSUTF8StringEncoding error:nil];
    NSArray * lrcArr = [lrcStr componentsSeparatedByString:@"\n"];
    NSMutableArray * tmpArr = @[].mutableCopy;
    for (NSString * lrcStr in lrcArr) {//去除含有以下多余的
        if ([lrcStr hasPrefix:@"[ar:"]||
            [lrcStr hasPrefix:@"[al:"]||
            [lrcStr hasPrefix:@"[ti:"]||
            ![lrcStr hasPrefix:@"["]) {
            continue;
        }
        XQQLrcModel * lrcModel = [XQQLrcModel LrcString:lrcStr];
        [tmpArr addObject:lrcModel];
    }
    return tmpArr;
}
@end
