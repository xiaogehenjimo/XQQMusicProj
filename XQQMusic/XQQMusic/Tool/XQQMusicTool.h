//
//  XQQMusicTool.h
//  XQQMusic
//
//  Created by XQQ on 16/9/19.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XQQMusic.h"
@class XQQMusic;
@interface XQQMusicTool : NSObject
//所有音乐
+ (NSArray*)musics;
//当前正在播放的音乐
+ (XQQMusic*)playingMusic;
//设置默认的音乐
+ (void)setUpPlayingMusic:(XQQMusic*)playingMusic;
//返回上一首音乐
+ (XQQMusic*)previousMusic;
//下一首
+ (XQQMusic*)nextMusic;
@end
