//
//  XQQLrcView.m
//  XQQMusic
//
//  Created by XQQ on 16/9/20.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import "XQQLrcView.h"
#import "XQQLrcCell.h"
#import "XQQLrcTool.h"
#import "XQQLrcModel.h"
#import "XQQMusic.h"
#import "XQQMusicTool.h"
#import <MediaPlayer/MediaPlayer.h>
#import "XQQAudioTool.h"
@interface XQQLrcView ()<UITableViewDelegate,UITableViewDataSource>
/**tableView*/
@property(nonatomic, strong)  UITableView  *  lrcTableView;
/**数据源*/
@property(nonatomic, strong)  NSMutableArray  *  dataArr;
/**记录刷新的某行*/
@property(nonatomic, assign)  NSInteger   refreshIndex;
@end

@implementation XQQLrcView

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super initWithCoder:aDecoder]) {
        //添加tableView
        [self setUpTableView];
    }
    return self;
}
- (instancetype)initWithFrame:(CGRect)frame{
    if (self = [super initWithFrame:frame]) {
        //添加tableView
        [self setUpTableView];
    }
    return self;
}
- (void)setLrcName:(NSString *)lrcName{
    //让tabelView滚动到中间
    [self.lrcTableView setContentOffset:CGPointMake(0, - self.lrcTableView.bounds.size.height * 0.5) animated:NO];
    //将refreshIndex设置为0
    self.refreshIndex = 0;
    _lrcName = lrcName;
    //解析歌词
    [self.dataArr setArray:[XQQLrcTool lrcToolWithLrcName:lrcName]];
    //设置第一句歌词
    XQQLrcModel * firstModel = self.dataArr.firstObject;
    self.lrcLabel.text = firstModel.text;
    //刷新表格
    [self.lrcTableView reloadData];
}
- (void)setCurrentTime:(NSTimeInterval)currentTime{
    _currentTime = currentTime;
    NSInteger count = self.dataArr.count;
    for (NSInteger i = 0; i < count; i ++) {
        //取出当前的歌词
        XQQLrcModel * currentModel = self.dataArr[i];
        //取出下一句歌词
        NSInteger nextIndex = i + 1;
        XQQLrcModel * nextModel = nil;
        if (nextIndex < count) {
            nextModel = self.dataArr[nextIndex];
        }
        //当前的播放时间和下一句的播放时间进行对比  大于等于当前的时间 并且小于下一句的时间  显示当前歌词
        if (self.refreshIndex != i && currentTime >= currentModel.time && currentTime < nextModel.time) {
            //当前的歌词滚动到中间
            NSIndexPath * currentIndexPath = [NSIndexPath indexPathForRow:i inSection:0];
            //上一句歌词
            NSIndexPath * previousIndex = [NSIndexPath indexPathForRow:self.refreshIndex inSection:0];
            //记录当前刷新的某行
            self.refreshIndex = i;
            [self.lrcTableView reloadRowsAtIndexPaths:@[currentIndexPath,previousIndex] withRowAnimation:UITableViewRowAnimationNone];
            [self.lrcTableView scrollToRowAtIndexPath:currentIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
            //设置主界面歌词的文字
            self.lrcLabel.text = currentModel.text;
            //生成锁屏界面的歌词图片
            [self genaratorLockImage];
        }
        if (self.refreshIndex == i) {//当前这句歌词
            //取出当前歌词的时间,用当前播放器的时间减去当前歌词的时间 除以(下一句歌词的时间- 当前歌词的时间)
            CGFloat value = (currentTime - currentModel.time) / (nextModel.time - currentModel.time);
            //设置当前歌词的播放进度
            NSIndexPath * indexPath = [NSIndexPath indexPathForRow:self.refreshIndex inSection:0];
            XQQLrcCell * lrcCell = [self.lrcTableView cellForRowAtIndexPath:indexPath];
            lrcCell.lrcLabel.progress = value;
            self.lrcLabel.progress = value;
        }
    }
}
//添加tableView
- (void)setUpTableView{
    UITableView * tableView = [[UITableView alloc]initWithFrame:self.frame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.backgroundColor = [UIColor clearColor];
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _lrcTableView = tableView;
    tableView.contentInset = UIEdgeInsetsMake(tableView.frame.size.height * 0.5, 0, tableView.frame.size.height * 0.5, 0);
    [self addSubview:tableView];
}
#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return self.dataArr.count;
}
- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    XQQLrcCell * cell = [XQQLrcCell lrcCellWithTableView:tableView];
    XQQLrcModel * lrcModel = self.dataArr[indexPath.row];
    if (self.refreshIndex == indexPath.row) {
        cell.lrcLabel.font = [UIFont boldSystemFontOfSize:18];
    }else{
        cell.lrcLabel.font = [UIFont systemFontOfSize:14];
        cell.lrcLabel.progress = 0;
    }
    cell.lrcLabel.text = lrcModel.text;
    return cell;
}

#pragma mark - lazy
- (NSMutableArray *)dataArr{
    if (!_dataArr) {
        _dataArr = @[].mutableCopy;
    }
    return _dataArr;
}
#pragma mark - 生成锁屏界面图片
- (void)genaratorLockImage{
    //取出当前播放的图片
    //当前播放的音乐
    XQQMusic * playingMusic = [XQQMusicTool playingMusic];
    UIImage * currentImage = [UIImage imageNamed:playingMusic.icon];
    //取出当前歌词
    XQQLrcModel * currentModel = self.dataArr[self.refreshIndex];
    //下一句歌词
    NSInteger nextIndex = self.refreshIndex + 1;
    XQQLrcModel * nextModel = nil;
    if (nextIndex < self.dataArr.count) {
        nextModel = self.dataArr[nextIndex];
    }
    //上一句歌词
    NSInteger previousIndex = self.refreshIndex - 1;
    XQQLrcModel * previousModel = nil;
    if (previousIndex >= 0) {
        previousModel = self.dataArr[previousIndex];
    }
    //生成水印图片
    //获取上下文
    UIGraphicsBeginImageContext(currentImage.size);
    
    [currentImage drawInRect:CGRectMake(0, 0, currentImage.size.width, currentImage.size.height)];
    //画上一句
    CGFloat textH = 25;
    CGFloat textX = 0 ;
    NSMutableParagraphStyle *  paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.alignment = NSTextAlignmentCenter;
    NSDictionary * attributes1 = @{NSFontAttributeName:[UIFont systemFontOfSize:14],NSForegroundColorAttributeName:[UIColor whiteColor],NSParagraphStyleAttributeName:paragraphStyle};
    [previousModel.text drawInRect:CGRectMake(textX, currentImage.size.height - 3 * textH, currentImage.size.width, textH) withAttributes:attributes1];
    //下一句
    [nextModel.text drawInRect:CGRectMake(textX, currentImage.size.height -  textH, currentImage.size.width, textH) withAttributes:attributes1];
    //当前一句歌词
    NSDictionary * attributes2 = @{NSFontAttributeName:[UIFont boldSystemFontOfSize:20],NSForegroundColorAttributeName:[UIColor greenColor],NSParagraphStyleAttributeName:paragraphStyle};
    [currentModel.text drawInRect:CGRectMake(textX, currentImage.size.height -  2 * textH, currentImage.size.width, textH) withAttributes:attributes2];
    //取出画好的image
    UIImage * lockImage = UIGraphicsGetImageFromCurrentImageContext();
    //关闭上下文
    UIGraphicsEndImageContext();
    //设置锁屏图片
    [self setupLockInfoWithLockImage:lockImage];
    
    
}
#pragma mark - 设置锁屏信息
- (void)setupLockInfoWithLockImage:(UIImage*)lockImage{
    /*
     // MPMediaItemPropertyAlbumTitle
     // MPMediaItemPropertyAlbumTrackCount
     // MPMediaItemPropertyAlbumTrackNumber
     // MPMediaItemPropertyArtist
     // MPMediaItemPropertyArtwork
     // MPMediaItemPropertyComposer
     // MPMediaItemPropertyDiscCount
     // MPMediaItemPropertyDiscNumber
     // MPMediaItemPropertyGenre
     // MPMediaItemPropertyPersistentID
     // MPMediaItemPropertyPlaybackDuration
     // MPMediaItemPropertyTitle
     */
    XQQMusic * playingMusic = [XQQMusicTool playingMusic];
    //获取锁屏中心
    MPNowPlayingInfoCenter * playingCenter = [MPNowPlayingInfoCenter defaultCenter];
    NSMutableDictionary * playingInfoDict = [NSMutableDictionary dictionary];
    [playingInfoDict setObject:playingMusic.name forKey:MPMediaItemPropertyAlbumTitle];
    [playingInfoDict setObject:playingMusic.singer forKey:MPMediaItemPropertyArtist];
    MPMediaItemArtwork * artWorh = [[MPMediaItemArtwork alloc]initWithImage:lockImage];
    [playingInfoDict setObject:artWorh forKey:MPMediaItemPropertyArtwork];
    [playingInfoDict setObject:@(_duration) forKey:MPMediaItemPropertyPlaybackDuration];
    [playingInfoDict setObject:@(self.currentTime) forKey:MPNowPlayingInfoPropertyElapsedPlaybackTime];
    playingCenter.nowPlayingInfo =playingInfoDict;
    //开启远程交互
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
}

@end
