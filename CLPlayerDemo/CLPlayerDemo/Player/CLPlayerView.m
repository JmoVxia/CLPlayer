//
//  PlayerView.m
//  CLPlayerDemo
//
//  Created by JmoVxia on 2016/11/1.
//  Copyright © 2016年 JmoVxia. All rights reserved.
//

#import "CLPlayerView.h"
#import <AVFoundation/AVFoundation.h>
#import "UIView+CLSetRect.h"
#import "CLSlider.h"
#import "CLPlayerMaskView.h"
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




//间隙
#define Padding        CLscaleX(15)
//消失时间
#define DisappearTime  10
//顶部底部控件高度
#define ViewHeight     35
//按钮大小
#define ButtonSize     CLscaleX(40)
//滑块大小
#define SliderSize     CLscaleX(30)
//进度条颜色
#define ProgressColor     [UIColor colorWithRed:0.54118 green:0.51373 blue:0.50980 alpha:1.00000]
//缓冲颜色
#define ProgressTintColor [UIColor orangeColor]
//播放完成颜色
#define PlayFinishColor   [UIColor whiteColor]
//滑块颜色
#define SliderColor       [UIColor whiteColor]

@interface CLPlayerView ()

/**控件原始Farme*/
@property (nonatomic,assign) CGRect customFarme;
/**父类控件*/
@property (nonatomic,strong) UIView *fatherView;
/**全屏标记*/
@property (nonatomic,assign) BOOL   isFullScreen;
/**横屏标记*/
@property (nonatomic,assign) BOOL   landscape;
/**工具条隐藏标记*/
@property (nonatomic,assign) BOOL   isDisappear;
/**视频拉伸模式*/
@property (nonatomic,copy) NSString *videoFillMode;
/** 播发器的几种状态 */
@property (nonatomic, assign) CLPlayerState state;
/** 是否被用户暂停 */
@property (nonatomic, assign) BOOL  isPauseByUser;


/**播放器*/
@property (nonatomic,strong) AVPlayer                *player;
/**playerLayer*/
@property (nonatomic,strong) AVPlayerLayer           *playerLayer;
/**播放器item*/
@property (nonatomic,strong) AVPlayerItem            *playerItem;
/**播放进度条*/
@property (nonatomic,strong) CLSlider                *slider;
/**播放时间*/
@property (nonatomic,strong) UILabel                 *currentTimeLabel;
/**总时间*/
@property (nonatomic,strong) UILabel                 *totalTimeLabel;
/**全屏按钮*/
@property (nonatomic,strong) UIButton                *maxButton;
/**表面遮罩*/
@property (nonatomic,strong) CLPlayerMaskView        *maskView;
/**转子*/
@property (nonatomic,strong) UIActivityIndicatorView *activity;
/**缓冲进度条*/
@property (nonatomic,strong) UIProgressView          *progress;
/**顶部控件*/
@property (nonatomic,strong) UIView                  *topView;
/**底部控件 */
@property (nonatomic,strong) UIView                  *bottomView;
/**播放按钮*/
@property (nonatomic,strong) UIButton                *startButton;
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
        self.backgroundColor = [UIColor blackColor];
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
- (void)setUrl:(NSURL *)url
{
    self.frame                = _customFarme;
    _url                      = url;
    self.playerItem               = [AVPlayerItem playerItemWithAsset:[AVAsset assetWithURL:_url]];
    //创建
    _player                   = [AVPlayer playerWithPlayerItem:_playerItem];
    _playerLayer              = [AVPlayerLayer playerLayerWithPlayer:_player];
    _playerLayer.frame        = CGRectMake(0, 0, _customFarme.size.width, _customFarme.size.height);
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
    
    [self.layer addSublayer:_playerLayer];
    //创建原始屏幕UI
    [self originalscreen];
    //开始旋转
    [_activity startAnimating];
   
}

-(void)setPlayerItem:(AVPlayerItem *)playerItem
{
    
    if (_playerItem == playerItem) {return;}
    
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
        [_activity startAnimating];
    }else{
        [_activity stopAnimating];
        [self playVideo];
    }
}




#pragma mark - 创建播放器UI
- (void)creatUI
{
    //最上面的View
    _maskView                 = [[CLPlayerMaskView alloc]init];
    _maskView.frame           = CGRectMake(0, _playerLayer.frame.origin.y, _playerLayer.frame.size.width, _playerLayer.frame.size.height);
    [_maskView addTarget:self action:@selector(disappearAction:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_maskView];
    
    //顶部View条
    _topView                 = [[UIView alloc]init];
    _topView.frame           = CGRectMake(0, 0, _maskView.CLwidth, ViewHeight);
    _topView.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.00000f];
    [_maskView addSubview:_topView];
    
    //底部View条
    _bottomView                 = [[UIView alloc] init];
    _bottomView.frame           = CGRectMake(0, _maskView.CLheight - ViewHeight, _maskView.CLwidth, ViewHeight);
    _bottomView.backgroundColor = [UIColor colorWithRed:0.00000f green:0.00000f blue:0.00000f alpha:0.50000f];
    [_maskView addSubview:_bottomView];
    
    //转子
    _activity        = [[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activity.center = _maskView.center;
    [self.maskView addSubview:_activity];

    
    //创建播放按钮
    [self createButton];
    //创建全屏按钮
    [self createMaxButton];
    //创建进度条
    [self createProgress];
    //创建播放条
    [self createSlider];
    //创建总时间Label
    [self createtotalTimeLabel];
    //创建播放时间Label
    [self createCurrentTimeLabel];
    //创建返回按钮
    [self createBackButton];
    
    //手动调用计时器时间，解决旋转等引起跳转
    [self timeStack];
    
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
#pragma mark - 隐藏或者显示状态栏方法
- (void)setStatusBarHidden:(BOOL)hidden
{
    //取出当前控制器的导航条
    UIView *statusBar = [[[UIApplication sharedApplication] valueForKey:@"statusBarWindow"] valueForKey:@"statusBar"];
    //设置是否隐藏
    statusBar.hidden  = hidden;
}
#pragma mark - 创建UIProgressView
- (void)createProgress
{
    CGFloat width;
    if (_isLandscape == YES)
    {
        width = self.frame.size.width;
    }
    else
    {
        if (_isFullScreen == NO)
        {
            width = self.frame.size.width;
        }
        else
        {
            width = self.frame.size.height;
        }
    }
    _progress                = [[UIProgressView alloc]init];
    _progress.frame          = CGRectMake(_startButton.CLright + Padding + 40 + Padding, 0, width - 80 - Padding - _startButton.CLright - Padding - Padding - Padding - _maxButton.CLwidth - Padding, Padding);
    _progress.CLcenterY        = _bottomView.CLheight/2.0;
    //进度条颜色
    _progress.trackTintColor = ProgressColor;
    
    // 计算缓冲进度
    NSTimeInterval timeInterval = [self availableDuration];
    CMTime duration             = _playerItem.duration;
    CGFloat totalDuration       = CMTimeGetSeconds(duration);
    CGFloat progress            = timeInterval / totalDuration;
    [_progress setProgress:progress animated:NO];


    
    CGFloat time  = round(timeInterval);
    CGFloat total = round(totalDuration);
    
    //确保都是number
    if (isnan(time) == 0 && isnan(total) == 0)
    {
        if (time == total)
        {
            //缓冲进度颜色
            _progress.progressTintColor = ProgressTintColor;
        }
        else
        {
            //缓冲进度颜色
            _progress.progressTintColor = [UIColor clearColor];
        }
    }
    else
    {
        //缓冲进度颜色
        _progress.progressTintColor = [UIColor clearColor];
    }
    [_bottomView addSubview:_progress];
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
            NSLog(@"加载失败");
        }
    } else if ([keyPath isEqualToString:@"loadedTimeRanges"]) {
        
        // 计算缓冲进度
        NSTimeInterval timeInterval = [self availableDuration];
        CMTime duration             = self.playerItem.duration;
        CGFloat totalDuration       = CMTimeGetSeconds(duration);
        [self.progress setProgress:timeInterval / totalDuration animated:NO];
        self.progress.progressTintColor = ProgressTintColor;

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
        if (!self.playerItem.isPlaybackLikelyToKeepUp) { [self bufferingSomeSecond]; }
        
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
#pragma mark - 创建UISlider
- (void)createSlider
{
    _slider         = [[CLSlider alloc]init];
    _slider.frame   = CGRectMake(_progress.CLx, 0, _progress.CLwidth, 2);
    _slider.CLcenterY = _bottomView.CLheight/2.0;
    [_bottomView addSubview:_slider];
    
    //开始拖拽
    [_slider addTarget:self
                action:@selector(processSliderStartDragAction:)
      forControlEvents:UIControlEventTouchDown];
    //拖拽中
    [_slider addTarget:self
                action:@selector(sliderValueChangedAction:)
      forControlEvents:UIControlEventValueChanged];
    //结束拖拽
    [_slider addTarget:self
                action:@selector(processSliderEndDragAction:)
      forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchCancel | UIControlEventTouchUpOutside];
    
    //左边颜色
    _slider.minimumTrackTintColor = PlayFinishColor;
    //右边颜色
    _slider.maximumTrackTintColor = [UIColor clearColor];
}
#pragma mark - 拖动进度条
//开始
- (void)processSliderStartDragAction:(UISlider *)slider
{
    //暂停
    [self pausePlay];
    [self destroyTimer];
}
//结束
- (void)processSliderEndDragAction:(UISlider *)slider
{
    //继续播放
    [self playVideo];
    _timer = [NSTimer scheduledTimerWithTimeInterval:DisappearTime
                                              target:self
                                            selector:@selector(disappear)
                                            userInfo:nil
                                             repeats:NO];
}
//拖拽中
- (void)sliderValueChangedAction:(UISlider *)slider
{
    //计算出拖动的当前秒数
    CGFloat total           = (CGFloat)_playerItem.duration.value / _playerItem.duration.timescale;
    NSInteger dragedSeconds = floorf(total * slider.value);
    //转换成CMTime才能给player来控制播放进度
    CMTime dragedCMTime     = CMTimeMake(dragedSeconds, 1);
    [_player seekToTime:dragedCMTime];
}

#pragma mark - 创建播放时间
- (void)createCurrentTimeLabel
{
    _currentTimeLabel           = [[UILabel alloc]init];
    _currentTimeLabel.frame     = CGRectMake(0, 0, 40, ViewHeight / 2.0);
    _currentTimeLabel.textColor = [UIColor whiteColor];
    _currentTimeLabel.font      = [UIFont systemFontOfSize:12];
    _currentTimeLabel.text      = @"00:00";
    _currentTimeLabel.textAlignment = NSTextAlignmentCenter;
    _currentTimeLabel.CLcenterY = _progress.CLcenterY;
    _currentTimeLabel.CLleft    = _startButton.CLright + Padding;
    [_bottomView addSubview:_currentTimeLabel];
}
#pragma mark - 总时间
- (void)createtotalTimeLabel
{
    _totalTimeLabel           = [[UILabel alloc] init];
    _totalTimeLabel.frame     = CGRectMake(0, 0, 40, ViewHeight / 2.0);
    _totalTimeLabel.textColor = [UIColor whiteColor];
    _totalTimeLabel.font      = [UIFont systemFontOfSize:12];
    _totalTimeLabel.text      = @"00:00";
    _totalTimeLabel.textAlignment = NSTextAlignmentCenter;
    _totalTimeLabel.CLcenterY = _progress.CLcenterY;
    _totalTimeLabel.CLright   = _maxButton.CLleft - Padding;
    [_bottomView addSubview:_totalTimeLabel];
}

#pragma mark - 计时器事件
- (void)timeStack
{
    if (_playerItem.duration.timescale != 0)
    {
        //总共时长
        _slider.maximumValue = 1;
        //当前进度
        _slider.value        = CMTimeGetSeconds([_playerItem currentTime]) / (_playerItem.duration.value / _playerItem.duration.timescale);
        //当前时长进度progress
        NSInteger proMin     = (NSInteger)CMTimeGetSeconds([_player currentTime]) / 60;//当前秒
        NSInteger proSec     = (NSInteger)CMTimeGetSeconds([_player currentTime]) % 60;//当前分钟
        _currentTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", proMin, proSec];
        
        //duration 总时长
        NSInteger durMin     = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale / 60;//总分钟
        NSInteger durSec     = (NSInteger)_playerItem.duration.value / _playerItem.duration.timescale % 60;//总秒
        _totalTimeLabel.text = [NSString stringWithFormat:@"%02ld:%02ld", durMin, durSec];
    }
}
#pragma mark - 播放按钮
- (void)createButton
{
    _startButton           = [UIButton buttonWithType:UIButtonTypeCustom];
    _startButton.frame     = CGRectMake(Padding, 0, ButtonSize, ButtonSize);
    _startButton.CLcenterY = _bottomView.CLheight/2.0;
    [_bottomView addSubview:_startButton];
   
    //根据播放状态来设置播放按钮
    if (_player.rate == 1.0)
    {
        _startButton.selected = YES;
        [_startButton setBackgroundImage:[self getPictureWithName:@"CLPauseBtn"] forState:UIControlStateNormal];
    }
    else
    {
        _startButton.selected = NO;
        [_startButton setBackgroundImage:[self getPictureWithName:@"CLPlayBtn"] forState:UIControlStateNormal];
    }
    
    [_startButton addTarget:self
                     action:@selector(startAction:)
           forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - 播放暂停按钮方法
- (void)startAction:(UIButton *)button
{
    if (button.selected == YES)
    {
        [self pausePlay];
    }
    else
    {
        [self playVideo];
    }
}
#pragma mark - 返回按钮
- (void)createBackButton
{
    UIButton *backButton = [UIButton new];
    backButton.frame     = CGRectMake(CLscaleX(15), CLscaleX(15), CLscaleX(40), CLscaleX(40));    
    [backButton setImage:[self getPictureWithName:@"CLBackBtn"] forState:UIControlStateNormal];
    [_topView addSubview:backButton];
    [backButton addTarget:self
               action:@selector(backButtonAction:)
     forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - 全屏按钮
- (void)createMaxButton
{
    UIButton *maxButton = [UIButton buttonWithType:UIButtonTypeCustom];
    maxButton.frame     = CGRectMake(0, 0, ButtonSize, ButtonSize);
    maxButton.CLright     = _bottomView.CLright - Padding;
    maxButton.CLcenterY   = _bottomView.CLheight / 2.0;
    [_bottomView addSubview:maxButton];
    _maxButton = maxButton;
    
    if (_isFullScreen == YES)
    {
        [_maxButton setBackgroundImage:[self getPictureWithName:@"CLMinBtn"] forState:UIControlStateNormal];
    }
    else
    {
        [_maxButton setBackgroundImage:[self getPictureWithName:@"CLMaxBtn"] forState:UIControlStateNormal];
    }
    
    [_maxButton addTarget:self
               action:@selector(maxAction:)
     forControlEvents:UIControlEventTouchUpInside];
}
#pragma mark - 全屏按钮响应事件
- (void)maxAction:(UIButton *)button
{
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
            _topView.alpha    = 0;
            _bottomView.alpha = 0;
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
            _topView.alpha    = 1;
            _bottomView.alpha = 1;
        }];
    }
    _isDisappear = !_isDisappear;
}
#pragma mark - 定时消失
- (void)disappear
{
    [UIView animateWithDuration:0.5 animations:^{
        _topView.alpha    = 0;
        _bottomView.alpha = 0;
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
- (void)backButtonAction:(UIButton *)button
{
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
    _startButton.selected = NO;
    _isPauseByUser = YES;
    [_player pause];
    [_startButton setBackgroundImage:[self getPictureWithName:@"CLPlayBtn"] forState:UIControlStateNormal];
}
#pragma mark - 播放
- (void)playVideo
{
    _startButton.selected = YES;
    _isPauseByUser = NO;
    [_player play];
    [_startButton setBackgroundImage:[self getPictureWithName:@"CLPauseBtn"] forState:UIControlStateNormal];
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

    //取消定时器
    [self destroyAllTimer];
    
    [self setStatusBarHidden:YES];
    //添加到Window上
    UIWindow *keyWindow = [UIApplication sharedApplication].keyWindow;
    [keyWindow addSubview:self];
    
    if (_isLandscape == YES)
    {
        self.frame         = CGRectMake(0, 0, CLscreenWidth, CLscreenHeight);
        _playerLayer.frame = CGRectMake(0, 0, CLscreenWidth, CLscreenHeight);
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
        _playerLayer.frame = CGRectMake(0, 0, CLscreenHeight, CLscreenWidth);
    }
    
    //删除原有控件
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //创建全屏UI
    [self creatUI];
}
#pragma mark - 原始大小
- (void)originalscreen
{
    [[UIDevice currentDevice] setValue:[NSNumber numberWithInteger:UIInterfaceOrientationPortrait] forKey:@"orientation"];
    
    _isFullScreen = NO;
    
    //取消定时器
    [self destroyAllTimer];

    [self setStatusBarHidden:NO];

    [UIView animateWithDuration:0.25 animations:^{
        //还原大小
        self.transform = CGAffineTransformMakeRotation(0);
    }];
    
    self.frame = _customFarme;
    _playerLayer.frame = CGRectMake(0, 0, _customFarme.size.width, _customFarme.size.height);
    //还原到原有父类上
    [_fatherView addSubview:self];
    
    //删除
    [self.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    //创建小屏UI
    [self creatUI];
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
        NSLog(@"播放器被销毁了");
}
-(void)layoutSubviews{
    [super layoutSubviews];
//    self.playerLayer.frame = self.bounds;
}




@end
