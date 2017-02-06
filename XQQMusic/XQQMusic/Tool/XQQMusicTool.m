//
//  XQQMusicTool.m
//  XQQMusic
//
//  Created by XQQ on 16/9/19.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import "XQQMusicTool.h"
@implementation XQQMusicTool
static NSArray *_musics;
static XQQMusic *_playingMusic;

+ (void)initialize
{
    if (_musics == nil) {
        _musics = [XQQMusic mj_objectArrayWithFilename:@"Musics.plist"];
    }
    if (_playingMusic == nil) {
        _playingMusic = _musics[1];
    }
}
+ (NSArray *)musics
{
    return _musics;
}

+ (XQQMusic *)playingMusic
{
    return _playingMusic;
}
+ (void)setUpPlayingMusic:(XQQMusic*)playingMusic
{
    _playingMusic = playingMusic;
}

+ (XQQMusic *)previousMusic
{
    // 1.获取当前音乐的下标值
    NSInteger currentIndex = [_musics indexOfObject:_playingMusic];
    // 2.获取上一首音乐的下标值
    NSInteger previousIndex = --currentIndex;
    XQQMusic *previousMusic = nil;
    if (previousIndex < 0) {
        previousIndex = _musics.count - 1;
    }
    previousMusic = _musics[previousIndex];
    return previousMusic;
}
+ (XQQMusic *)nextMusic
{
    // 1.获取当前音乐的下标值
    NSInteger currentIndex = [_musics indexOfObject:_playingMusic];
    // 2.获取下一首音乐的下标值
    NSInteger nextIndex = ++currentIndex;
    XQQMusic *nextMusic = nil;
    if (nextIndex >= _musics.count) {
        nextIndex = 0;
    }
    nextMusic = _musics[nextIndex];
    return nextMusic;
}

@end
