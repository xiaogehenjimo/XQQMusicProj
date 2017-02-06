//
//  XQQLrcLabel.m
//  XQQMusic
//
//  Created by XQQ on 16/9/20.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import "XQQLrcLabel.h"

@implementation XQQLrcLabel
- (void)setProgress:(CGFloat)progress{
    _progress = progress;
    //就会调用下面的方法
    [self setNeedsDisplay];
}
- (void)drawRect:(CGRect)rect{
    [super drawRect:rect];
    CGRect fillRect = CGRectMake(0, 0, self.bounds.size.width *  self.progress, self.bounds.size.height);
    [XQQColor(49, 194, 124, 1) set];
    UIRectFillUsingBlendMode(fillRect, kCGBlendModeSourceIn);
}
@end
