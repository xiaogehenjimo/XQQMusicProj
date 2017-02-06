//
//  XQQPlayingViewController.m
//  XQQMusic
//
//  Created by XQQ on 16/9/19.
//  Copyright © 2016年 UIP. All rights reserved.
//

#import "XQQPlayingViewController.h"
#import <MediaPlayer/MediaPlayer.h>
#import "XQQMusic.h"
#import "XQQAudioTool.h"
#import "XQQMusicTool.h"
#import "XQQLrcTool.h"
#import "XQQLrcView.h"
#import "XQQLrcLabel.h"
@interface XQQPlayingViewController ()<UIScrollViewDelegate>
/**歌手背景视图*/
@property(nonatomic, strong)  UIImageView   *  albumView;
/**底部视图*/
@property(nonatomic, strong)  UIView        *  bottomView;
/**当前时间*/
@property(nonatomic, strong)  UILabel       *  currentTimeLabel;
/**总的时间*/
@property(nonatomic, strong)  UILabel       *  allTimeLabel;
/**滑块*/
@property(nonatomic, strong)  UISlider      *  progressSlider;
/**上一曲按钮*/
@property(nonatomic, strong)  UIButton      *  backBtn;
/**下一曲按钮*/
@property(nonatomic, strong)  UIButton      *  nextBtn;
/**暂停按钮*/
@property(nonatomic, strong)  UIButton      *  stopBtn;
/**顶部视图*/
@property(nonatomic, strong)  UIView        *  topView;
/**左侧下拉按钮*/
@property(nonatomic, strong)  UIButton      *  pullDownBtn;
/**歌曲名字label*/
@property(nonatomic, strong)  UILabel       *  songNameLabel;
/**歌手名字label*/
@property(nonatomic, strong)  UILabel       *  singerNameLabel;
/**右侧更多按钮*/
@property(nonatomic, strong)  UIButton      *  moreBtn;
/**中间的scrollView*/
@property(nonatomic, strong)  UIScrollView  *  centerScrollView;
/**滚动视图第一页*/
@property(nonatomic, strong)  UIView        *  firstScroll;
/**歌手头像*/
@property(nonatomic, strong)  UIImageView   *  iconImageView;
/**歌词label*/
@property(nonatomic, strong)  XQQLrcLabel   *  lrcLabel;
/**滚动视图第二页*/
@property(nonatomic, strong)  UIView        *  secondScroll;
/**第二页的视图*/
/**歌词视图*/
@property(nonatomic, strong)  XQQLrcView    *  lrcView;

/***/
/**播放器*/
@property(nonatomic, strong)  AVAudioPlayer *  currentPlayer;
/** 进度条时间 */
@property(nonatomic, strong)  NSTimer       *   progressTimer;
/** 歌词时间控制器 */
@property(nonatomic, strong)  CADisplayLink *  lrcTimer;
@end

@implementation XQQPlayingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    //初始化UI
    [self initUI];
    //开始播放音乐
    [self startPlayMusic];
    //将lrcView中的lrcLabel设置为主界面的lrcLabel
    self.lrcView.lrcLabel = self.lrcLabel;
    //监听
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(addIconViewAnimate) name:@"iconImageViewAnimation" object:nil];
}
//锁屏当中的按钮被点击了
- (void)remoteControlReceivedWithEvent:(UIEvent *)event{
    /*
     UIEventSubtypeRemoteControlPlay                 = 100,
     UIEventSubtypeRemoteControlPause                = 101,
     UIEventSubtypeRemoteControlStop                 = 102,
     UIEventSubtypeRemoteControlTogglePlayPause      = 103,
     UIEventSubtypeRemoteControlNextTrack            = 104,
     UIEventSubtypeRemoteControlPreviousTrack        = 105,
     UIEventSubtypeRemoteControlBeginSeekingBackward = 106,
     UIEventSubtypeRemoteControlEndSeekingBackward   = 107,
     UIEventSubtypeRemoteControlBeginSeekingForward  = 108,
     UIEventSubtypeRemoteControlEndSeekingForward    = 109,
     */
    switch (event.subtype) {
        case UIEventSubtypeRemoteControlPlay:
        case UIEventSubtypeRemoteControlPause:
            [self playingAndPause];
            break;
        case UIEventSubtypeRemoteControlNextTrack:{
            //下一首
            [self nextMusic];
        }
            break;
        case UIEventSubtypeRemoteControlPreviousTrack:{
            //上一曲
            [self previous];
        }
            break;
        default:
            break;
    }
}
#pragma mark - 初始化UI
/**初始化UI*/
- (void)initUI{
    /**背景*/
    [self.view addSubview:self.albumView];
    /**顶部视图*/
    [self.view addSubview:self.topView];
    /**中间的视图*/
    [self.view addSubview:self.centerScrollView];
    /**底部视图*/
    [self.view addSubview:self.bottomView];
   
}
#pragma mark - 开始播放音乐
/**开始播放音乐*/
- (void)startPlayMusic{
    //清除之前的歌词
    self.lrcLabel.text = nil;
    //获取当前正在播放的音乐
    XQQMusic * playingMusic = [XQQMusicTool playingMusic];
    //设置界面信息
    self.albumView.image = [UIImage imageNamed:playingMusic.icon];
    self.iconImageView.image = [UIImage imageNamed:playingMusic.icon];
    self.songNameLabel.text = playingMusic.name;
    self.singerNameLabel.text = playingMusic.singer;
    //播放音乐
    AVAudioPlayer * currentPlayer = [XQQAudioTool playMusicWithFileName:playingMusic.filename];
    self.currentTimeLabel.text = [NSString stringWithTime:currentPlayer.currentTime];
    self.allTimeLabel.text = [NSString stringWithTime:currentPlayer.duration];
    self.currentPlayer = currentPlayer;
    //设置播放按钮
    self.stopBtn.selected = self.currentPlayer.isPlaying;
    if (self.stopBtn.selected){
        [self setBtnImageWithNormalImageName:@"player_btn_pause_normal" HighlightedImageName:@"player_btn_pause_highlight" andBtn:self.stopBtn];
    }else{
        [self setBtnImageWithNormalImageName:@"player_btn_play_normal" HighlightedImageName:@"player_btn_play_highlight" andBtn:self.stopBtn];
    }
    //设置歌词
    self.lrcView.lrcName = playingMusic.lrcname;
    self.lrcView.duration = currentPlayer.duration;
    //开启定时器 先移除之前的定时器
    [self removeTimer];
    [self addTimer];
    [self removeLrcTimer];
    [self addLrcTimer];
    //添加iconView的动画
    [self addIconViewAnimate];
}
/**移除音乐定时器*/
- (void)removeTimer{
    [self.progressTimer invalidate];
    self.progressTimer = nil;
}
/**添加音乐定时器*/
- (void)addTimer{
    //提前更新数据
    [self updateProgressInfo];
    //添加定时器
    self.progressTimer = [NSTimer scheduledTimerWithTimeInterval:.5f target:self selector:@selector(updateProgressInfo) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.progressTimer forMode:NSDefaultRunLoopMode];
}
#pragma mark - 添加歌词定时器
/**添加歌词定时器*/
- (void)addLrcTimer{
    self.lrcTimer = [CADisplayLink displayLinkWithTarget:self selector:@selector(updateLrcInfo)];
    [self.lrcTimer addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
}
/**移除歌词定时器*/
- (void)removeLrcTimer{
    [self.lrcTimer invalidate];
    self.lrcTimer = nil;
}
#pragma mark - 更新歌词播放时间
- (void)updateLrcInfo{
    self.lrcView.currentTime = self.currentPlayer.currentTime;
}
#pragma mark - 更新音乐播放的时间
- (void)updateProgressInfo{
    //更新播放的时间
    self.currentTimeLabel.text = [NSString stringWithTime:self.currentPlayer.currentTime];
    //更新滑动条
    self.progressSlider.value = self.currentPlayer.currentTime / self.currentPlayer.duration;
}
/**添加动画*/
- (void)addIconViewAnimate{
    CABasicAnimation *rotateAnimate = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimate.fromValue = @(0);
    rotateAnimate.toValue = @(M_PI * 2);
    rotateAnimate.repeatCount = NSIntegerMax;
    rotateAnimate.duration = 35;
    [self.iconImageView.layer addAnimation:rotateAnimate forKey:nil];
}
#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView{
    //获取偏移量
    CGPoint offset = scrollView.contentOffset;
    //计算alpha的值
    CGFloat alpha =1 -  offset.x / self.centerScrollView.frame.size.width;
    self.iconImageView.alpha = alpha;
    self.lrcLabel.alpha = alpha;
}

#pragma mark - activity
- (void)topBtnDidPress:(UIButton*)button{
    switch (button.tag) {
        case 118:{
            NSLog(@"下拉");
        }
            break;
        case 119:{
            NSLog(@"更多");
        }
            break;
        default:
            break;
    }
}
/**头像被点击切换滚动视图的偏移量*/
- (void)iconImageViewDidPress{
    [UIView animateWithDuration:1.f animations:^{
        self.centerScrollView.contentOffset = CGPointMake(iphoneWidth, 0);
    }];
}
#pragma mark - 暂停播放
- (void)playingAndPause{
    self.stopBtn.selected = !self.stopBtn.selected;
    if (self.currentPlayer.playing) {//正在播放
        //暂停播放器
        [self.currentPlayer pause];
        //移除定时器
        [self removeTimer];
        //暂停动画
        [self.iconImageView.layer pauseAnimate];
        //设置按钮图片
        [self setBtnImageWithNormalImageName:@"player_btn_play_normal" HighlightedImageName:@"player_btn_play_highlight" andBtn:self.stopBtn];
    }else{//没有播放
        //开始播放
        [self.currentPlayer play];
        //添加定时器
        [self addTimer];
        //设置按钮图片
        [self setBtnImageWithNormalImageName:@"player_btn_pause_normal" HighlightedImageName:@"player_btn_pause_highlight" andBtn:self.stopBtn];
        //开始动画
        [self.iconImageView.layer resumeAnimate];
    }
}
#pragma mark - 上一首
- (void)previous{
    //获取上一曲音乐
    XQQMusic * music = [XQQMusicTool previousMusic];
    //开始动画
    [self.iconImageView.layer resumeAnimate];
    //播放音乐
    [self playMusicWithMusic:music];
}
#pragma mark - 下一首
- (void)nextMusic{
    XQQMusic * music = [XQQMusicTool nextMusic];
    //开始动画
    [self.iconImageView.layer resumeAnimate];
    //播放音乐
    [self playMusicWithMusic:music];
}
- (void)bottomBtnDidPress:(UIButton*)button{
    switch (button.tag) {
        case 996:{
            [self playingAndPause];
        }
            break;
        case 997:{
            //上一首
            [self previous];
        }
            break;
        case 998:{
            //下一首
            [self nextMusic];
        }
            break;
        default:
            break;
    }
}
- (void)playMusicWithMusic:(XQQMusic*)music{
    //获取当前播放的歌曲并停止
    XQQMusic * currentMusic = [XQQMusicTool playingMusic];
    [XQQAudioTool stopMusicWithFileName:currentMusic.filename];
    //设置上一首音乐为默认音乐
    [XQQMusicTool setUpPlayingMusic:music];
    //播放音乐更新界面信息
    [self startPlayMusic];
}
#pragma mark - 滑块点击事件
//滑块点击事件
- (void)progressSliderTouchUpInside{
    //更新播放的时间
    self.currentPlayer.currentTime = self.progressSlider.value * self.currentPlayer.duration;
    //添加定时器
    [self addTimer];
}
- (void)progressSliderTouchDown{
    //移除定时器
    [self removeTimer];
}
- (void)progressSliderTap:(UITapGestureRecognizer*)tap{
    //获取到点击的点
    CGPoint point  = [tap locationInView:tap.view];
    //获取点击的比例
    CGFloat ratio = point.x / self.progressSlider.bounds.size.width;
    //更新播放时间
    self.currentPlayer.currentTime = self.currentPlayer.duration * ratio;
    //更新时间和滑块的位置
    [self updateProgressInfo];
}
- (void)sliderDidChange:(UISlider*)slider{
    if (slider == self.progressSlider) {
        //拿到总时间
        NSArray * timeArr = [self.allTimeLabel.text componentsSeparatedByString:@":"];
        CGFloat m = [timeArr.firstObject floatValue];
        CGFloat s = [timeArr.lastObject floatValue];
        CGFloat allTime = (m > 0 ? m * 60 : 0) + (s > 0 ? s : 0);
        //比例
        CGFloat ratio = slider.maximumValue / allTime;
        //改变当前时间的label值
        CGFloat currentTime = slider.value / ratio;
        NSInteger current = currentTime;
        NSString * time = [self TimeformatFromSeconds:current];
        self.currentTimeLabel.text = time;
    }
}

#pragma mark - setter&getter
/**底部视图*/
- (UIView *)bottomView{
    if (!_bottomView) {
        CGFloat bottomViewX = 0;
        CGFloat bottomViewY = CGRectGetMaxY(self.centerScrollView.frame);
        CGFloat bottomViewW = iphoneWidth;
        CGFloat bottomViewH = iphoneHeight - CGRectGetMaxY(self.centerScrollView.frame);
        _bottomView = [[UIView alloc]initWithFrame:CGRectMake(bottomViewX, bottomViewY, bottomViewW, bottomViewH)];
        //_bottomView.backgroundColor = [UIColor redColor];
        //距离顶部15  宽42  高21
        //当前时间label
        CGFloat currentTimeLabelX = 0;
        CGFloat currentTimeLabelY = 15;
        CGFloat currentTimeLabelW = 42;
        CGFloat currentTimeLabelH = 21;
        self.currentTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(currentTimeLabelX, currentTimeLabelY, currentTimeLabelW, currentTimeLabelH)];
        //self.currentTimeLabel.backgroundColor = [UIColor yellowColor];
        self.currentTimeLabel.font = [UIFont systemFontOfSize:13];
        self.currentTimeLabel.textColor = [UIColor whiteColor];
        self.currentTimeLabel.text = @"00:13";
        [_bottomView addSubview:self.currentTimeLabel];
        //总时间label
        CGFloat allTimeLabelX = bottomViewW - 42;
        CGFloat allTimeLabelY = currentTimeLabelY;
        CGFloat allTimeLabelW = currentTimeLabelW;
        CGFloat allTimeLabelH = currentTimeLabelH;
        self.allTimeLabel = [[UILabel alloc]initWithFrame:CGRectMake(allTimeLabelX, allTimeLabelY, allTimeLabelW, allTimeLabelH)];
        //self.allTimeLabel.backgroundColor = [UIColor yellowColor];
        self.allTimeLabel.text = @"04:24";
        self.allTimeLabel.font = [UIFont systemFontOfSize:13];
        self.allTimeLabel.textColor = [UIColor whiteColor];
        [_bottomView addSubview:self.allTimeLabel];
        //滑块
        CGFloat progressSliderX = CGRectGetMaxX(self.currentTimeLabel.frame) + 5;
        CGFloat progressSliderY = 11;
        CGFloat progressSliderW = bottomViewW - currentTimeLabelW * 2 - 10;
        CGFloat progressSliderH = 30;
        self.progressSlider = [[UISlider alloc]initWithFrame:CGRectMake(progressSliderX, progressSliderY, progressSliderW, progressSliderH)];
        self.progressSlider.minimumTrackTintColor = XQQColor(38, 187, 102, 1);
        [self.progressSlider setThumbImage:[UIImage imageNamed:@"player_slider_playback_thumb"] forState:UIControlStateNormal];
        self.progressSlider.minimumValue = 0;
        self.progressSlider.maximumValue = 1;
        self.progressSlider.continuous = YES;
        [self.progressSlider addTarget:self action:@selector(sliderDidChange:) forControlEvents:UIControlEventValueChanged];
        [self.progressSlider addTarget:self action:@selector(progressSliderTouchUpInside) forControlEvents:UIControlEventTouchUpInside];
        [self.progressSlider addTarget:self action:@selector(progressSliderTouchDown) forControlEvents:UIControlEventTouchDown];
        UITapGestureRecognizer * sigleTap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(progressSliderTap:)];
        [self.progressSlider addGestureRecognizer:sigleTap];
        //self.progressSlider.backgroundColor = [UIColor blueColor];
        [_bottomView addSubview:self.progressSlider];
        //暂停/播放按钮
        CGFloat stopBtnX = bottomViewW/2 - 32;
        CGFloat stopBtnY = CGRectGetMaxY(self.progressSlider.frame) + 10;
        CGFloat stopBtnW = 64;
        CGFloat stopBtnH = 64;
        self.stopBtn = [[UIButton alloc]initWithFrame:CGRectMake(stopBtnX, stopBtnY, stopBtnW, stopBtnH)];
        [self setBtnImageWithNormalImageName:@"player_btn_pause_normal" HighlightedImageName:@"player_btn_pause_highlight" andBtn:self.stopBtn];
        self.stopBtn.tag = 996;
        [self.stopBtn addTarget:self action:@selector(bottomBtnDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:self.stopBtn];
        //回退按钮
        CGFloat backBtnX = stopBtnX - 35 - stopBtnW;
        CGFloat backBtnY = stopBtnY;
        CGFloat backBtnW = stopBtnW;
        CGFloat backBtnH = stopBtnH;
        self.backBtn = [[UIButton alloc]initWithFrame:CGRectMake(backBtnX, backBtnY, backBtnW, backBtnH)];
        [self setBtnImageWithNormalImageName:@"player_btn_pre_normal" HighlightedImageName:@"player_btn_pre_highlight" andBtn:self.backBtn];
        self.backBtn.tag = 997;
        [self.backBtn addTarget:self action:@selector(bottomBtnDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:self.backBtn];
        //前进按钮
        CGFloat nextBtnX = CGRectGetMaxX(self.stopBtn.frame) + 35;
        CGFloat nextBtnY = stopBtnY;
        CGFloat nextBtnW = stopBtnW;
        CGFloat nextBtnH = stopBtnH;
        self.nextBtn = [[UIButton alloc]initWithFrame:CGRectMake(nextBtnX, nextBtnY, nextBtnW, nextBtnH)];
        [self setBtnImageWithNormalImageName:@"player_btn_next_normal" HighlightedImageName:@"player_btn_next_highlight" andBtn:self.nextBtn];
        self.nextBtn.tag = 998;
        [self.nextBtn addTarget:self action:@selector(bottomBtnDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [_bottomView addSubview:self.nextBtn];
    }
    return _bottomView;
}
/**中间滚动视图视图*/
- (UIScrollView *)centerScrollView{
    if (!_centerScrollView) {
        CGFloat centerScrollViewX = 0;
        CGFloat centerScrollViewY = CGRectGetMaxY(self.topView.frame);
        CGFloat centerScrollViewW = iphoneWidth;
        CGFloat centerScrollViewH = iphoneHeight - self.topView.frame.size.height - 150;
        _centerScrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(centerScrollViewX, centerScrollViewY, centerScrollViewW, centerScrollViewH)];
        //_centerScrollView.backgroundColor = [UIColor yellowColor];
        _centerScrollView.showsVerticalScrollIndicator = NO;
        _centerScrollView.showsHorizontalScrollIndicator = NO;
        _centerScrollView.delegate = self;
        _centerScrollView.pagingEnabled = YES;
        _centerScrollView.contentSize = CGSizeMake(2 * iphoneWidth, 0);
        //左侧的视图
        CGFloat firstScrollX = 0;
        CGFloat firstScrollY = CGRectGetMaxY(self.topView.frame);
        CGFloat firstScrollW = centerScrollViewW;
        CGFloat firstScrollH = centerScrollViewH;
        self.firstScroll = [[UIView alloc]initWithFrame:CGRectMake(firstScrollX, firstScrollY, firstScrollW, firstScrollH)];
        //self.firstScroll.backgroundColor = [UIColor greenColor];
        UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(iconImageViewDidPress)];
        [self.firstScroll addGestureRecognizer:tap];
        //左侧的iconImageView 左 20
        CGFloat iconImageViewX = 20;
        CGFloat iconImageViewY = 20;
        CGFloat iconImageViewW = firstScrollW - iconImageViewX * 2;
        CGFloat iconImageViewH = iconImageViewW;
        self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(iconImageViewX, iconImageViewY, iconImageViewW, iconImageViewH)];
        self.iconImageView.image = [UIImage imageNamed:@"kzxd@2x.jpg"];
        self.iconImageView.layer.cornerRadius = self.iconImageView.bounds.size.width * 0.5;
        self.iconImageView.layer.masksToBounds = YES;
        self.iconImageView.layer.borderColor = XQQColor(36, 36, 36, 1.0).CGColor;
        self.iconImageView.userInteractionEnabled = YES;
        //添加点击事件切换scrollView的偏移量
        self.iconImageView.layer.borderWidth = 8;
        //歌词label
        CGFloat lrcLabelX = 0;
        CGFloat lrcLabelY = CGRectGetMaxY(self.iconImageView.frame)+15;
        CGFloat lrcLabelW = iphoneWidth;
        CGFloat lrcLabelH = 40;
        self.lrcLabel = [[XQQLrcLabel alloc]initWithFrame:CGRectMake(lrcLabelX, lrcLabelY, lrcLabelW, lrcLabelH)];
        self.lrcLabel.textAlignment = NSTextAlignmentCenter;
        self.lrcLabel.textColor  = [UIColor whiteColor];
        self.lrcLabel.font = [UIFont systemFontOfSize:18];
        [self.firstScroll addSubview:self.lrcLabel];
        [self.firstScroll addSubview:self.iconImageView];
        //右侧的视图
        self.secondScroll = [[UIView alloc]initWithFrame:CGRectMake(iphoneWidth, 0, centerScrollViewW, centerScrollViewH)];
        _lrcView = [[XQQLrcView alloc]initWithFrame:CGRectMake(0, 0, centerScrollViewW, centerScrollViewH)];
        [self.secondScroll addSubview:_lrcView];
        [self.view addSubview:self.firstScroll];
        [_centerScrollView addSubview:self.secondScroll];
    }
    return _centerScrollView;
}
/**顶部视图*/
- (UIView *)topView{
    if (!_topView) {
        CGFloat topViewX = 0;
        CGFloat topViewY = 0;
        CGFloat topViewW = iphoneWidth;
        CGFloat topViewH = 100;
        _topView = [[UIView alloc]initWithFrame:CGRectMake(topViewX, topViewY, topViewW, topViewH)];
        //_topView.backgroundColor = [UIColor yellowColor];
        //左侧按钮  上30   左20
        CGFloat pullDownBtnX = 20;
        CGFloat pullDownBtnY = 30;
        CGFloat pullDownBtnW = 40;
        CGFloat pullDownBtnH = 40;
        self.pullDownBtn = [[UIButton alloc]initWithFrame:CGRectMake(pullDownBtnX, pullDownBtnY, pullDownBtnW, pullDownBtnH)];
        //self.pullDownBtn.backgroundColor = [UIColor redColor];
        [self.pullDownBtn setImage:[UIImage imageNamed:@"miniplayer_btn_playlist_close"] forState:UIControlStateNormal];
        [self.pullDownBtn setImage:[UIImage imageNamed:@"miniplayer_btn_playlist_close_b"] forState:UIControlStateHighlighted];
        self.pullDownBtn.tag = 119;
        [self.pullDownBtn addTarget:self action:@selector(topBtnDidPress:) forControlEvents:UIControlEventTouchUpInside];
        //右侧的按钮
        CGFloat moreBtnX = topViewW - 60;
        CGFloat moreBtnY = 30;
        CGFloat moreBtnW = 40;
        CGFloat moreBtnH = 40;
        self.moreBtn = [[UIButton alloc]initWithFrame:CGRectMake(moreBtnX, moreBtnY, moreBtnW, moreBtnH)];
        //self.moreBtn.backgroundColor = [UIColor redColor];
        [self.moreBtn setImage:[UIImage imageNamed:@"main_tab_more"] forState:UIControlStateNormal];
        [self.moreBtn setImage:[UIImage imageNamed:@"main_tab_more_h"] forState:UIControlStateHighlighted];
        self.moreBtn.tag = 118;
        [self.moreBtn addTarget:self action:@selector(topBtnDidPress:) forControlEvents:UIControlEventTouchUpInside];
        [_topView addSubview:self.pullDownBtn];
        [_topView addSubview:self.moreBtn];
        //歌曲名字label
        CGFloat songNameLabelX = CGRectGetMaxX(self.pullDownBtn.frame) + 10;
        CGFloat songNameLabelY = 30;
        CGFloat songNameLabelW = iphoneWidth - 40 - moreBtnW - pullDownBtnW - 20;
        CGFloat songNameLabelH = 40;
        self.songNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(songNameLabelX, songNameLabelY, songNameLabelW, songNameLabelH)];
        self.songNameLabel.text = @"小苹果";
        self.songNameLabel.textColor = [UIColor whiteColor];
        self.songNameLabel.font = [UIFont systemFontOfSize:25];
        self.songNameLabel.textAlignment = NSTextAlignmentCenter;
        //self.songNameLabel.backgroundColor = [UIColor greenColor];
        [_topView addSubview:self.songNameLabel];
        //歌手名字label
        CGFloat singerNameLabelX = songNameLabelX;
        CGFloat singerNameLabelY = CGRectGetMaxY(self.songNameLabel.frame) + 5;
        CGFloat singerNameLabelW = songNameLabelW;
        CGFloat singerNameLabelH = 20;
        self.singerNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(singerNameLabelX, singerNameLabelY, singerNameLabelW, singerNameLabelH)];
        self.singerNameLabel.text = @"筷子兄弟";
        self.singerNameLabel.textColor = [UIColor whiteColor];
        self.singerNameLabel.textAlignment = NSTextAlignmentCenter;
        //self.singerNameLabel.backgroundColor = [UIColor yellowColor];
        [_topView addSubview:self.singerNameLabel];
    }
    return _topView;
}
/**歌手背景视图*/
- (UIImageView *)albumView{
    if (!_albumView) {
        _albumView = [[UIImageView alloc]initWithFrame:self.view.frame];
        _albumView.image = [UIImage imageNamed:@"kzxd@2x.jpg"];
        _albumView.userInteractionEnabled = YES;
        //添加毛玻璃效果
        UIToolbar * toolbar = [[UIToolbar alloc]init];
        [_albumView addSubview:toolbar];
        toolbar.barStyle = UIBarStyleBlack;
        //添加约束
        toolbar.translatesAutoresizingMaskIntoConstraints = YES;
        [toolbar mas_makeConstraints:^(MASConstraintMaker *make) {
            make.edges.equalTo(_albumView);
        }];
    }
    return _albumView;
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
//设置暂停按钮图片
- (void)setBtnImageWithNormalImageName:(NSString*)normalImageName
                  HighlightedImageName:(NSString*)highlightedImageName
                                andBtn:(UIButton*)button{
    [button setImage:[UIImage imageNamed:normalImageName] forState:UIControlStateNormal];
    [button setImage:[UIImage imageNamed:highlightedImageName] forState:UIControlStateHighlighted];
}
//移除监听
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}
//秒数换算
- (NSString*)TimeformatFromSeconds:(NSInteger)seconds
{
    //format of hour
    //    NSString *str_hour = [NSString stringWithFormat:@"%02ld",seconds/3600];
    //format of minute
    NSString *str_minute = [NSString stringWithFormat:@"%02ld",(seconds%3600)/60];
    //format of second
    NSString *str_second = [NSString stringWithFormat:@"%02ld",seconds%60];
    //format of time
    NSString *format_time = [NSString stringWithFormat:@"%@:%@",str_minute,str_second];
    return format_time;
}
@end
