//
//  XQQLrcModel.m
//  XQQMusic
//
//  Created by XQQ on 16/9/20.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import "XQQLrcModel.h"

@implementation XQQLrcModel
- (instancetype)initWithLrcString:(NSString*)lrcString{
    if (self = [super init]) {
        //lrcString
        //[00:33.20]只是因为在人群中多看了你一眼
        NSArray * lrcArr = [lrcString componentsSeparatedByString:@"]"];
        self.text = lrcArr.lastObject;
        self.time = [self timeWithLrcStr:[lrcArr.firstObject substringFromIndex:1]];
    }
    return self;
}
- (NSTimeInterval)timeWithLrcStr:(NSString*)lrcStr{
    //00:33.20
    NSInteger min = [[lrcStr componentsSeparatedByString:@":"].firstObject integerValue];
    NSInteger sec = [[[[lrcStr componentsSeparatedByString:@"."] firstObject] componentsSeparatedByString:@":"].lastObject integerValue];
    NSInteger hs = [[lrcStr componentsSeparatedByString:@"."].lastObject integerValue];
    return min * 60 + sec + hs * 0.01;
}
+ (instancetype)LrcString:(NSString*)lrcString{
    return [[self alloc]initWithLrcString:lrcString];
}
@end
