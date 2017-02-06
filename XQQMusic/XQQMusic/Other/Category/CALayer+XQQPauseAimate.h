//
//  CALayer+XQQPauseAimate.h
//  XQQMusic
//
//  Created by XQQ on 16/9/19.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>

@interface CALayer (XQQPauseAimate)
// 暂停动画
- (void)pauseAnimate;

// 恢复动画
- (void)resumeAnimate;
@end
