//
//  XQQLrcModel.h
//  XQQMusic
//
//  Created by XQQ on 16/9/20.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XQQLrcModel : NSObject
@property(nonatomic, copy)      NSString  *  text;
@property(nonatomic, assign)    NSTimeInterval   time;
- (instancetype)initWithLrcString:(NSString*)lrcString;
+ (instancetype)LrcString:(NSString*)lrcString;
@end
