//
//  XQQAudioTool.h
//  XQQMusic
//
//  Created by XQQ on 16/9/19.
//  Copyright © 2016年 UIP. All rights reserved.
//
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
@interface XQQAudioTool : NSObject
//播放音乐 fileName:音乐名
+ (AVAudioPlayer*)playMusicWithFileName:(NSString*)fileName;
//暂停音乐
+ (void)pauseMusicWithFileName:(NSString*)fileName;
//停止音乐
+ (void)stopMusicWithFileName:(NSString*)fileName;
//播放音效
+ (void)playSoundWithSoundName:(NSString*)soundName;
@end
