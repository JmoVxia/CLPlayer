//
//  PlayerView.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2016/11/1.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import "CLPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "CLplayer.h"
#import "CLPlayerMaskView.h"
#import "UIView+CLSetRect.h"
//方向枚举
typedef NS_ENUM(NSInteger,Direction){
    Letf = 0,
    Right,
};

// 播放器的几种状态
typedef NS_ENUM(NSInteger, CLPlayerState) {
    CLPlayerStateFailed,     // 播放失败
    CLPlayerStateBuffering,  // 缓冲中
    CLPlayerStatePlaying,    // 播放中
    CLPlayerStateStopped,    // 停止播放
    CLPlayerStatePause       // 暂停播放
};





@interface CLPlayerView ()<CLPlayerMaskViewDelegate>

/**控件原始Farme*/
@property (nonatomic,assign) CGRect        customFarme;
/** 播发器的几种状态 */
@property (nonatomic,assign) CLPlayerState state;
/**父类控件*/
@property (nonatomic,strong) UIView        *fatherView;
/**视频拉伸模式*/
@property (nonatomic,copy) NSString        *videoFillMode;

/** 是否被用户暂停 */
@property (nonatomic,assign) BOOL   isPauseByUser;
/**全屏标记*/
@property (nonatomic,assign) BOOL   isFullScreen;
/**横屏标记*/
@property (nonatomic,assign) BOOL   landscape;
/**工具条隐藏标记*/
@property (nonatomic,assign) BOOL   isDisappear;


/**播放器*/
@property (nonatomic,strong) AVPlayer                *player;
/**playerLayer*/
@property (nonatomic,strong) AVPlayerLayer           *playerLayer;
/**播放器item*/
@property (nonatomic,strong) AVPlayerItem            *playerItem;
/**遮罩*/
@property (nonatomic,strong) CLPlayerMaskView        *maskView;
/**轻拍定时器*/
@property (nonatomic,strong) NSTimer                 *timer;
/**slider定时器*/
@property (nonatomic,strong) NSTimer                 *sliderTimer;

/**返回按钮回调*/
@property (nonatomic,copy) void (^BackBlock) (UIButton *backButton);
/**播放完成回调*/
@property (nonatomic,copy) void (^EndBlock) ();

@end

@implementation CLPlayerView
#pragma mark - 懒加载
//遮罩
- (CLPlayerMaskView *) maskView{
    if (_maskView == nil){
        _maskView          = [[CLPlayerMaskView alloc] init];
        _maskView.delegate = self;
        [_maskView addTarget:self action:@selector(disappearAction:) forControlEvents:UIControlEventTouchUpInside];
        //计时器，循环执行
        _sliderTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                        target:self
                                                      selector:@selector(timeStack)
                                                      userInfo:nil
                                                       repeats:YES];
        //定时器，工具条消失
        _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime
                                                  target:self
                                                selector:@selector(disappear)
                                                userInfo:nil
                                                 repeats:NO];
    }
    return _maskView;
}

#pragma mark - 初始化
- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame])
    {
        _customFarme         = frame;
        _isFullScreen        = NO;
        _autoFullScreen      = YES;
        _repeatPlay          = NO;
        _isLandscape         = NO;
        _landscape           = NO;
        _isDisappear         = NO;
        //开启
        [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
        //注册屏幕旋转通知
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientChange:)
                                                     name:UIDeviceOrientationDidChangeNotification
                                                   object:[UIDevice currentDevice]];
        //APP运行状态通知，将要被挂起
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(appwillResignActive:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];
        [self creatUI];

    }
    return self;
}
#pragma mark - 视频拉伸方式
-(void)setFillMode:(VideoFillMode)fillMode
{
    switch (fillMode)
    {
        case ResizeAspectFill:
            //原比例拉伸视频，直到两边屏幕都占满，但视频内容有部分会被剪切
            _videoFillMode = AVLayerVideoGravityResizeAspectFill;
            break;
        case ResizeAspect:
            //按原视频比例显示，是竖屏的就显示出竖屏的，两边留黑
            _videoFillMode = AVLayerVideoGravityResizeAspect;
            break;
        case Resize:
            //拉伸视频内容达到边框占满，但不按原比例拉伸
            _videoFillMode = AVLayerVideoGravityResize;
            break;
    }
}
#pragma mark - 是否自动支持全屏
- (void)setAutoFullScreen:(BOOL)autoFullScreen
{
    _autoFullScreen = autoFullScreen;
}
#pragma mark - 是否支持横屏
-(void)setIsLandscape:(BOOL)isLandscape
{
    _isLandscape = isLandscape;
    _landscape   = isLandscape;
}
#pragma mark - 重复播放
- (void)setRepeatPlay:(BOOL)repeatPlay
{
    _repeatPlay = repeatPlay;
}
#pragma mark - 传入播放地址
- (void)setUrl:(NSURL *)url{
    _url                      = url;
    self.playerItem           = [AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:_url]];
    //创建
    _player                   = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer              = [AVPlayerLayer playerLayerWithPlayer:_player];
    //设置静音模式播放声音
    AVAudioSession * session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayback error:nil];
    [session setActive:YES error:nil];
    //全屏拉伸
    _playerLayer.videoGravity = AVLayerVideoGravityResize;
    if (_videoFillMode)
    {
        _playerLayer.videoGravity = _videoFillMode;
    }
    //放到最下面，防止遮挡
    [self.layer insertSublayer:_playerLayer atIndex:0];


}

-(void)setPlayerItem:(AVPlayerItem *)playerItem
{
    
    if (_playerItem == playerItem){
        return;
    }
    
    if (_playerItem) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification object:_playerItem];
        [_playerItem removeObserver:self forKeyPath:@"status"];
        [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
        [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
        [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    }
    _playerItem = playerItem;
    if (playerItem) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(moviePlayDidEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:playerItem];
        [playerItem addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"loadedTimeRanges" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"playbackBufferEmpty" options:NSKeyValueObservingOptionNew context:nil];
        [playerItem addObserver:self forKeyPath:@"playbackLikelyToKeepUp" options:NSKeyValueObservingOptionNew context:nil];
    }
    
}
- (void)setState:(CLPlayerState)state{
    _state = state;
    if (state == CLPlayerStateBuffering) {
        [self.maskView.activity startAnimating];
    }else{
        [self.maskView.activity stopAnimating];
        [self playVideo];
    }
}
#pragma mark - 创建播放器UI
- (void)creatUI
{
    self.backgroundColor = [UIColor blackColor];
    //最上面的View
    [self addSubview:self.maskView];
}
#pragma mark - 隐藏或者显示状态栏方法
- (void)setStatusBarHidden:(BOOL)hidden
{
    //取出当前控制器的导航条
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    //设置是否隐藏
    statusBar.hidden  = hidden;
}
#pragma mark - 缓冲条监听
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSString *,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"status"]) {
        
        if (self.player.currentItem.status == AVPlayerItemStatusReadyToPlay) {
            self.state = CLPlayerStatePlaying;
        }
        else if (self.player.currentItem.status == AVPlayerItemStatusFailed) {
            self.state = CLPlayerStateFailed;
            CLlog(@"加载失败");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        // 计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration             = self.playerItem.duration;
        CGFloat totalDuration       = CMTimeGetSeconds(duration);
        [self.maskView.progress setProgress:timeInterval / totalDuration animated:NO];

    } else if ([keyPath isEqualToString:@"playbackBufferEmpty"]) {
        
        // 当缓冲是空的时候
        if (self.playerItem.playbackBufferEmpty) {
            self.state = CLPlayerStateBuffering;
            [self bufferingSomeSecond];
        }
        
    } else if ([keyPath isEqualToString:@"playbackLikelyToKeepUp"]) {
        
        // 当缓冲好的时候
        if (self.playerItem.playbackLikelyToKeepUp && self.state == CLPlayerStateBuffering){
            self.state = CLPlayerStatePlaying;
        }
        
    }
}

#pragma mark - 缓冲较差时候

/**
 *  缓冲较差时候回调这里
 */
- (void)bufferingSomeSecond
{
    self.state = CLPlayerStateBuffering;

    __block BOOL isBuffering = NO;
    if (isBuffering) return;
    isBuffering = YES;
    
    // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
    [self pausePlay];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        // 如果此时用户已经暂停了，则不再需要开启播放了
        if (self.isPauseByUser) {
            isBuffering = NO;
            return;
        }
        
        [self playVideo];
        // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
        isBuffering = NO;
        if (!self.playerItem.isPlaybackLikelyToKeepUp) {
            [self bufferingSomeSecond];
        }
        
    });
}


//计算缓冲进度
- (NSTimeInterval)availableDuration
{
    NSArray *loadedTimeRanges = [[_player currentItem] loadedTimeRanges];
    CMTimeRange timeRange     = [loadedTimeRanges.firstObject CMTimeRangeValue];// 获取缓冲区域
    float startSeconds        = CMTimeGetSeconds(timeRange.start);
    float durationSeconds     = CMTimeGetSeconds(timeRange.duration);
    NSTimeInterval result     = startSeconds + durationSeconds;// 计算缓冲总进度
    return result;
}
#pragma mark - 拖动进度条
//开始
-(void)cl_progressSliderTouchBegan:(CLSlider *)slider{
    //暂停
    [self pausePlay];
    [self destroyTimer];
}
//结束
-(void)cl_progressSliderTouchEnded:(CLSlider *)slider{
    //继续播放
    [self playVideo];
    _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime
                                              target:self
                                            selector:@selector(disappear)
                                            userInfo:nil
                                             repeats:NO];
}
//拖拽中
-(void)cl_progressSliderValueChanged:(CLSlider *)slider{
    //计算出拖动的当前秒数
    CGFloat total           = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
    NSInteger dragedSeconds = floorf(total * slider.value);
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime     = CMTimeMake(dragedSeconds, 1);
    [_player seekToTime:dragedCMTime];
}

#pragma mark - 计时器事件
- (void)timeStack
{
    if (_playerItem.duration.timescale != 0)
    {
        //总共时长
        self.maskView.slider.maximumValue = 1;
        //当前进度
        self.maskView.slider.value        = CMTimeGetSeconds([_playerItem currentTime]) / (_playerItem.duration.value / _playerItem.duration.timescale);
        //当前时长进度progress
        NSInteger proMin     = (NSInteger)CMTimeGetSeconds([_player currentTime]) / 60;//当前秒
        NSInteger proSec     = (NSInteger)CMTimeGetSeconds([_player currentTime]) % 60;//当前分钟
        self.maskView.currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", proMin, proSec];
        
        //duration 总时长
        NSInteger durMin     = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale / 60;//总分钟
        NSInteger durSec     = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale % 60;//总秒
        self.maskView.totalTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", durMin, durSec];
    }
}

#pragma mark - 播放暂停按钮方法
-(void)cl_playButtonAction:(UIButton *)button{
    if (button.selected == NO)
    {
        [self pausePlay];
    }
    else
    {
        [self playVideo];
    }
}

#pragma mark - 全屏按钮响应事件
-(void)cl_fullButtonAction:(UIButton *)button{
    _isLandscape = NO;
    if (_isFullScreen == NO)
    {
        [self fullScreenWithDirection:Letf];
    }
    else
    {
        [self originalscreen];
    }
    _isLandscape = _landscape;
}

#pragma mark - 点击响应
- (void)disappearAction:(UIButton *)button
{
    //取消定时消失
    [self destroyTimer];
    if (_isDisappear == NO)
    {
        [UIView animateWithDuration:0.5 animations:^{
            self.maskView.topToolBar.alpha    = 0;
            self.maskView.bottomToolBar.alpha = 0;
        }];
    }
    else
    {
        //添加定时消失
        _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime
                                                  target:self
                                                selector:@selector(disappear)
                                                userInfo:nil
                                                 repeats:NO];
        
        [UIView animateWithDuration:0.5 animations:^{
            self.maskView.topToolBar.alpha    = 1.0;
            self.maskView.bottomToolBar.alpha = 1.0;
        }];
    }
    _isDisappear = !_isDisappear;
}
#pragma mark - 定时消失
- (void)disappear
{
    [UIView animateWithDuration:0.5 animations:^{
        self.maskView.topToolBar.alpha    = 0;
        self.maskView.bottomToolBar.alpha = 0;
    }];
}
#pragma mark - 播放完成
- (void)moviePlayDidEnd:(id)sender
{
    if (_repeatPlay == NO)
    {
        [self pausePlay];
    }
    else
    {
        [self resetPlay];
    }
    if (self.EndBlock)
    {
        self.EndBlock();
    }
    
}
- (void)endPlay:(EndBolck) end
{
    self.EndBlock = end;
}
#pragma mark - 返回按钮
-(void)cl_backButtonAction:(UIButton *)button{
    if (self.BackBlock)
    {
        self.BackBlock(button);
    }
}
- (void)backButton:(BackButtonBlock) backButton;
{
    self.BackBlock = backButton;
}
#pragma mark - 暂停播放
- (void)pausePlay
{
    self.maskView.playButton.selected = NO;
    _isPauseByUser = YES;
    [_player pause];
}
#pragma mark - 播放
- (void)playVideo
{
    self.maskView.playButton.selected = YES;
    _isPauseByUser = NO;
    [_player play];
}
#pragma mark - 重新开始播放
- (void)resetPlay
{
    [_player seekToTime:CMTimeMake(0, 1)];
    [self playVideo];
}
#pragma mark - 销毁播放器
- (void)destroyPlayer
{
    //销毁定时器
    [self destroyAllTimer];
    //暂停
    [_player pause];
    //清除
    [_player.currentItem cancelPendingSeeks];
    [_player.currentItem.asset cancelLoading];
    //移除
    [self removeFromSuperview];

}
#pragma mark - 取消定时器
//销毁所有定时器
- (void)destroyAllTimer
{
    [_sliderTimer invalidate];
    [_timer invalidate];
    _sliderTimer = nil;
    _timer       = nil;
}
//销毁定时消失定时器
- (void)destroyTimer
{
    [_timer invalidate];
    _timer = nil;
}
#pragma mark - 屏幕旋转通知
- (void)orientChange:(NSNotification *)notification
{
    if (_autoFullScreen == NO)
    {
        return;
    }
    
    UIDeviceOrientation orientation = [UIDevice currentDevice].orientation;
    if (orientation == UIDeviceOrientationLandscapeLeft)
    {
        if (_isFullScreen == NO)
        {
            [self fullScreenWithDirection:Letf];
        }
    }
    else if (orientation == UIDeviceOrientationLandscapeRight)
    {
        if (_isFullScreen == NO)
        {
            [self fullScreenWithDirection:Right];
        }
    }
    else if (orientation == UIDeviceOrientationPortrait)
    {
        if (_isFullScreen == YES)
        {
            [self originalscreen];
        }
    }
}
#pragma mark - 全屏
- (void)fullScreenWithDirection:(Direction)direction
{
    //记录播放器父类
    _fatherView = self.superview;
    _isFullScreen = YES;
    [self setStatusBarHidden:YES];
    //添加到Window上
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    if (_isLandscape == YES)
    {
        self.frame         = CGRectMake(0, 0, CLscreenWidth, CLscreenHeight);
    }
    else
    {        
        if (direction == Letf)
        {
            [UIView animateWithDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeRotation(M_PI / 2);
            }];
        }
        else
        {
            [UIView animateWithDuration:0.25 animations:^{
                self.transform = CGAffineTransformMakeRotation( - M_PI / 2);
            }];
        }
        self.frame         = CGRectMake(0, 0, CLscreenWidth, CLscreenHeight);
    }
    self.maskView.fullButton.selected = YES;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
#pragma mark - 原始大小
- (void)originalscreen
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    
    _isFullScreen = NO;
    [self setStatusBarHidden:NO];
    [UIView animateWithDuration:0.25 animations:^{
        //还原大小
        self.transform = CGAffineTransformMakeRotation(0);
    }];
    
    self.frame = _customFarme;
    //还原到原有父类上
    [_fatherView addSubview:self];
    self.maskView.fullButton.selected = NO;
    [self setNeedsLayout];
    [self layoutIfNeeded];
}
#pragma mark - APP活动通知
- (void)appwillResignActive:(NSNotification *)note
{
    //将要挂起，停止播放
    [self pausePlay];
}
#pragma mark - 获取资源图片
- (UIImage *)getPictureWithName:(NSString *)name
{
    NSBundle *bundle = [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"CLPlayer" ofType:@"bundle"]];
    NSString *path   = [bundle pathForResource:name ofType:@"png"];
    return [UIImage imageWithContentsOfFile:path];
}
#pragma mark - 根据Cell位置判断是否销毁
- (void)calculateWith:(UITableView *)tableView cell:(UITableViewCell *)cell topOffset:(CGFloat)topOffset bottomOffset:(CGFloat)bottomOffset beyond:(BeyondBlock) beyond;
{
    //取出cell位置
    CGRect rect = cell.frame;
    //cell顶部
    CGFloat cellTop = rect.origin.y;
    //cell底部
    CGFloat cellBottom = rect.origin.y + rect.size.height;
    
    
    if (tableView.contentOffset.y + topOffset > cellBottom)
    {
        if (beyond)
        {
            beyond();
        }
        return;
    }
    
    if (cellTop > tableView.contentOffset.y + tableView.frame.size.height - bottomOffset)
    {
        if (beyond)
        {
            beyond();
        }
        return;
    }
}

#pragma mark - dealloc
- (void)dealloc
{
    [[UIDevice currentDevice] endGeneratingDeviceOrientationNotifications];
    [_playerItem removeObserver:self forKeyPath:@"status"];
    [_playerItem removeObserver:self forKeyPath:@"loadedTimeRanges"];
    [_playerItem removeObserver:self forKeyPath:@"playbackBufferEmpty"];
    [_playerItem removeObserver:self forKeyPath:@"playbackLikelyToKeepUp"];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:AVPlayerItemDidPlayToEndTimeNotification
                                                  object:_player.currentItem];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification
                                                  object:[UIDevice currentDevice]];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIApplicationWillResignActiveNotification
                                                  object:nil];
        CLlog(@"播放器被销毁了");
}
-(void)layoutSubviews{
    [super layoutSubviews];
    self.playerLayer.frame = self.bounds;
    self.maskView.frame = self.bounds;
}




@end
