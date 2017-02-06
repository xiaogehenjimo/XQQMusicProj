//
//  XQQAudioTool.m
//  XQQMusic
//
//  Created by XQQ on 16/9/19.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import "XQQAudioTool.h"

@implementation XQQAudioTool
static NSMutableDictionary *_soudIDs;
static NSMutableDictionary *_players;

+ (void)initialize{
    _soudIDs = [NSMutableDictionary dictionary];
    _players = [NSMutableDictionary dictionary];
}
//播放音乐 fileName:音乐名
+ (AVAudioPlayer*)playMusicWithFileName:(NSString*)fileName{
    //创建空的播放器
    AVAudioPlayer * player = nil;
    //从字典中取出播放器
    player = _players[fileName];
    //判断播放器是否为空
    if (player == nil) {
        //生成对应的音乐源
        NSURL  * fileURL = [[NSBundle mainBundle] URLForResource:fileName withExtension:nil];
        if (fileURL == nil) return nil;
            //创建对应的播放器
        player = [[AVAudioPlayer alloc]initWithContentsOfURL:fileURL error:nil];
        //保存到字典中
        [_players setObject:player forKey:fileName];
        //准备播放
        [player prepareToPlay];
    }
    //播放
    [player play];
    return player;
}
//暂停音乐
+ (void)pauseMusicWithFileName:(NSString*)fileName{
    //从字典中取出播放器
    AVAudioPlayer *player = [_players objectForKey:fileName];
    //暂停音乐
    if (player) {
        [player pause];
    }
}
//停止音乐
+ (void)stopMusicWithFileName:(NSString*)fileName{
    //从字典中取出播放器
    AVAudioPlayer *player = [_players objectForKey:fileName];
    if (player) {
        [player stop];
        [_players removeObjectForKey:fileName];
        player = nil;
    }
}
//播放音效
+ (void)playSoundWithSoundName:(NSString*)soundName{
    //创建soundID = 0;
    SystemSoundID soundID = 0;
    //从字典中取出soundID
    soundID = [_soudIDs[soundName] unsignedIntValue];
    //判断soundID是否为0
    if (soundName == 0) {
        //生成soundID
        CFURLRef url = (__bridge CFURLRef)[[NSBundle mainBundle] URLForResource:soundName withExtension:nil];
        if (url == nil) return;
        AudioServicesCreateSystemSoundID(url, &soundID);
        //将soundID保存到字典中
        [_soudIDs setObject:@(soundID) forKey:soundName];
    }
    //播放音效
    AudioServicesPlaySystemSound(soundID);
}
@end
