//
//  XQQLrcView.h
//  XQQMusic
//
//  Created by XQQ on 16/9/20.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import <UIKit/UIKit.h>
@class XQQLrcLabel;
@interface XQQLrcView : UIView
/**歌词名称*/
@property (nonatomic, copy)  NSString  *  lrcName;
/**当前的时间*/
@property (nonatomic, assign)  NSTimeInterval   currentTime;
/**主界面歌词的label*/
@property(nonatomic, strong)  XQQLrcLabel  *  lrcLabel;
/**总时间*/
@property (nonatomic, assign)  NSTimeInterval   duration;
@end
